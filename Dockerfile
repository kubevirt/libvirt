FROM fedora:27

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

# Direct libvirt dependencies
RUN dnf install -y \
  libvirt-daemon-kvm \
  libvirt-daemon-qemu \
  libvirt-client \
  selinux-policy selinux-policy-targeted \
  augeas && dnf clean all

# Kubevirt launcher dependencies
RUN dnf -y install \
  socat \
  genisoimage \
  util-linux \
  libcgroup-tools \
  ethtool \
  sudo && dnf -y clean all && \
  test $(id -u qemu) = 107 # make sure that the qemu user really is 107

COPY augconf /augconf
RUN augtool -f /augconf

COPY libvirtd.sh /libvirtd.sh
RUN chmod a+x /libvirtd.sh

CMD ["/libvirtd.sh"]
