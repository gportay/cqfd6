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
Provides:       cqfd = %{version}-%{release}
Obsoletes:      cqfd <= %{version}-%{release}

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
%make_install PREFIX=/usr


%files
%doc %{_datadir}/doc/%{name}/AUTHORS
%doc %{_datadir}/doc/%{name}/CHANGELOG.md
%doc %{_datadir}/doc/%{name}/README.md
%license %{_datadir}/doc/%{name}/LICENSE
%{_bindir}/{%name}
%{_bindir}/cqfd
%{_bindir}/linux-amd64-cqfd
%{_bindir}/linux-arm-cqfd
%{_bindir}/linux-arm64-cqfd
%{_bindir}/linux-ppc64le-cqfd
%{_bindir}/linux-riscv64-cqfd
%{_bindir}/linux-s390x-cqfd
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/%{name}/samples/Dockerfile.focalFossa.android34
%{_datadir}/%{name}/samples/Dockerfile.focalFossa.nodejs20x
%{_datadir}/%{name}/samples/dot-cqfdrc
%{_datadir}/man/man1/cqfd.1.gz
%{_datadir}/man/man5/cqfdrc.5.gz

%changelog
* Wed Aug 13 2025 Gaël PORTAY <gael.portay@gmail.com> - 6-1
- Initial release.
