FROM fedora:28

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ARG LIBVIRT_VERSION=4.9.0
ENV container docker

RUN curl --output /etc/yum.repos.d/fedora-virt-preview.repo \
  https://copr.fedorainfracloud.org/coprs/g/virtmaint-sig/virt-preview/repo/fedora-28/group_virtmaint-sig-virt-preview-fedora-28.repo && \
  dnf install -y \
  libvirt-daemon-kvm-$LIBVIRT_VERSION \
  libvirt-client-$LIBVIRT_VERSION \
  selinux-policy selinux-policy-targeted \
  augeas && dnf clean all

COPY augconf /augconf
RUN augtool -f /augconf

COPY libvirtd.sh /libvirtd.sh
RUN chmod a+x /libvirtd.sh

CMD ["/libvirtd.sh"]
