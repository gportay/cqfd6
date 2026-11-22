---
title: "Compile for another distribution"
permalink: /other-distributions/
excerpt: "Compile your application with the toolchain and the libraries of the distribution it targets, without installing that distribution."
---

An application compiled on your machine links against the libraries of your
distribution; it may not run on an older release, or on another distribution.
Compile it in a build container of the target distribution instead, and keep
working from your machine.

## Describe the target distribution

Write a `Dockerfile` per target distribution, with its toolchain and the
development packages of your application. For example, to target Ubuntu 22.04:

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y build-essential
```

Save it as `docker/ubuntu-22.04/Dockerfile`, and add a flavor using it to the
`.cqfdrc` file:

```ini
[ubuntu-22.04]
dockerfile='docker/ubuntu-22.04/Dockerfile'

[build]
command='make'
files='myprogram'
```

## Compile the application

Run the build in the target distribution, from your source tree:

```console
$ cqfd6 --build ubuntu-22.04
```

The build runs as you, so the binaries land in your project directory, owned
by you, ready to ship. Add a flavor per release or distribution to target, and
compile for each of them the same way.

## Ready-to-use samples

cqfd6 comes with samples installed under `/usr/share/cqfd6/samples/`, such as
`Dockerfile.Ubuntu:24.04` for Ubuntu 24.04. Use them as a starting point:

```console
$ mkdir -p docker/ubuntu-24.04
$ cp /usr/share/cqfd6/samples/Dockerfile.Ubuntu:24.04 docker/ubuntu-24.04/Dockerfile
```

Combine the target distribution with the option `--platform` to target another
architecture too. See [Package for multiple architectures].

[Package for multiple architectures]: {{ "/multi-architecture/" | relative_url }}
