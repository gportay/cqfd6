#!/usr/bin/env -S "CQFD_EXTRA_RUN_ARGS=--volume ${PWD}/rpmbuild:${HOME}/rpmbuild --volume ${PWD}/cqfd6.spec:${HOME}/rpmbuild/SPECS/cqfd6.spec" cqfd6 --build rpm --yes /bin/bash
set -e
rpmdev-setuptree
cd ~/rpmbuild/SPECS
rpmbuild --undefine=_disable_source_fetch --define='_dockerlibdir %{_exec_prefix}/lib/docker' -ba cqfd6.spec "$@"
rpmlint ~/rpmbuild/SPECS/cqfd6.spec ~/rpmbuild/SRPMS/cqfd6*.rpm ~/rpmbuild/RPMS/cqfd6*.rpm
