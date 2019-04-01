FROM fedora:28

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

ENV LIBVIRT_VERSION 5.1.0

RUN dnf install -y dnf-plugins-core && \
  dnf copr enable -y @virtmaint-sig/virt-preview && \
  dnf install -y \
    libvirt-daemon-kvm-${LIBVIRT_VERSION} \
    libvirt-client-${LIBVIRT_VERSION} \
    socat \
    genisoimage \
    selinux-policy selinux-policy-targeted \
    augeas && \
  dnf clean all

COPY augconf /augconf
RUN augtool -f /augconf

COPY libvirtd.sh /libvirtd.sh
RUN chmod a+x /libvirtd.sh

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/qemu-system-x86_64

CMD ["/libvirtd.sh"]
