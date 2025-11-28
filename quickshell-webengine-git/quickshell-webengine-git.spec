%bcond_with         asan

%global commit      e9bad67619ee9937a1bbecfc6ad3b4231d2ecdc3
%global commits     709
%global snapdate    20251125
%global tag         0.2.1

Name:               quickshell-git-webengine
Version:            %{tag}^%{commits}.git%(c=%{commit}; echo ${c:0:7})
Release:            1%{?dist}
Summary:            QtQuick desktop shell toolkit (Git snapshot) with QtWebEngine support

License:            LGPL-3.0-only AND GPL-3.0-only
URL:                https://github.com/quickshell-mirror/quickshell
Source0:            %{url}/archive/%{commit}/quickshell-%{commit}.tar.gz
Patch0:             quickshell-git-webengine.patch

Conflicts:          quickshell-git <= %{tag}
Conflicts:          quickshell-webengine
Provides:           desktop-notification-daemon

BuildRequires:      cmake
BuildRequires:      ninja-build
BuildRequires:      gcc-c++

BuildRequires:      cmake(Qt6Core)
BuildRequires:      cmake(Qt6Qml)
BuildRequires:      cmake(Qt6Quick)
BuildRequires:      cmake(Qt6ShaderTools)
BuildRequires:      cmake(Qt6WaylandClient)
BuildRequires:      cmake(Qt6WebEngineQuick)
BuildRequires:      cmake(Qt6WebChannel)

BuildRequires:      pkgconfig(breakpad)
BuildRequires:      pkgconfig(CLI11)
BuildRequires:      pkgconfig(gbm)
BuildRequires:      pkgconfig(glib-2.0)
BuildRequires:      pkgconfig(jemalloc)
BuildRequires:      pkgconfig(libdrm)
BuildRequires:      pkgconfig(libpipewire-0.3)
BuildRequires:      pkgconfig(pam)
BuildRequires:      pkgconfig(polkit-agent-1)
BuildRequires:      pkgconfig(wayland-client)
BuildRequires:      pkgconfig(wayland-protocols)

BuildRequires:      qt6-qtbase-private-devel
BuildRequires:      spirv-tools

%if %{with asan}
BuildRequires:      libasan
%endif

Requires:           qt6-qtwebengine
Requires:           qt6-qtwebchannel

%description
Flexible toolkit for building desktop shells with QtQuick.

This variant is a Git snapshot and includes support for QtWebEngine
and QtWebChannel.

%prep
%autosetup -n quickshell-%{commit} -p1

%build
%cmake -GNinja \
%if %{with asan}
      -DASAN=ON \
%endif
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DDISTRIBUTOR="Fedora COPR (mecattaf/packages)" \
      -DDISTRIBUTOR_DEBUGINFO_AVAILABLE=YES \
      -DGIT_REVISION=%{commit} \
      -DINSTALL_QML_PREFIX=%{_lib}/qt6/qml \
      -DWEBENGINE=ON

%cmake_build

%install
%cmake_install

%files
%license LICENSE
%license LICENSE-GPL
%doc BUILD.md
%doc CONTRIBUTING.md
%doc README.md
%doc changelog/v%{tag}.md
%{_bindir}/qs
%{_bindir}/quickshell
%{_datadir}/applications/org.quickshell.desktop
%{_datadir}/icons/hicolor/scalable/apps/org.quickshell.svg
%{_libdir}/qt6/qml/Quickshell

%changelog
* Thu Nov 28 2024 Your Name <you@example.com> - %{tag}^%{commits}.git-1
- Add QtWebEngine support for Git snapshot
