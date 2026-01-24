Name:           cqfd6
Version:        6
Release:        1
Summary:        Wrap commands in controlled Docker containers using docker

License:        GPL-3.0-or-later
URL:            https://github.com/gportay/%{name}
Source0:        https://github.com/gportay/%{name}/archive/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  asciidoctor
BuildRequires:  make
BuildRequires:  shellcheck
BuildRequires:  pkgconfig(bash-completion)
Requires:       bash
Requires:       docker

%description
Wrap commands in controlled Docker containers using docker.
cqfd provides a quick and convenient way to run commands in the current
directory, but within a Docker container defined in a per-project config file.

%global debug_package %{nil}

%prep
%setup -q


%check
make check


%build
%make_build doc


%install
%make_install PREFIX=/usr DOCKERLIBDIR=%_libdir/docker
rm %{buildroot}/usr/share/doc/cqfd6/CHANGELOG.md
rm %{buildroot}/usr/share/doc/cqfd6/LICENSE
install -D -m 644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE


%post
_libdir=$(rpm --eval '%%{_libdir}')
mkdir -p "$_libdir/docker/cli-plugins"
ln -sf ../../../../..%{_dockerlibdir}/cli-plugins/docker-cqfd "$_libdir/docker/cli-plugins/docker-cqfd"
if [ $1 -eq 1 ]; then
    alternatives --install /usr/bin/cqfd cqfd /usr/bin/cqfd6 20
    alternatives --install /usr/share/man/man1/cqfd.1.gz cqfd.1.gz /usr/share/man/man1/cqfd6.1.gz 20
    alternatives --install /usr/share/man/man5/cqfdrc.5.gz cqfdrc.5.gz /usr/share/man/man5/cqfdrc6.5.gz 20
fi


%preun
_libdir=$(rpm --eval '%%{_libdir}')
rm -f "$_libdir/docker/cli-plugins/docker-cqfd"
if [ $1 -eq 0 ]; then
    alternatives --remove cqfdrc.5.gz /usr/share/man/man5/cqfdrc6.5.gz
    alternatives --remove cqfd.1.gz /usr/share/man/man1/cqfd6.1.gz
    alternatives --remove cqfd /usr/bin/cqfd6
fi


%files
%doc %{_datadir}/doc/%{name}/AUTHORS
%doc %{_datadir}/doc/%{name}/README.md
%license %{_licensedir}/%{name}/LICENSE
%{_bindir}/%{name}
%{_bindir}/linux-amd64-cqfd6
%{_bindir}/linux-arm-cqfd6
%{_bindir}/linux-arm64-cqfd6
%{_bindir}/linux-ppc64le-cqfd6
%{_bindir}/linux-riscv64-cqfd6
%{_bindir}/linux-s390x-cqfd6
%{_datadir}/%{name}/samples/Dockerfile.Yocto:scarthgap
%{_datadir}/%{name}/samples/dot-cqfdrc
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/man/man1/cqfd6.1.gz
%{_datadir}/man/man5/cqfdrc6.5.gz
%{_dockerlibdir}/cli-plugins/docker-cqfd

%changelog
* Wed Aug 13 2025 Gaël PORTAY <gael.portay@gmail.com> - 6-1
- Initial release.
