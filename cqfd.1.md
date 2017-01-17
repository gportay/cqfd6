cqfd(1) - a tool to wrap commands in controlled Docker containers
===

## SYNOPSIS

**cqfd** [OPTIONS] [COMMAND] [ARGUMENTS]

## DESCRIPTION

**cqfd(1)** provides a quick and convenient way to run commands in the current
directory, but within a Docker container defined in a per-project config file.

This becomes useful when building an application designed for another Linux
system, e.g. building a RHEL7 app when your workstation runs on Ubuntu 16.04.

## COMMANDS

**init**
: Initialize project build container

**run**
: Run argument(s) inside build container

**release**
: Run argument(s) and release software

**help**
: Show this help text

## OPTIONS

**-f <file>**
: Use file as config file (default .cqfdrc)

**-b <flavor_name>**
: Target a specific build flavor.

**-h or --help**
: Display this help message.

## EXAMPLES

**Regular builds**

To build your project from the configured build environment with the default
build command as configured in **.cqfdrc(5)**, use:

```
$ cqfd
```

Alternatively, you may want to specify a custom build command to be executed
from inside the build container.

```
$ cqfd run make clean
$ cqfd run "make linux-dirclean && make foobar-dirclean"
```

When **cqfd(1)** is running, the current directory is mounted by Docker as a
volume. As a result, all the build artefacts generated inside the container are
still accessible in this directory after the container has been stopped and
removed.

**Release**

The __release__ command behaves exactly like __run__, but creates a release
tarball for your project additionally. The release files (as specified in your
**.cqfdrc(5)**) will be included inside the release archive.

```
$ cqfd release
```

The resulting release file is then called unique job name, or the string
`local-build' when run from outside Jenkins, and BUILD_ID is a Jenkins-generated
unique and date-based string, or the current date.

**Flavors**

You may also want to build a specific build __flavor__, for a regular build or
a release. To do so use the __-b__ option, for example:

```
$ cqfd -b debug run
```

When building with a __flavor__ as when building a regular project, the run
option can be omitted.

**Other command-line options**

In some conditions you may want to use an alternate config file with
**cqfd(1)**. This is what the __-f__ option is for:

```
$ cqfd -f .cqfdrc.test
```

## FILES

**.cqfdrc**
    Project information config file (See **cqfdrc(5)**).

## ENVIRONMENT

**CQFD_EXTRA_VOLUMES**
: A space-separated list of additional volume mappings to be configured inside
the started container. Format is the same as (and passed to) docker-run’s __-v__
option.

**CQFD_EXTRA_HOSTS**
: A space-separated list of additional host mappings to be configured inside the
started container. Format is the same as (and passed to) docker-run’s
__--add-host__ option.

**CQFD_EXTRA_ENV**
: A space-separated list of additional environment variables to be passed to the
started container. Format is the same as (and passed to) docker-run’s __-e__
option.

## BUGS

Report bugs at <**https://github.com/savoirfairelinux/cqfd/issues**>

## AUTHOR

Originally written by Mathieu Audat <**mathieu.audat@savoirfairelinux.com**>

## COPYRIGHT

Copyright (C) 2015-2017 Savoir-faire Linux, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

## SEE ALSO

**cqfdrc(5)**, **docker(1)**, **Dockerfile(5)**

## COLOPHON

This page is part of **C.Q.F.D.** project.

**C.Q.F.D.** stands for \`Ce qu'il fallait Dockeriser', french for \`what needed
to be dockerized'.
