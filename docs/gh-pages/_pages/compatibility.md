---
title: "Run it with any Docker Engine"
permalink: /compatibility/
excerpt: "cqfd6 works with any Docker Engine, and with Podman. It runs on Linux and on Windows with WSL."
---

cqfd6 is a bash script running the `docker` command line. It works with any
engine providing that command line, including Docker Engine, Docker Desktop
and, with limited functionality, Podman.

## Use Podman

[Podman] is a daemonless alternative to Docker providing the same command line
interface. cqfd6 can use it instead of Docker, with limited functionality, for
example when dealing with extra groups.

Add the following lines to the shell `~/.profile` to tell cqfd6 to run
`podman` instead of `docker`, and to map your user in the rootless containers:

```sh
export CQFD_DOCKER="podman"
export PODMAN_USERNS="keep-id"
```

Or, set the program per project with the property `docker` in the `[build]`
section of the `.cqfdrc` file.

## Use it as a Docker CLI plugin

cqfd6 installs the Docker CLI plugin `docker-cqfd`: run it as a subcommand of
`docker`.

```console
$ docker cqfd make
```

## Use WSL

On Windows, install cqfd6 in a Linux distribution running in [WSL]. Use it with
a Docker Engine or Podman installed in that distribution, or with Docker
Desktop and its WSL integration enabled.

## Run without the docker group

cqfd6 relies on the setup of Docker. If you are not a member of the `docker`
group, set the variable `CQFD_RUN_WITH_SUDO` to `true`: it only runs the
`docker` commands with superuser privileges.

```console
$ CQFD_RUN_WITH_SUDO=true cqfd6
```

[Podman]: https://github.com/containers/podman
[WSL]: https://learn.microsoft.com/windows/wsl/

<a class="btn btn--primary" href="https://github.com/gportay/cqfd6#using-podman">Read the documentation</a>
