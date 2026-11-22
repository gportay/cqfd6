---
title: "Frequently Asked Questions"
permalink: /faq/
excerpt: "Answers to the common questions about cqfd6."
---

## What does cqfd6 <mark>do exactly</mark>?

In short, cqfd6 does:

```console
$ docker run --rm [--tty] [--interactive] "--volume=$PWD:$PWD" "--workdir=$PWD" IMAGE sh -c "COMMAND"
```

... with a little more magic! It builds `IMAGE` from your `Dockerfile` when
needed, adds your user and groups in the container, and runs `COMMAND` as you.
See the [getting started] page.

## What is the difference between <mark>cqfd and cqfd6</mark>?

cqfd6 is a fork of cqfd fixing several broken things in the upstream project:
the hazardous .ini parser, the missing cleaning commands, the inconsistent
pulling behaviour, the image naming, the ambiguous `run` command and
`custom_img_name` property... It deprecates the former command line interface
in favor of a much simpler and more common one, similar to the one of `sudo`:

```console
$ cqfd6 make clean
```

## Which <mark>container engines</mark> does cqfd6 support?

cqfd6 works with any Docker Engine, and, with limited functionality, with
[Podman]. Tell cqfd6 to run Podman in your `~/.profile`:

```bash
export CQFD_DOCKER="podman"
export PODMAN_USERNS="keep-id"
```

See the [compatibility] page.

## Which <mark>operating systems</mark> does cqfd6 run on?

cqfd6 runs on Linux and on Windows with WSL. cqfd6 is a bash script; it
requires bash and Docker on the host. See the [download page].

## Where does cqfd6 look for the <mark>Dockerfile</mark>?

cqfd6 looks for the `.cqfdrc` file in the working directory and its parents;
its directory is the project directory. It reads the `Dockerfile` from the
subdirectory `docker/` of the project directory. Select another `Dockerfile`
with the property `dockerfile` in the `[build]` section, or use an image from a
registry with the property `image` in the `[project]` section.

The former `.cqfd` directory is deprecated: move its content to the project
directory.

## Who <mark>owns the files</mark> created in the container?

You do. cqfd6 runs the commands as your user, with your user ID and groups, so
the files created in your project directory belong to you, as if you had
created them on the host.

## Does cqfd6 <mark>rebuild</mark> the image every time?

No. cqfd6 tags the image with the hash of the `Dockerfile`, and it builds the
image only if it does not exist yet, or if the `Dockerfile` changes. Use the
command `--init` to build the image anyway, or the option `--reinit` to build
it again before running the command.

## How do I <mark>clean up</mark> the cqfd6 images?

List the images with the command `--ls`, remove the image of the current
`Dockerfile` with the command `--deinit`, and remove the unused images with the
command `--gc`.

## How do I build <mark>variants</mark> of my project?

Use the build flavors: add a section per flavor in the `.cqfdrc` file, with its
own `command`, `files` or `dockerfile`, and select it with the option
`--build`:

```console
$ cqfd6 --build debug
```

List the flavors with the command `--flavors`.

## How do I <mark>release</mark> my project?

List the files to release with the property `files` in the `[build]` section,
and use the option `--release`: cqfd6 runs the build, and archives the files
in a tarball named after the property `archive`.

## Do I need to be <mark>root</mark> to run cqfd6?

No. cqfd6 relies on the setup of Docker; see how to run Docker as a
[non-root user]. If you are not a member of the `docker` group, do not run
cqfd6 with `sudo`; set the variable `CQFD_RUN_WITH_SUDO` to `true` instead, it
only runs the `docker` commands with superuser privileges.

## Can cqfd6 build for <mark>another architecture</mark>?

Yes. Use the option `--platform`, for example `--platform linux/arm64`, to
build and run [multi-platform] images. See the [multi-architecture] page.

## How do I see <mark>what cqfd6 runs</mark>?

Use the option `--verbose` to increase the verbosity of cqfd6.

## What does <mark>CQFD</mark> stand for?

CQFD stands for "ce qu'il fallait Dockeriser", French for "what needed to be
Dockerized". SIX stands for *Sudo Interface eXperimentation*.

## Where can I get <mark>help</mark>?

Visit the [support page].

[getting started]: {{ "/getting-started/" | relative_url }}
[compatibility]: {{ "/compatibility/" | relative_url }}
[download page]: {{ "/download/" | relative_url }}
[multi-architecture]: {{ "/multi-architecture/" | relative_url }}
[support page]: {{ "/support/" | relative_url }}
[Podman]: https://podman.io/
[non-root user]: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
[multi-platform]: https://docs.docker.com/build/building/multi-platform/
