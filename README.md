# DEPRECATED
test
With the merge of https://github.com/kubevirt/kubevirt/pull/4703 this
repository is no longer needed in `kubevirt/kubevirt`.

The repository may get some sporadic fixes for kubevirt/kubevirt releses prior
to `v0.37.0` until they are EOL.

# Containerized libvirtd and QEMU

This is a simple container wrapping libvirtd.

## Purpose

Instead of delivering libvirtd in a package, libvirtd is
now delivered in a container. This container is used as
the base container image for `virt-launcher` to run
as the entrypoint, it is not intended to be run standalone.

## Build types

The specifics of the build process vary based on the type of build.

### Official builds

These happen on Travis CI, as three separate steps:

* first the environment is set up using the `hack/prepare.sh` script;

* then several single-architecture containers are built and tested,
  using `qemu-user` for cross-architecture support, as part of the
  `hack/build.sh` script;

* finally, a multi-architecture container is assembled and pushed to
  Docker Hub using the `hack/deploy.sh` script.

The entire process is described in `.travis.yml`, and no human
intervention is necessary.

### Local builds

These builds are mostly useful for maintainers.

It is expected that you have `docker buildx` set up and configured to
perform cross-architecture builds, as well as a local Docker registry
running on your machine.

To create a local build, use something like

```bash
$ IMAGE_NAME=localhost:5000/my-libvirt ./hack/local-build.sh
```

### Simple builds

These builds are perfect for quick testing: a single-architecture
container is built, so there is no additional setup required.

To create a simple build, use something like

```bash
$ IMAGE_NAME=my-libvirt ./hack/simple-build.sh
```

## Build configuration

The default configuration, which is used for official builds, is
stored in `hack/config`. See the file for information on how to
override some of the settings for a specific build.
