%global github_owner    jnohlgard
%global github_project  issuegen

Name:           issuegen
Version:        0.2
Release:        1%{?dist}
Summary:        Issue generator scripts showing SSH keys and IP addresses

License:        GPL-3.0-or-later
URL:            https://github.com/%{github_owner}/%{github_project}
Source0:        https://github.com/%{github_owner}/%{github_project}/archive/v%{version}.tar.gz

Requires:       systemd
Requires:       /bin/sh
# ssh-keygen is required in order to get the fingerprints from the host key
Recommends:     openssh
Suggests:       openssh-server
# udev rules can be used to generate netif issues for hotplugged network interfaces
Recommends:     systemd-udev
# agetty displays the messages
Recommends:     util-linux-core

BuildArch:      noarch
BuildRequires:  make
BuildRequires:  systemd-rpm-macros

%description
Show SSH host keys and IP addresses for the machine on the getty
login console.

%prep
%setup -q

%build

%install
make install DESTDIR=%{buildroot}

%post
%systemd_post %{name}-ssh-host-keys.service
%systemd_post %{name}-netif-online.service

%preun
%systemd_preun %{name}-ssh-host-keys.service
%systemd_preun %{name}-netif-online.service

%postun
%systemd_postun_with_restart %{name}-ssh-host-keys.service
%systemd_postun_with_restart %{name}-netif-online.service

%files
%license LICENSE
%dir %{_libexecdir}/%{name}
%{_libexecdir}/%{name}/%{name}-netif
%{_libexecdir}/%{name}/%{name}-ssh-host-keys
%dir /run/issue.d
%{_tmpfilesdir}/%{name}.conf
%{_unitdir}/%{name}-netif-online.service
%{_unitdir}/%{name}-netif@.service
%{_unitdir}/%{name}-ssh-host-keys.service
%{_udevrulesdir}/99-%{name}-netif.rules

%changelog
* Thu Aug 29 2024 Joakim Nohlgård <joakim@nohlgard.se> - 0.2-1
- Iron out issues with dependencies and packaging

* Thu Aug 29 2024 Joakim Nohlgård <joakim@nohlgard.se> - 0.1-1
- Initial release
