---
title: "Getting Started"
permalink: /getting-started/
excerpt: "Run your first command with cqfd6, the way cqfd6 builds itself."
---

cqfd6 is its own first user: the project uses cqfd6 to build its man pages,
its packages, and this website. This page walks you through these examples.

## <mark>Install</mark> cqfd6

Follow the [download page] to install cqfd6 and [Docker].

```console
$ cqfd6 --version
```

## Write a <mark>Dockerfile</mark>

cqfd6 reads the `Dockerfile` from the subdirectory `docker/` of your project
directory. Describe the tools your project needs, as you would set up a
development machine. For example, to build the cqfd6 man pages:

```console
$ mkdir docker
$ echo "FROM ubuntu" >docker/Dockerfile
$ echo "RUN apt-get update && apt-get install -y asciidoctor make" >>docker/Dockerfile
```

## Write a <mark>.cqfdrc</mark> file

The `.cqfdrc` file at the root of your project names the project, and sets the
default build command, in an .ini-like format:

```ini
[project]
org='gportay'
name='cqfd6'

[build]
command='make man'
```

## Run the <mark>build</mark>

Run `cqfd6` alone to run the default build command in the build container:

```console
$ cqfd6
#0 building with "default" instance using docker driver
...
$ man ./cqfd.1.gz
```

cqfd6 builds the image the first time, and reuses it until the `Dockerfile`
changes. The command runs as you, in a fresh container, and the files
`cqfd.1.gz` and `cqfdrc.5.gz` land in your project directory.

## Run a <mark>command</mark>

Give cqfd6 a command, as you would with `sudo`, to run it in the build
container instead:

```console
$ cqfd6 make clean
```

Use `sh -c` for commands composed with shell grammar:

```console
$ cqfd6 sh -c "make clean && make man"
```

Or, run a shell to work interactively in the build container:

```console
$ cqfd6 bash
```

## Use one <mark>flavor</mark> per task

A project often needs several environments. Add a section per flavor in the
`.cqfdrc` file, each with its own `Dockerfile` and command, and select it with
the option `--build`. The cqfd6 sources keep one flavor per task:

| Section  | Dockerfile                 | Builds                 |
| -------- | -------------------------- | ---------------------- |
| `build`  | `.cqfd/docker/Dockerfile`  | the man pages, default |
| `deb`    | `.cqfd/deb/Dockerfile`     | the Debian package     |
| `rpm`    | `.cqfd/rpm/Dockerfile`     | the RPM package        |
| `pkg`    | `.cqfd/pkg/Dockerfile`     | the Arch Linux package |
| `serve`  | `.cqfd/jekyll/Dockerfile`  | this website           |

For example, the flavor of this website publishes the ports of Jekyll and its
live reload:

```ini
[serve]
dockerfile='.cqfd/jekyll/Dockerfile'
docker_run_args='--publish 4000:4000 --publish 35729:35729'
command='cd docs/gh-pages && bundle exec jekyll serve --host 0.0.0.0 --livereload --destination /tmp/_site'
```

Then, serve the website:

```console
$ cqfd6 --build serve
```

List the flavors with the command `--flavors`.

## <mark>Release</mark> your project

List the files to release in the `.cqfdrc` file:

```ini
[build]
command='make man'
files='AUTHORS CHANGELOG.md LICENSE README.md cqfd cqfd.1.gz cqfdrc.5.gz'
```

Then, build the project, and archive the files in a tarball named after the
organization and the project, `gportay-cqfd6.tar.xz`:

```console
$ cqfd6 --release
```

Set the property `archive` to name the tarball differently, for example with
the git hash of the release, `%Gh`.

## Use cqfd6 from a <mark>Makefile</mark>

Set cqfd6 as the `SHELL` of `make`, and the recipes run in the build
container:

```console
$ make SHELL="cqfd6 sh"
```

Or, run cqfd6 from a recipe. The cqfd6 `Makefile` serves this website this
way:

```make
.PHONY: serve
serve:
	cqfd6 --build serve
```

Then, `make man` and `make serve` need nothing else than cqfd6 and Docker on
your machine.

## Use cqfd6 as a <mark>shebang</mark>

cqfd6 is also an interpreter for shell scripts: start a script with
`#!/usr/bin/env -S cqfd6 sh`, and it runs in the build container. Pass the
cqfd6 options with the split option `-S` of `env`. The cqfd6 sources build
the Arch Linux package with `make-pkg.sh`:

```bash
#!/usr/bin/env -S cqfd6 --build pkg --yes /bin/bash
set -e
makepkg --force --skipchecksums "$@"
shellcheck --shell=bash --exclude=SC2034,SC2154,SC2164 PKGBUILD
namcap PKGBUILD* *.pkg.tar*
```

Make the script executable, and run it as any other script:

```console
$ chmod +x make-pkg.sh
$ ./make-pkg.sh
```

## Share your host settings with the <mark>container</mark>

cqfd6 brings your host settings into the build container, so the build can,
for example, pull authenticated git repositories:

| Setting             | Disabled with                                |
| ------------------- | -------------------------------------------- |
| `~/.ssh`            | `CQFD_NO_USER_SSH_CONFIG=true`               |
| `/etc/ssh`          | `CQFD_NO_SSH_CONFIG=true`                    |
| the SSH agent       | `CQFD_NO_SSH_AUTH_SOCK=true`                 |
| `~/.gitconfig`      | `CQFD_NO_USER_GIT_CONFIG=true`               |
| `/etc/gitconfig`    | `CQFD_NO_SYSTEM_GIT_CONFIG=true`             |

Pass extra options to `docker run` with the property `docker_run_args`, or
with the variable `CQFD_EXTRA_RUN_ARGS`.

## Go <mark>further</mark>

Read the [documentation] and the man pages, [cqfd6(1)] and [cqfdrc6(5)], to
learn about the commands, the options and the properties. Have a question?
Visit the [support page].

[download page]: {{ "/download/" | relative_url }}
[support page]: {{ "/support/" | relative_url }}
[Docker]: https://docs.docker.com/engine/install/
[documentation]: https://github.com/gportay/cqfd6#readme
[cqfd6(1)]: https://github.com/gportay/cqfd6/blob/master/cqfd.1.adoc
[cqfdrc6(5)]: https://github.com/gportay/cqfd6/blob/master/cqfdrc.5.adoc
