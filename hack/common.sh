source hack/config

# Apply overrides from the environment
IMAGE_NAME="${IMAGE_NAME:-$CONF_IMAGE_NAME}"
FEDORA_VERSION="${CONF_FEDORA_VERSION:-$CONF_FEDORA_VERSION}"
LIBVIRT_VERSION="${LIBVIRT_VERSION:-$CONF_LIBVIRT_VERSION}"
QEMU_VERSION="${QEMU_VERSION:-$CONF_QEMU_VERSION}"
SEABIOS_VERSION="${SEABIOS_VERSION:-$CONF_SEABIOS_VERSION}"
QEMU_PACKAGE_NAME="${QEMU_PACKAGE_NAME:-$CONF_QEMU_PACKAGE_NAME}"
TARGET_ARCHITECTURES="${TARGET_ARCHITECTURES:-$CONF_TARGET_ARCHITECTURES}"

GIT_UNIX_TIMESTAMP=$(git show --format='%ct' | head -1)
GIT_TIMESTAMP=$(date --date="@${GIT_UNIX_TIMESTAMP}" '+%Y%m%d')
GIT_COMMIT=$(git describe --always)
IMAGE_TAG="${GIT_TIMESTAMP}-${GIT_COMMIT}"
DOCKER_PLATFORMS="linux/$(echo "${TARGET_ARCHITECTURES}" | sed "s: :,linux/:g")"

die() {
    echo "$@" >&2
    exit 1
}

_make_binary_version() {
    local package_version="$1"
    local os_version="$2"

    # Strip the .fc* or .el* suffix, if present
    package_version="${package_version%.fc*}"
    package_version="${package_version%.el*}"

    echo "${package_version}.fc${os_version}"
}

prepare_dockerfile() {
    # Source and binary versions might differ, because we might for
    # example rebuild a SRPM coming from Fedora 34 on Fedora 32
    LIBVIRT_SOURCE_VERSION="${LIBVIRT_VERSION}"
    QEMU_SOURCE_VERSION="${QEMU_VERSION}"
    SEABIOS_SOURCE_VERSION="${SEABIOS_VERSION}"
    LIBVIRT_BINARY_VERSION="$(_make_binary_version "${LIBVIRT_VERSION}" "${FEDORA_VERSION}")"
    QEMU_BINARY_VERSION="$(_make_binary_version "${QEMU_VERSION}" "${FEDORA_VERSION}")"
    SEABIOS_BINARY_VERSION="$(_make_binary_version "${SEABIOS_VERSION}" "${FEDORA_VERSION}")"

    # We need to do this instead of using the ARG feature because buildx
    # doesn't currently behave correctly when cross-building containers
    # that use that feature: preprocessing the file ourselves works
    # around that limitation
    sed -e "s/@FEDORA_VERSION@/${FEDORA_VERSION}/g" \
        -e "s/@LIBVIRT_SOURCE_VERSION@/${LIBVIRT_SOURCE_VERSION}/g" \
        -e "s/@LIBVIRT_BINARY_VERSION@/${LIBVIRT_BINARY_VERSION}/g" \
        -e "s/@QEMU_SOURCE_VERSION@/${QEMU_SOURCE_VERSION}/g" \
        -e "s/@QEMU_BINARY_VERSION@/${QEMU_BINARY_VERSION}/g" \
        -e "s/@SEABIOS_SOURCE_VERSION@/${SEABIOS_SOURCE_VERSION}/g" \
        -e "s/@SEABIOS_BINARY_VERSION@/${SEABIOS_BINARY_VERSION}/g" \
        -e "s/@QEMU_PACKAGE_NAME@/${QEMU_PACKAGE_NAME}/g" \
        <Dockerfile.in >Dockerfile
}

build_container() {
    local tag="$1"
    local platform="$2"
    local builder="$3"
    local push="$4"

    case "${builder}" in
    BUILDER_BUILDX)
        docker buildx build \
               --progress=plain \
               --platform="${platform}" \
               --tag "${tag}" \
               .
        ;;
    BUILDER_BUILD)
        docker build \
               --tag "${tag}" \
               .
        ;;
    *)
        die "build_container: Invalid argument"
        ;;
    esac
}

push_container() {
    local tag="$1"
    local platform="$2"
    local builder="$3"
    local push="$4"

    case "${push}" in
    PUSH_DOCKER)
        push_arg="--load"
        ;;
    PUSH_REGISTRY)
        push_arg="--push"
        ;;
    *)
        die "push_container: Invalid argument"
        ;;
    esac

    case "${builder}" in
    BUILDER_BUILDX)
        docker buildx build \
               --progress=plain \
               "${push_arg}" \
               --platform="${platform}" \
               --tag "${tag}" \
               .
        ;;
    BUILDER_BUILD)
        docker build \
               --tag "${tag}" \
               .
        if test "${push}" = PUSH_REGISTRY; then
            docker push "${tag}"
        fi
        ;;
    esac
}

delete_container() {
    local tag="$1"
    local platform="$2"
    local builder="$3"
    local push="$4"

    case "${push}" in
    PUSH_DOCKER)
        ;;
    *)
        die "delete_container: Invalid argument"
        ;;
    esac

    docker rmi "${tag}"
}

test_container() {
    local tag="$1"
    local platform="$2"
    local builder="$3"
    local push="$4"

    docker run \
           --rm \
           --platform="${platform}" \
           "${tag}" \
           uname -m
    docker run \
           --rm \
           --platform="${platform}" \
           "${tag}" \
           libvirtd --version
    docker run \
           --rm \
           --platform="${platform}" \
           "${tag}" \
           sh -c '
               set -e; \
               for qemu in \
                   /usr/bin/qemu-system-aarch64 \
                   /usr/bin/qemu-system-ppc64 \
                   /usr/bin/qemu-system-s390x \
                   /usr/bin/qemu-system-x86_64 \
                   /usr/libexec/qemu-kvm; \
               do \
                   test -f "$qemu" || continue; \
                   "$qemu" --version && break; \
               done
           '
}

build_and_test_containers() {
    local tag
    local platform
    local arch

    # We need to build for one architecture at a time because buildx
    # can't currently export multi-architecture containers to the Docker
    # daemon, so we wouldn't be able to test the results otherwise. The
    # deploy step will reuse the cached layers, so we're not wasting any
    # extra time building twice nor are we uploading contents that we
    # haven't made sure actually works
    for arch in ${TARGET_ARCHITECTURES}; do
        tag="${IMAGE_NAME}:${IMAGE_TAG}.${arch}"
        platform="linux/${arch}"

        build_container "${tag}" "${platform}" BUILDER_BUILDX PUSH_DOCKER
        push_container "${tag}" "${platform}" BUILDER_BUILDX PUSH_DOCKER
        test_container "${tag}" "${platform}" BUILDER_BUILDX PUSH_DOCKER
        delete_container "${tag}" "${platform}" BUILDER_BUILDX PUSH_DOCKER
    done
}
