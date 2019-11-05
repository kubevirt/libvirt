FROM fedora:30

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

ENV LIBVIRT_VERSION 5.0.0

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

RUN for arch in x86_64 ppc64; do \
      qemu="/usr/bin/qemu-system-${arch}"; \
      test -e "${qemu}" || continue; \
      setcap CAP_NET_BIND_SERVICE=+eip "${qemu}"; \
    done

CMD ["/libvirtd.sh"]
