---
title: "Package for multiple architectures"
permalink: /multi-architecture/
excerpt: "Build and run your project for different target architectures using multi-platform container images and emulation."
---

cqfd6 builds and runs images for another platform if the option `--platform`
is set to a target different from the host platform (`linux/amd64`,
`linux/arm64`...).

```console
$ cqfd6 uname -m
x86_64

$ cqfd6 --platform linux/arm64 uname -m
aarch64
```

Running images for a foreign platform requires emulation on the host, thanks
to QEMU and binfmt, as described in the Docker [multi-platform] documentation.

## Set the platform

Alternatively, set the platform with the environment variable `CQFD_PLATFORM`:

```console
$ export CQFD_PLATFORM="linux/arm64"
$ cqfd6 uname -m
aarch64
```

Or, per flavor, with the property `platform` of the `.cqfdrc` file:

```ini
[project]
org='fooinc'
name='multi-platform'

[arm64]
platform='linux/arm64'

[build]
command='make'
```

```console
$ cqfd6 --build arm64 uname -m
aarch64
```

Or, in the `Dockerfile` itself:

```dockerfile
FROM --platform=linux/arm64 ubuntu:24.04
```

## Platform helper scripts

Alternatively, use the specific platform helper scripts to run cqfd6 using the
platform prefixed in the executable filename: `linux-amd64-cqfd6`,
`linux-arm64-cqfd6`, `linux-arm-cqfd6`, `linux-ppc64le-cqfd6`,
`linux-riscv64-cqfd6` and `linux-s390x-cqfd6`.

```console
$ linux-arm64-cqfd6 uname -m
aarch64
```

## Build packages for another architecture

Combine a flavor building a package with another platform to build the package
for that architecture. For example, to build a Debian package for `arm64`:

```ini
[deb]
dockerfile='docker/deb/Dockerfile'
docker_run_args="--volume $HOME:$HOME"
command='dpkg-buildpackage -us -uc'
```

*dpkg-buildpackage* writes the package in the parent directory: the property
`docker_run_args` mounts your home directory in the build container to keep it.

```console
$ linux-arm64-cqfd6 --build deb
```

[multi-platform]: https://docs.docker.com/build/building/multi-platform/

<a class="btn btn--primary" href="https://github.com/gportay/cqfd6#multi-platform">Read the documentation</a>
