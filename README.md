# What is cqfd ? #

cqfd provides a quick and convenient way to run commands in the current
directory, but within a Docker container defined in a per-project config
file. This becomes useful when building an application designed for
another Linux system, e.g. building a RHEL7 app when your workstation
runs on Ubuntu 16.04.

# Using cqfd #

## Getting started ##

Just follow these steps:

* Install cqfd (see below)
* Go into your project's directory
* Create a .cqfdrc file
* Put a Dockerfile and save it as .cqfd/docker/Dockerfile
* Run ``cqfd init``

Examples are available in the samples/ directory.

cqfd will use the provided Dockerfile to create a normalized runtime
build environment for your project.

## Using cqfd on a daily basis ##

### Regular builds ###

### Release ###

### Flavors ###

## The .cqfdrc file ##

### Environment variables ###

### Other command-line options ###

## Build Container Environment ##

When cqfd runs, a docker container is launched as the environment in
which to run the *command*.  Within this environment, commands are
run as the 'builder' user.  So that this user has access to local
files, the current working directory is mapped to ~builder/src/.

### SSH Handling ###

The local ~/.ssh directory is mapped to the corresponding directory in
the build container i.e. ~builder/.ssh.  This effectively enables SSH agent
forwarding so a build can, for example, pull authenticated git repos.

Note that it may be helpful to specify the local user name in the
.ssh/config file as this isn't the default on the builder e.g.

	$ echo "User $USER" >> ~/.ssh/config

## Requirements ##

To use cqfd, ensure the following requirements are satisfied on your
workstation:

-  Bash 4.x

-  Docker

-  A ``docker`` group in your /etc/group

-  Your username is a member of the ``docker`` group

-  Restart your docker service if you needed to create the group.

## Installing/removing cqfd ##

The cqfd script can be installed system-wide.

Install or remove the script and its resources:

    $ make install [PREFIX=/usr/local] [DESTDIR=]
    $ make uninstall [PREFIX=/usr/local] [DESTDIR=]

## Testing cqfd (for developers) ##

The codebase contains tests which can be invoked using the following
command, if the above requirements are met on the system:

    $ make tests
