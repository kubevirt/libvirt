# Containerized libvirtd and QEMU

This is a simple container wrapping libvirtd.

# DO NOT USE THIS BRANCH

In order to be able to pick up fixes to a certain libvirt or QEMU
version without impacting images using different versions of those
components, we don't use a single `master` branch but rather several
branches that move forward independently.

Please pick the appropriate target branch when submitting pull
requests.
