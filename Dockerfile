FROM fedora:28

MAINTAINER "The KubeVirt Project" <kubevirt-dev@googlegroups.com>
ENV container docker

ENV LIBVIRT_VERSION 4.9.0

RUN PKGS="libvirt-libs-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-gluster-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-rbd-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-secret-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-nwfilter-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-bash-completion-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-disk-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-iscsi-direct-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-mpath-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-scsi-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-nodedev-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-zfs-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-iscsi-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-qemu-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-interface-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-client-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-kvm-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-core-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-logical-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-sheepdog-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-storage-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm,\
libvirt-daemon-driver-network-${LIBVIRT_VERSION}-1.fc28.x86_64.rpm" && \
  curl -O https://libvirt.org/sources/{$PKGS}

RUN dnf install -y \
    libvirt-* \
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
