%bcond_with         asan

Name:               quickshell-webengine
Version:            0.2.1
Release:            1%{?dist}
Summary:            Flexible QtQuick desktop shell toolkit with QtWebEngine support

License:            LGPL-3.0-only AND GPL-3.0-only
URL:                https://github.com/quickshell-mirror/quickshell
Source0:            %{url}/archive/v%{version}/quickshell-%{version}.tar.gz
Patch0:             quickshell-webengine.patch

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
BuildRequires:      pkgconfig(jemalloc)
BuildRequires:      pkgconfig(libdrm)
BuildRequires:      pkgconfig(libpipewire-0.3)
BuildRequires:      pkgconfig(pam)
BuildRequires:      pkgconfig(wayland-client)
BuildRequires:      pkgconfig(wayland-protocols)

BuildRequires:      qt6-qtbase-private-devel
BuildRequires:      spirv-tools

%if %{with asan}
BuildRequires:      libasan
%endif

Requires:           qt6-qtwebengine
Requires:           qt6-qtwebchannel

Provides:           desktop-notification-daemon
Conflicts:          quickshell

%description
Flexible toolkit for building desktop shells using Qt Quick on Wayland or X11.

This build includes support for QtWebEngine and QtWebChannel, enabling HTML/JS
user interfaces through the WebEngineView component.

%prep
%autosetup -n quickshell-%{version} -p1

%build
%cmake -GNinja \
%if %{with asan}
      -DASAN=ON \
%endif
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DDISTRIBUTOR="Fedora COPR (mecattaf/packages)" \
      -DDISTRIBUTOR_DEBUGINFO_AVAILABLE=YES \
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
%doc changelog/v%{version}.md
%{_bindir}/qs
%{_bindir}/quickshell
%{_datadir}/applications/org.quickshell.desktop
%{_datadir}/icons/hicolor/scalable/apps/org.quickshell.svg
%{_libdir}/qt6/qml/Quickshell

%changelog
* Thu Nov 28 2024 Your Name <you@example.com> - 0.2.1-1
- Add QtWebEngine integration
