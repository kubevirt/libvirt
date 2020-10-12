source hack/config

GIT_UNIX_TIMESTAMP=$(git show --format='%ct' | head -1)
GIT_TIMESTAMP=$(date --date="@${GIT_UNIX_TIMESTAMP}" '+%Y%m%d')
GIT_COMMIT=$(git describe --always)
TAG="${GIT_TIMESTAMP}-${GIT_COMMIT}"
DOCKER_PLATFORM="linux/$(echo "${TARGET_ARCHITECTURES}" | sed "s: :,linux/:g")"
