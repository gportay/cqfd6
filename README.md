![cqfd logo](./doc/cqfd6_logo.png?raw=true)

# What are cqfd and cqfd6 ?

cqfd provides a quick and convenient way to run commands in the current
directory, but within a Docker container defined in a per-project config file.

This becomes useful when building an application designed for another Linux
system, e.g. building an old embedded firmware that only works in an older
Linux distribution.

cqfd uses containers and introduced the concept of build containers to define a
container specifically configured with all the software required to build the
project. Simply install the necessary packages in the container file, and cqfd
makes you feel at home by adding your user and mounting your project workspace
into the build container. In short, cqfd makes it easy to build the image and
execute commands in a fresh container, with only a few lightweight, per-project
static configuration files. As the cherry on top, cqfd can also build the
project for different architectures thanks to multi-platform images and
emulation.

cqfd6 is a fork of cqfd fixing several broken things in the upstream project
(hazardous .ini parser, no cleaning commands, inconsistant pulling behaviour,
image naming, ambiguous `run` command and `custom_img_name` property...). It
deprecates the former CLI to modernize it to something much simpler and much
more common such as the CLI of `sudo`.

# Using cqfd

## Getting started

Just follow these steps:

* [Install requirements](#requirements)
* [Install cqfd](#installingremoving-cqfd6)
* Go into your project's directory
* Create a [.cqfdrc](cqfdrc.5.adoc) file
* Create a [Dockerfile](https://docs.docker.com/reference/dockerfile/) and save
  it as `.cqfd/docker/Dockerfile`

The project uses itself to build the documentation or release packages. The
in-tree files [.cqfdrc](.cqfdrc), the [.cqfd](.cqfd) directory, and the three
cqfd shell scripts — [make-deb.sh](make-deb.sh), [make-pkg.sh](make-pkg.sh),
and [make-rpm.sh](make-rpm.sh) — provide good examples of how to set up a
project and add custom scripting. Additional examples can be found in the
[samples](samples) directory.

`cqfd` will use the provided `Dockerfile` to create a normalized runtime build
environment for your project.

## Using cqfd on a daily basis

### Regular builds

To build your project from the configured build environment with the default
build command as configured in `.cqfdrc`, use:

    $ cqfd

Alternatively, you may want to specify a single custom command to be executed
from inside the build container.

    $ cqfd make clean

Or custom commands composed with shell grammar:

    $ cqfd sh -c "make linux-dirclean && make foobar-dirclean"

Or run a shell script with arguments:

    $ cqfd sh ./build.sh debug

When `cqfd` is running, the current directory is mounted by Docker as a volume.
As a result, all the build artefacts generated inside the build container are
still accessible in this directory after the build container has been stopped
and removed.

### Release

The `--release` option creates a release tarball for your project. The release
files (as specified in your `.cqfdrc`) will be included inside the release
archive.

    $ cqfd --release

The resulting release file is then called according to the archive template,
which defaults to `%Po-%Pn.tar.xz`.

### Flavors

Flavors are used to create alternate build scenarios. For example, to use
another build container or another build command.

## The .cqfdrc file

The `.cqfdrc` file at the root of your project contains the information
required to support project tooling. It is written in an .ini-like format and
`samples/dot-cqfdrc` is an example.

Here is a sample `.cqfdrc` file:

    [project]
    org='fooinc'
    name='buildroot'

    [build]
    command='make foobar_defconfig && make && asciidoc README.FOOINC'
    files='README.FOOINC output/images/sdcard.img'
    archive='cqfd-%Gh.tar.xz'

### Comments

The `.cqfdrc` file supports Unix shell and .ini comments: words after the
character `#` or `;` are ignored to the end of the line.

### Using build flavors

In some cases, it may be desirable to build the project using variations of the
build and release methods (for example a debug build). This is made possible in
`cqfd` with the build flavors feature.

In the `.cqfdrc` file, one or more flavors may be listed in the `[build]`
section, referencing other sections named following flavor's name.

    [centos7]
    command='make CENTOS=1'
    distro='centos7'

    [debug]
    command='make DEBUG=1'
    files='myprogram Symbols.map'

    [build]
    command='make'
    files='myprogram'

A flavor will typically redefine some keys of the build section: `command`,
`files`, `archive`, `distro`.

### Manual page

For a more thorough description of the `.cqfdrc` configuration file, please
refer to [cqfdrc(5)](cqfdrc.5.adoc).

## Using cqfd in an advanced way

### Running a shell in the build container

You can pop an interactive shell in your build container.

Example:

    fred@host:~/project$ cqfd bash
    fred@container:~/project$

### Use cqfd as an interpreter for shell script

You can write a shell script and run it in your build container.

Example:

    fred@host:~/project$ cat get-container-pretty-name.sh
    #!/usr/bin/env -S cqfd sh
    if ! test -e /.dockerenv; then
        exit 1
    fi
    source /etc/os-release
    echo "$PRETTY_NAME"
    fred@host:~/projet$ ./get-container-pretty-name.sh
    Debian GNU/Linux 13 (trixie)

### Use cqfd as a standard shell for binaries

You can even use `cqfd` as a standard `$SHELL` so binaries honoring that
variable run shell commands in your build container.

Example:

    fred@host:~/project$ make SHELL="cqfd sh"
    Available make targets:
       help:      This help message
       install:   Install script, doc and resources
       uninstall: Remove script, doc and resources
       tests:     Run functional tests

### Manual page

For a more thorough description of the `cqfd` commands, options, and
environment variables, please refers to [cqfd(1)](cqfd.1.adoc).

## Multi-platform

Docker supports multi-platform images; such images can run on multiple
platforms (`amd64`, `arm64`, etc.). Therefore, `cqfd` takes advantage of this
to build and run containers for different architectures thanks to QEMU and
binfmt on Linux.

Example:

Specify the desired platform in the `Dockerfile`, as shown below:

    FROM --platform=linux/arm64 ubuntu:24.04
    (...)

Test the build container:

    $ cqfd uname -m
    aarch64

Additionally, `cqfd` supports the option `--platform TARGET`, the environment
variable `CQFD_PLATFORM`, and the build property `platform=` to set the desired
platform dynamically.

Examples:

    $ cqfd --platform linux/arm64 uname -m
    aarch64

    $ export CQFD_PLATFORM="linux/arm64"
    $ cqfd uname -m
    aarch64

    $ cat .cqfdrc
    [project]
    org='fooinc'
    name='multi-platform'

    [arm64]
    platform='linux/arm64'

    [build]
    command='uname -a'
    $ cqfd uname -m
    x86_64
    $ cqfd --build arm64 uname -m
    aarch64

## Key files and directories

cqfd project uses three key files and directories.

The `.cqfd` directory contains the `Dockerfile`s, organized in a specific
hierarchy. Each build container file is located and accessed according to the
`distro` build property: `.cqfd/$distro/Dockerfile`. This `.cqfd` directory is
controlled by the `-d` option or the `CQFD_DIR` environment variable.

The `.cqfd` directory mainly serves to locate the root of the cqfd project. The
root directory is the parent of the `.cqfd` directory, and it is referred to as
the *project* or *working* directory. This directory is bind-mounted into the
build container and is controlled by the `-w` option or the `CQFD_WORKDIR`
environment variable.

The `.cqfdrc` file defines the cqfd project information and the build command.
It is controlled by the `-f` option or the `CQFDRC_FILE` environment variable.

All these files and directories are interpreted relative to the current working
directory if specified with a relative path. Additionally, the `--directory`
option changes the working directory, meaning that these files and directories
are then relative to the new working directory.

In some cases, you may want to use alternate cqfd filenames and/or an external
directory. The following options allow you to control cqfd configuration files:

To change the current working directory, use the `--directory` option:

    $ cqfd --directory external/directory

To specify an alternate cqfd directory, use the `--cqfd-directory` option:

    $ cqfd --cqfd-directory cqfd_alt

To specify an alternate cqfdrc file, use the `--cqfdrc-file` option:

    $ cqfd --cqfdrc-file cqfdrc_alt

To specify an alternate working directory, use the `--working-directory`
option:

    $ cqfd --working-directory ..

These options can be combined, for example to use out-of-tree cqfd files if
these files cannot be committed to the project.

Example:

    ~/src$ tree out-of-tree-cqfd-files/
    out-of-tree-cqfd-files/
    ├── cqfd
    │   └── docker
    │       └── Dockerfile
    └── cqfdrc

    3 directories, 2 files
    ~/src$ cd buildroot
    ~/src/buildroot$ cqfd --working-directory . --cqfd-directory ../out-of-tree-cqfd-files/cqfd --cqfdrc-file ../out-of-tree-cqfd-files/cqfdrc
    # or sourcing environment from a file
    ~/src/buildroot$ cat environment
    export CQFD_WORKDIR=.
    export CQFD_DIR=../out-of-tree-cqfd-files/cqfd
    export CQFDRC_FILE=../out-of-tree-cqfd-files/cqfdrc
    ~/src/buildroot$ source environment
    ~/src/buildroot$ cqfd
    (...)

## Build Container Environment

When `cqfd` runs, a build container is launched as the environment in which to
run the `command`.  Within this environment, commands are run as the same user
as the one invoking `cqfd` (with a fallback to the 'builder' user in case it
cannot be determined). So that this user has access to local files, the current
working directory is mapped to the same location inside the build container.

### SSH Handling

The local `~/.ssh` directory is also mapped to the corresponding directory in
the build container. This effectively enables SSH agent forwarding so a build
can, for example, pull authenticated git repositories.

### Terminal job control

When `cqfd` runs a command as the unprivileged user that called it in the first
place, `su(1)` is used to run the command. This brings a limitation for
processes that require a controlling terminal (such as an interactive shell),
as `su` will prevent the command executed from having one on very old version
os `su` ([see][0b69ccba9000b9298c8f0b39416884c697b50a38]).

```
$ cqfd bash
bash: cannot set terminal process group (-1): Inappropriate ioctl for device
bash: no job control in this shell
```

To work around this limitation, `cqfd` will use `sudo(8)` when it is available
in the build container instead. The user is responsible for including it in the
related `Dockerfile`.

## Remove images

Running `cqfd` creates and names a new Docker image each time the `Dockerfile`
is modified, which may lead to a large number of unused images that are not
automatically purged.

To remove the image associated with the current version of the `Dockerfile`,
use:

    $ cqfd --deinit

If a flavor redefines the distro key of the build section, use:

    $ cqfd --build centos7 --deinit

To list all created images, use:

    $ cqfd --ls

To collect all unused images across all user projects on the system, use:

    $ cqfd --gc

## Requirements

To use `cqfd`, ensure the following requirements are satisfied on your
workstation:

-  Bash
-  Docker

## Installing/removing cqfd6

### From packages

#### Arch Linux or Manjaro

First download the package:

    $ curl https://github.com/gportay/cqfd6/releases/download/v6/cqfd6-6-1-any.pkg.tar.zst

Then, install it using the package manager:

    $ sudo pacman -U ./cqfd6-6-1-any.pkg.tar.zst

_Note_: Uninstall it using the package manager:

    $ sudo pacman -R cqfd6

#### Debian or Ubuntu

First download the package:

    $ curl https://github.com/gportay/cqfd6/releases/download/v6/cqfd6_6_all.deb

Then, install it using the package manager:

    $ sudo dpkg -i ./cqfd6_6_all.deb

_Note_: Uninstall it using the package manager:

    $ sudo dpkg -r cqfd6

#### RedHat Linux or Fedora

First download the package:

    $ curl https://github.com/gportay/cqfd6/releases/download/v6/cqfd6-6-1.noarch.rpm

Then, install it using the package manager:

    $ sudo dnf install ./cqfd6-6-1.noarch.rpm

_Note_: Uninstall it using the package manager:

    $ sudo dnf remove cqfd6

### From source

First clone this repository:

    $ git clone https://github.com/gportay/cqfd6.git

Then, install the script and its resources:

    $ make install

Finally, uninstall the script and its resources:

    $ make uninstall

Makefile honors both **PREFIX** (__/usr/local__) and **DESTDIR** (__[empty]__)
variables:

    $ make install PREFIX=/opt
    $ make install PREFIX=/usr DESTDIR=package

### Arch Linux or Manjaro

If you use an Arch Linux derivative distribution based on pacman package
manager, you can build the latest released version of the `cqfd6` package via:

```sh
makepkg
```

Or, the current unreleased version of the `cqfd6-git` package via:

```sh
makepkg -f PKGBUILD-git
```

_Note_: The artefacts are available in the current directory.

### Debian or Ubuntu

If you use an Debian derivative distribution based on the dpkg package manager,
you can build the latest released version of the `cqfd6` package via:

```sh
dpkg-buildpackage -us -uc
```

_Note_: The artefacts are available in the parent directory.

### RedHat Linux or Fedora

If you use a RPM based distribution, you can build the latest released version
of the `cqfd6` package via:

```sh
rpmdev-setuptree
cp cqfd6.spec ~/rpmbuild/SPECS/
cd ~/rpmbuild/SPECS
rpmbuild --undefine=_disable_source_fetch --define='_dockerlibdir %{_exec_prefix}/lib/docker' -ba cqfd6.spec "$@"
cp ~/rpmbuild/SRPMS/*.src.rpm ~/rpmbuild/RPMS/*/*.rpm "$OLDPWD"
```

_Note_: The artefacts are available in `~/rpmbuild/RPMS` and `~/rpmbuild/SRPMS`
directories.

## Using podman

Podman may be used instead of Docker, but with limited functionalities, for
example when dealing with extra groups.

To use `podman` instead of `docker`, you can set in your environment, like your
`.profile`, `.bashrc` or `.zshrc`:

```bash
export CQFD_DOCKER="podman"
export PODMAN_USERNS="keep-id"
```

## Testing cqfd (for developers)

The codebase contains tests which can be invoked using the following command,
if the above requirements are met on the system:

    $ make tests

## Patches

Submit patches at *https://github.com/gportay/cqfd6/pulls*

## Bugs

Report bugs at *https://github.com/gportay/cqfd6/issues*

## Trivia

CQFD stands for "ce qu'il fallait Dockeriser", French for "what needed
to be Dockerized".

SIX stands for *Sudo Interface eXperimentation*.

[0b69ccba9000b9298c8f0b39416884c697b50a38]: https://github.com/gportay/cqfd6/commit/0b69ccba9000b9298c8f0b39416884c697b50a38
