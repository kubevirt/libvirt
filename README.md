# Containerized libvirtd and QEMU

This is a simple container wrapping libvirtd.

## Purpose

Instead of delivering libvirtd in a package, libvirtd is
now delivered in a container. This container is used as
the base container image for `virt-launcher` to run
as the entrypoint, it is not intended to be run standalone.
