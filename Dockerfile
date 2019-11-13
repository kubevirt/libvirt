FROM fedora:30

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

ARG LIBVIRT_VERSION
RUN dnf install -y dnf-plugins-core && \
  dnf copr enable -y @virtmaint-sig/for-kubevirt && \
  dnf install -y \
    libvirt-daemon-kvm-${LIBVIRT_VERSION} \
    libvirt-client-${LIBVIRT_VERSION} \
    genisoimage \
    selinux-policy selinux-policy-targeted \
    nftables \
    augeas && \
  dnf clean all

COPY augconf /augconf
RUN augtool -f /augconf

COPY libvirtd.sh /libvirtd.sh
RUN chmod a+x /libvirtd.sh

ARG QEMU_ARCH
RUN setcap CAP_NET_BIND_SERVICE=+eip "/usr/bin/qemu-system-${QEMU_ARCH}"

CMD ["/libvirtd.sh"]
