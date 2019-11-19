# libvirtd

This is a simple container wrapping libvirtd.

## Purpose

Instead of delivering libvirtd in a package, libvirtd is
now delivered in a container.
When running the container it will _look_ like libvirtd is
running on the host's namespace. But in fact it's running
in a container.

This is similar to Atomic's 'system containers'.

You can use virsh on the host to access it.

To access libvirtd via TCP you still need to export
the correct port.

## Versions to use

Look for something like

    container_pull(
        name = "libvirt",
        digest = "sha256:1234567890abcdef..."
        registry = "index.docker.io",
        repository = "kubevirt/libvirt",
        #tag = "...",
    )

in the
[WORKSPACE](https://github.com/kubevirt/kubevirt/blob/master/WORKSPACE)
file for the KubeVirt project to figure out which version is currently
in use, and then run the same version using

    docker run \
      ... \
      kubevirt/libvirt@sha256:1234567890abcdef...

## Try with docker

Note: Make sure to not run libvirtd on the host.

Start the container

    docker run \
      --name libvirtd \
      --rm \
      --net=host \
      --pid=host \
      --ipc=host \
      --user=root \
      --privileged \
      -v /:/host:Z \
      -it kubevirt/libvirt:latest

Now, to verify, run, on the host:

    virsh capabilities

## Environment Variables

These environment variables can be passed into the container

* LIBVIRTD_DEFAULT_NETWORK_DEVICE: Set it to an existing device
  to let the default network point to it.

## Notes

Considerations that need to be taken into account:

* The D-Bus socket is not exposed inside the container
  so firewalld cannot be notified of changes (also
  not every host system uses firewalld) so the following
  ports might need to be allowed in if iptables is not
  accepting input by default:
  * TCP 16509
  * TCP 5900->590X (depending on Spice/VNC settings of guest)

  To run this container with the dbus socket mounted, a host
  directory could be mounted as a data volume. e.g.:

    docker run \
      --name libvirtd \
      --rm \
      --net=host \
      --pid=host \
      --ipc=host \
      --user=root \
      --privileged \
      -v /:/host:Z \
      -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket
      -it kubevirt/libvirt:latest

  The example path used here could vary across different systems.
