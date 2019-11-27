ARG FEDORA_VERSION
FROM fedora:${FEDORA_VERSION}

LABEL maintainer="The KubeVirt Project <kubevirt-dev@googlegroups.com>"

ARG COPR_VERSION
ARG LIBVIRT_VERSION
ARG QEMU_VERSION
RUN dnf install -y dnf-plugins-core && \
    dnf copr enable -y @virtmaint-sig/for-kubevirt-${COPR_VERSION} && \
    dnf install -y \
      libvirt-daemon-driver-qemu-${LIBVIRT_VERSION} \
      libvirt-client-${LIBVIRT_VERSION} \
      libvirt-daemon-driver-storage-core-${LIBVIRT_VERSION} \
      qemu-kvm-${QEMU_VERSION} \
      genisoimage \
      selinux-policy selinux-policy-targeted \
      nftables \
      iptables \
      augeas && \
    dnf update -y libgcrypt && \
    dnf clean all

COPY augconf /augconf
RUN augtool -f /augconf

COPY libvirtd.sh /libvirtd.sh
RUN chmod a+x /libvirtd.sh

RUN setcap CAP_NET_BIND_SERVICE=+eip "/usr/libexec/qemu-kvm"

CMD ["/libvirtd.sh"]
