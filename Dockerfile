FROM fedora:28

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

RUN curl --output /etc/yum.repos.d/fedora-virt-preview.repo \
  https://fedorapeople.org/groups/virt/virt-preview/fedora-virt-preview.repo && \
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
