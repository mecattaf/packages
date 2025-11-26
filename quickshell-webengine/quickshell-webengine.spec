Name:               quickshell-webengine
Version:            0.2.1
Release:            1%{?dist}
Summary:            QtQuick-based desktop shell toolkit with QtWebEngine support

License:            LGPL-3.0-only AND GPL-3.0-only
URL:                https://github.com/quickshell-mirror/quickshell
Source0:            %{url}/archive/v%{version}/quickshell-%{version}.tar.gz
Patch0:             quickshell-webengine.patch

BuildRequires:      cmake
BuildRequires:      ninja-build
BuildRequires:      gcc-c++
BuildRequires:      qt6-qtbase-devel
BuildRequires:      qt6-qtbase-private-devel
BuildRequires:      qt6-qtdeclarative-devel
BuildRequires:      qt6-qtwayland-devel
BuildRequires:      qt6-qtwebengine-devel
BuildRequires:      qt6-qtwebchannel-devel
BuildRequires:      qt6-qtsvg-devel
BuildRequires:      pam-devel
BuildRequires:      pulseaudio-libs-devel
BuildRequires:      pipewire-devel
BuildRequires:      wayland-devel
BuildRequires:      layer-shell-qt-devel
BuildRequires:      pkgconfig(jemalloc)
BuildRequires:      pkgconfig(xkbcommon)

Requires:           qt6-qtwebengine
Requires:           qt6-qtwebchannel

# Conflict with official QuickShell package
Conflicts:          quickshell

%description
QuickShell is a simple and flexable QtQuick based desktop shell toolkit.

This variant includes QtWebEngine and QtWebChannel support, enabling
web-based UI components and modern web technologies in desktop shells.

%prep
%autosetup -n quickshell-%{version} -p1

%build
%cmake -DWEBENGINE=ON -GNinja
%cmake_build

%install
%cmake_install

%files
%license COPYING
%doc README.md
%{_bindir}/quickshell
%{_libdir}/quickshell/
%{_datadir}/quickshell/

%changelog
* Tue Nov 26 2024 Agency <maintainer@agency-agency.dev> - 0.2.1-1
- Initial package with simplified WebEngine patch
- Patch reduced to <30 lines with minimal changes
- Only adds option and find_package/target_link_libraries
