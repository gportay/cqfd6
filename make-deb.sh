#!/usr/bin/env -S "CQFD_EXTRA_RUN_ARGS=--volume ${HOME}:${HOME}" cqfd --build deb --shell
set -e
dpkg-buildpackage -us -uc "$@"
lintian ../cqfd*.dsc ../cqfd*.deb
