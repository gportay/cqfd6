![cqfd logo](./doc/cqfd6_logo.png?raw=true)

# What are cqfd and cqfd6 ?

cqfd provides a quick and convenient way to run commands in the current
directory, but within a Docker container defined in a per-project config
file.

This becomes useful when building an application designed for another
Linux system, e.g. building an old embedded firmware that only works
in an older Linux distribution.

cqfd uses containers and introduced the concept of build containers to define a
container specifically configured with all the software required to build the
project. Simply install the necessary packages in the container file, and cqfd
makes you feel at home by adding your user and mounting your project workspace
into the build container. In short, cqfd makes it easy to build the image and
execute commands in a fresh container, with only a few lightweight, per-project
static configuration files. As the cherry on top, cqfd can also build the
project for different architectures thanks to multi-platform images and
emulation.

cqfd6 is a fork of cqfd fixing several broken things in the upstream project.
It depreciates the former CLI to modernize it to something much more simple and
much more common such as the CLI of `sudo`. Moreover, the project need a new
name, remembering its roots. Meanwhile, cqfd6 is for *CQFD Sudo Interface
eXperimentation*.

# Using cqfd

## Getting started

Just follow these steps:

* [Install cqfd](#installingremoving-cqfd6)
* Go into your project's directory
* Create a `.cqfdrc` file
* Create a Dockerfile and save it as `.cqfd/docker/Dockerfile`
* Run `cqfd --init`

Examples are available in the `samples/` directory.

`cqfd` will use the provided `Dockerfile` to create a normalized runtime
build environment for your project.

## Using cqfd on a daily basis

### Regular builds

To build your project from the configured build environment with the
default build command as configured in `.cqfdrc`, use:

    $ cqfd

Alternatively, you may want to specify a single custom command to be
executed from inside the build container.

    $ cqfd --exec make clean

Or custom commands composed with shell grammar:

    $ cqfd --shell -c "make linux-dirclean && make foobar-dirclean"

Or run a shell script with arguments:

    $ cqfd --shell ./build.sh debug

When `cqfd` is running, the current directory is mounted by Docker
as a volume. As a result, all the build artefacts generated inside the
build container are still accessible in this directory after the build container
has been stopped and removed.

### Release

The `--release` option creates a release tarball for your project. The release
files (as specified in your `.cqfdrc`) will be included inside the release
archive.

    $ cqfd --release

The resulting release file is then called according to the archive
template, which defaults to `%Po-%Pn.tar.xz`.

### Flavors

Flavors are used to create alternate build scenarios. For example, to
use another build container or another build command.

## The .cqfdrc file

The `.cqfdrc` file at the root of your project contains the information
required to support project tooling. It is written in an .ini-like
format and `samples/dot-cqfdrc` is an example.

Here is a sample `.cqfdrc` file:

    [project]
    org='fooinc'
    name='buildroot'

    [build]
    command='make foobar_defconfig && make && asciidoc README.FOOINC'
    files='README.FOOINC output/images/sdcard.img'
    archive='cqfd-%Gh.tar.xz'

### Comments

The `.cqfdrc` file supports Unix shell comments; the words after the character `#`
are ignored up to the end of line. A comment cannot be set in the first line,
and right after a section.

### Using build flavors

In some cases, it may be desirable to build the project using
variations of the build and release methods (for example a debug
build). This is made possible in `cqfd` with the build flavors feature.

In the `.cqfdrc` file, one or more flavors may be listed in the
`[build]` section, referencing other sections named following
flavor's name.

    [centos7]
    command='make CENTOS=1'
    distro='centos7'

    [debug]
    command='make DEBUG=1'
    files='myprogram Symbols.map'

    [build]
    command='make'
    files='myprogram'

A flavor will typically redefine some keys of the build section:
command, files, archive, distro.

Flavors from a `.cqfdrc` file can be listed using the `flavors` argument.

### Manual page

For a more thorough description of the `.cqfdrc` configuration file, please
refers to [cqfdrc(5)](cqfdrc.5.adoc).

### Appending to the build command

The `-c` option sets immediately after the command `--run` allows appending the
command of a `cqfd --run` for temporary developments:

    $ cqfd --build centos7 --run -c "clean"
    $ cqfd --build centos7 --run -c "TRACING=1"

### Running a shell in the build container

You can use the `shell` command to quickly pop a shell in your build
container. The shell to be launched (default `/bin/sh`) can be customized using
the `CQFD_SHELL` environment variable.

Example:

    fred@host:~/project$ cqfd --shell
    fred@container:~/project$

### Use cqfd as an interpreter for shell script

You can use the `--shell` command to write a shell script and run it in your
build container.

Example:

    fred@host:~/project$ cat get-container-pretty-name.sh
    #!/usr/bin/env -S cqfd --shell
    if ! test -e /.dockerenv; then
        exit 1
    fi
    source /etc/os-release
    echo "$PRETTY_NAME"
    fred@host:~/projet$ ./get-container-pretty-name.sh
    Debian GNU/Linux 12 (bookworm)

### Use cqfd as a standard shell for binaries

You can even use the `--shell` command to use it as a standard `$SHELL` so
binaries honoring that variable run shell commands in your build container.

Example:

    fred@host:~/project$ make SHELL="cqfd --shell"
    Available make targets:
       help:      This help message
       install:   Install script, doc and resources
       uninstall: Remove script, doc and resources
       tests:     Run functional tests

### Manual page

For a more thorough description of the `cqfd` commands, options, and
environment variables, please refers to [cqfd(1)](cqfd.1.adoc).

### Multi-platform

Docker supports multi-platform images; such images can run on multiple
platforms (`amd64`, `arm64`, etc.). Therefore, `cqfd` takes advantage of this
to build and run containers for different architectures thanks to QEMU and
binfmt on Linux.

Example:

First, specify the desired platform in the `Dockerfile`, as shown below:

    FROM --platform=linux/arm64 ubuntu:24.04
    (...)

Then, initialize the image:

    $ cqfd --init

Finally, test the build container:

    $ cqfd --exec uname -m
    aarch64

Additionally, `cqfd` supports the option `--platform TARGET`, the environment
variable `CQFD_PLATFORM`, and the build property `platform=` to set the desired
platform dynamically.

Examples:

    $ cqfd --platform linux/arm64 --init
    $ cqfd --platform linux/arm64 --exec uname -m
    aarch64

    $ export CQFD_PLATFORM="linux/arm64"
    $ cqfd --init
    $ cqfd --exec uname -m
    aarch64

    $ cat .cqfdrc
    [project]
    org='fooinc'
    name='multi-platform'

    [arm64]
    platform='linux/arm64'

    [build]
    command='uname -a'
    $ cqfd --init
    $ cqfd --exec uname -m
    x86_64
    $ cqfd --build arm64 --exec uname -m
    aarch64

### Key files and directories

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

To specify an alternate working directory, use the `--working-directory` option:

    $ cqfd --working-directory ..

These options can be combined, for example to use out-of-tree cqfd files if
these files cannot be commit to the project.

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
    # or sourcing enviroment from a file
    ~/src/buildroot$ cat environment
    export CQFD_WORKDIR=.
    export CQFD_DIR=../out-of-tree-cqfd-files/cqfd
    export CQFDRC_FILE=../out-of-tree-cqfd-files/cqfdrc
    ~/src/buildroot$ source environment
    ~/src/buildroot$ cqfd
    (...)

## Build Container Environment

When `cqfd` runs, a build container is launched as the environment in
which to run the `command`.  Within this environment, commands are run
as the same user as the one invoking `cqfd` (with a fallback to the
'builder' user in case it cannot be determined). So that this user has
access to local files, the current working directory is mapped to
the same location inside the build container.

### SSH Handling

The local `~/.ssh` directory is also mapped to the corresponding
directory in the build container. This effectively enables SSH agent
forwarding so a build can, for example, pull authenticated git repos.

### Terminal job control

When `cqfd` runs a command as the unprivileged user that called it in
the first place, `su(1)` is used to run the command. This brings a
limitation for processes that require a controlling terminal (such as
an interactive shell), as `su` will prevent the command executed
from having one.

```
$ cqfd bash
bash: cannot set terminal process group (-1): Inappropriate ioctl for device
bash: no job control in this shell
```

To work around this limitation, `cqfd` will use `sudo(8)` when it is
available in the build container instead. The user is responsible for
including it in the related `Dockerfile`.

## Remove images

Running `cqfd --init` creates and names a new Docker image each
time the `Dockerfile` is modified, which may lead to a large number of
unused images that are not automatically purged.

To remove the image associated with the current version of the `Dockerfile`,
use:

    $ cqfd --deinit

If a flavor redefines the distro key of the build section, use:

    $ cqfd --build centos7 --deinit

To list all created images, use:

    $ cqfd --ls

To purge all unused images across all user projects on the system, use:

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
rpmbuild --undefine=_disable_source_fetch -ba cqfd6.spec "$@"
cp ~/rpmbuild/SRPMS/*.src.rpm ~/rpmbuild/RPMS/*/*.rpm "$OLDPWD"
```

_Note_: The artefacts are available in `~/rpmbuild/RPMS` and `~/rpmbuild/SRPMS`
directories.

## Using podman

Podman may be used instead of Docker, but with limited functionalities,
for example when dealing with extra groups.

To use `podman` instead of `docker`, you can set in your environment,
like your `.bashrc`, `.profile` or `.zshrc`:

```bash
export CQFD_DOCKER="podman"
export PODMAN_USERNS="keep-id"
```

## Testing cqfd (for developers)

The codebase contains tests which can be invoked using the following
command, if the above requirements are met on the system:

    $ make tests

## The parser

The .ini parser is implemented using a series of bash substitutions that
transform an .ini-style configuration file into shell instructions. The
original code was written by Andrés J. Díaz and later improved and
simplified[1].

In practice, sections are converted into functions whose names are prefixed
with `cfg_section_`, while properties are translated into variables. The
resulting code is then evaluated with `eval`, and the section functions are
executed to set the corresponding properties in the shell environment.

For example:

``` .ini
# The content of .cqfdrc:
[project]
org=savoirfairelinux
name=cqfd

[build]
command=/bin/sh
```

``` sh
# The generated shell code
function cfg_section_project {
    org=savoirfairelinux
    name=cqfd
}

function cfg_section_build {
    command=/bin/sh
}
```

_Important_: Shell commands must not be placed inside sections; any code
present is executed upon section load.

## Patches

Submit patches at *https://github.com/gportay/cqfd6/pulls*

## Bugs

Report bugs at *https://github.com/gportay/cqfd6/issues*

## Trivia

CQFD stands for "ce qu'il fallait Dockeriser", French for "what needed
to be Dockerized".

[1]: https://ajdiaz.wordpress.com/2008/02/09/bash-ini-parser/
