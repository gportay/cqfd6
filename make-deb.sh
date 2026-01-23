#!/usr/bin/env -S "CQFD_EXTRA_RUN_ARGS=--volume ${HOME}:${HOME}" cqfd6 --build deb --yes /bin/bash
set -e
dpkg-buildpackage -us -uc "$@"
lintian ../cqfd*.dsc ../cqfd*.deb
