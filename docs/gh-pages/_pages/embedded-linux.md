---
title: "Build embedded Linux systems"
permalink: /embedded-linux/
excerpt: "Build Yocto, OpenEmbedded and Buildroot projects directly inside containers, without the overhead of a virtual machine or changes to your existing build workflow."
---

Embedded Linux build systems require a long list of host packages, often in
specific versions. cqfd6 provides them in a build container, while the build
runs in your project directory, as your user, exactly as on the host.

Running as your user matters: *bitbake* refuses to run as root, and the build
artefacts belong to you once the build is over.

## Ready-to-use samples

cqfd6 comes with sample files for the common embedded Linux build systems. The
distribution packages install them under `/usr/share/cqfd6/samples/`:

| Sample                                                    | Environment                    |
| --------------------------------------------------------- | ------------------------------ |
| `Dockerfile.Yocto:scarthgap`, `dot-cqfdrc.Yocto:scarthgap` | Yocto Project and OpenEmbedded |
| `Dockerfile.Yocto:scarthgap`, `dot-cqfdrc.kas:4.5`         | Yocto Project with kas         |

## Build with Yocto

Copy the samples to the Poky directory:

```console
$ mkdir -p docker
$ cp /usr/share/cqfd6/samples/Dockerfile.Yocto:scarthgap docker/Dockerfile
$ cp /usr/share/cqfd6/samples/dot-cqfdrc.Yocto:scarthgap .cqfdrc
```

The `.cqfdrc` sources the build environment and runs *bitbake*, and it
releases the images of the build:

```ini
[project]
org='yocto'
name='scarthgap'

[build]
shell=bash
command='. oe-init-build-env && bitbake core-image-minimal'
files='build/tmp/deploy/images/*/core-image-minimal-*.rootfs.*'
```

Then, build the image, and archive it:

```console
$ cqfd6 --release
```

## Build with Buildroot

Buildroot ships its own Dockerfile. Write a `.cqfdrc` at the root of the
Buildroot directory using it:

```ini
[project]
org='buildroot'
name='qemu'

[build]
dockerfile='support/docker/Dockerfile'
command='make qemu_x86_64_defconfig all'
```

Then, run the build:

```console
$ cqfd6
```

<a class="btn btn--primary" href="https://github.com/gportay/cqfd6/tree/master/samples">Browse the samples</a>
