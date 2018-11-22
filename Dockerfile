FROM fedora:28

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

RUN dnf install -y dnf-plugins-core && \
  dnf copr enable -y @virtmaint-sig/virt-preview && \
  dnf install -y \
  libvirt-daemon-kvm \
  libvirt-client \
  selinux-policy selinux-policy-targeted \
  augeas && dnf clean all

COPY augconf /augconf
RUN augtool -f /augconf

COPY libvirtd.sh /libvirtd.sh
RUN chmod a+x /libvirtd.sh

CMD ["/libvirtd.sh"]
