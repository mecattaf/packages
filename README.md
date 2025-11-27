# DankLinux COPR Package Repository

**Repository**: `mecattaf/packages`
**Status**: ✅ Active | **Fedora**: 40, 41, 43, Rawhide

Comprehensive COPR repository for DankMaterialShell ecosystem, QuickShell with QtWebEngine support, and related components optimized for modern Wayland desktop environments.

---

## 🎯 Purpose

This repository provides the complete DankMaterialShell (DMS) desktop environment stack including:

- **quickshell-webengine**: QuickShell with QtWebEngine and QtWebChannel support
- **dms**: DankMaterialShell with React-based web UI components
- **dms-greeter**: Modern greeter for greetd login manager
- **danksearch**: Blazingly fast filesystem search utility
- **breakpad**: Google's crash-reporting system (required by quickshell)
- **material-symbols-fonts**: Google Material Symbols font for UI icons

---

## 📦 Complete Package List

### Package Overview

| Package | Version | Description | Dependencies |
|---------|---------|-------------|--------------|
| **breakpad** | 2024.02.16 | Google Breakpad crash-reporting system | zlib, gcc-c++ |
| **quickshell-webengine** | 0.2.1 | QtQuick desktop shell with WebEngine | breakpad-static, qt6-qtwebengine |
| **dms** | git-based | DankMaterialShell main package | quickshell-webengine, dgop, dms-cli |
| **dms-cli** | (subpackage) | DMS command-line interface | Built from Go sources |
| **dgop** | (subpackage) | Stateless CPU/GPU monitor | Binary download from GitHub |
| **dms-greeter** | git-based | DMS greeter for greetd | quickshell-webengine, greetd |
| **danksearch** | 0.0.7 | Fast filesystem search tool | glibc |
| **material-symbols-fonts** | 1.0 | Google Material Symbols font | fontpackages |

---

## 🔗 Dependency Graph

```
Build Order (respect dependencies):

1. breakpad
   └─> Provides: breakpad-static
       Required by: quickshell-webengine

2. quickshell-webengine
   └─> Requires: breakpad-static (build), qt6-qtwebengine (runtime)
       Required by: dms, dms-greeter

3. material-symbols-fonts
   └─> No dependencies
       Required by: dms (for UI icons)

4. danksearch
   └─> No dependencies
       Recommended by: dms

5. dms
   ├─> REQUIRES: quickshell-webengine, dms-cli, dgop
   ├─> RECOMMENDS: danksearch, material-symbols-fonts, cliphist, matugen
   └─> Downloads: dgop binary from GitHub releases

6. dms-greeter
   └─> REQUIRES: quickshell-webengine, greetd
```

### External COPR Dependencies

This repository is self-contained except for:
- **None currently** - All required packages are built in `mecattaf/packages`

### External Fedora Repository Dependencies

The following are required from standard Fedora repos:
- `qt6-qtwebengine`, `qt6-qtwebchannel` (runtime for quickshell-webengine)
- `greetd` (for dms-greeter)
- `golang >= 1.24` (build dependency for dms-cli)
- Various Qt6 and system libraries

---

## 🚀 Installation

### Quick Start - Full DMS Environment

```bash
# Enable the COPR repository
sudo dnf copr enable mecattaf/packages

# Install complete DMS desktop environment
sudo dnf install dms dms-greeter material-symbols-fonts danksearch

# Optional: Install recommended utilities
sudo dnf install cliphist hyprpicker matugen gamescope
```

### Individual Package Installation

```bash
# Just QuickShell with WebEngine support
sudo dnf install quickshell-webengine

# Just the greeter
sudo dnf install dms-greeter

# Just the search tool
sudo dnf install danksearch
```

---

## 🏗️ Architecture

### DankMaterialShell Stack

```
┌─────────────────────────────────────────────────┐
│            User Applications                    │
│         (React UI Components)                   │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│        QuickShell + QtWebEngine                 │
│     (QML ↔ JavaScript Bridge)                  │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│          Wayland Compositor                     │
│    (niri, hyprland, sway, dwl)                 │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│     Optional: GameScope (Vulkan)                │
│   (Hardware-accelerated rendering)              │
└─────────────────────────────────────────────────┘
                    ↓
            Hardware GPU (Vulkan)
```

**Why GameScope?** (Optional but Recommended)
- Valve's proven Vulkan microcompositor (powers Steam Deck)
- Hardware-accelerated WebEngine rendering
- Solves GPU/Wayland compatibility edge cases
- Battle-tested at scale

---

## 📋 Repository Structure

```
.
├── breakpad/
│   └── breakpad.spec                # Google Breakpad packaging
├── quickshell-webengine/
│   ├── quickshell-webengine.spec    # QuickShell with WebEngine
│   └── quickshell-webengine.patch   # CMake modifications for WebEngine
├── dms/
│   └── dms.spec                     # Main DMS package (includes dms-cli, dgop)
├── dms-greeter/
│   └── dms-greeter.spec             # Greeter for greetd
├── danksearch/
│   └── danksearch.spec              # Filesystem search tool
├── fonts/
│   └── material-symbols-fonts.spec  # Material Symbols font
├── references/
│   └── [original spec files]        # Reference specs from upstream
├── .copr/
│   └── Makefile                     # COPR build automation
├── .github/workflows/
│   ├── build.yml                    # Package building
│   └── update.yml                   # Version checking
└── docs/
    ├── TESTING.md                   # Testing instructions
    └── PATCH_MAINTENANCE.md         # Patch update guide
```

---

## 🔧 Package Details

### QuickShell WebEngine

**What's Different from Official QuickShell?**

| Feature | Official QuickShell | quickshell-webengine |
|---------|---------------------|----------------------|
| QtWebEngine | ❌ | ✅ |
| QtWebChannel | ❌ | ✅ |
| Web UI Support | ❌ | ✅ |
| Chromium Rendering | ❌ | ✅ |
| QML ↔ JS Bridge | ❌ | ✅ |
| GameScope Optimized | - | ✅ |
| Conflicts with official | - | Yes (by design) |

**Patch Changes:**
```cmake
option(WEBENGINE "Enable QtWebEngine support" OFF)

find_package(Qt6 COMPONENTS WebEngineQuick WebChannel)
target_link_libraries(quickshell-module Qt6::WebEngineQuick Qt6::WebChannel)
```

Minimal, surgical changes to QuickShell upstream.

**Source:** https://github.com/quickshell-mirror/quickshell

---

### DankMaterialShell (dms)

Material Design 3 inspired desktop shell for Wayland compositors.

**Subpackages:**
- `dms` - Main shell files and configuration
- `dms-cli` - Command-line tool (built from Go sources)
- `dgop` - CPU/GPU/Memory monitor (pre-built binary)

**Features:**
- Material 3 design with React-based web UI
- Auto-theming for GTK/Qt apps (via matugen)
- 20+ customizable widgets
- Process monitoring and notifications
- Clipboard history (cliphist integration)
- Control center, lock screen, dock
- Comprehensive plugin system

**Supported Compositors:**
- niri (primary)
- hyprland
- sway
- dwl (MangoWC)

**Installation Location:** `/usr/share/quickshell/dms/`

**Source:** https://github.com/AvengeMedia/DankMaterialShell

---

### DMS Greeter

Modern Material Design 3 greeter for the greetd login manager.

**Features:**
- Automatic compositor detection (niri/hyprland/sway)
- Session selection
- User authentication via PAM
- Dynamic theming (syncs with DMS if installed)
- SELinux context management
- Auto-configuration of greetd

**Post-Install Steps:**
```bash
# Disable existing display managers
sudo systemctl disable gdm sddm lightdm

# Enable greetd
sudo systemctl enable greetd

# Optional: Sync theme with DMS
dms greeter sync
```

**Installation Location:** `/usr/share/quickshell/dms-greeter/`

**Source:** https://github.com/AvengeMedia/DankMaterialShell (Modules/Greetd)

---

### DankSearch

Blazingly fast filesystem search utility powered by bleve.

**Features:**
- Fuzzy search
- EXIF extraction for images
- Virtual folders
- Concurrent indexing
- Systemd user service for background indexing

**Usage:**
```bash
# Enable background service
systemctl --user enable --now dsearch

# Search from command line
dsearch query "myfile"
```

**Installation Location:** `/usr/bin/dsearch`

**Source:** https://github.com/AvengeMedia/danksearch

---

### Breakpad

Google's crash-reporting system, required for building quickshell.

**Subpackages:**
- `breakpad` - Runtime binaries
- `breakpad-devel` - Development headers
- `breakpad-static` - Static libraries (required by quickshell)

**Source:** https://chromium.googlesource.com/breakpad/breakpad

---

### Material Symbols Fonts

Google Material Symbols Rounded variable font.

**Usage:** Required for DMS UI icons. Supports adjustable:
- Fill
- Weight
- Grade
- Optical size

**Installation Location:** `/usr/share/fonts/material-symbols/`

**Source:** https://github.com/google/material-design-icons

---

## 🛠️ Development

### Local Testing

See [docs/TESTING.md](docs/TESTING.md) for detailed instructions.

```bash
# Clone repository
git clone https://github.com/mecattaf/packages
cd packages

# Build a specific package
cd quickshell-webengine
spectool -g quickshell-webengine.spec
rpmbuild -bb quickshell-webengine.spec
```

### Build Order for Local Builds

If building all packages locally, follow this order:

1. `breakpad` (provides breakpad-static)
2. `quickshell-webengine` (requires breakpad-static)
3. `material-symbols-fonts` (no dependencies)
4. `danksearch` (no dependencies)
5. `dms` (requires quickshell-webengine)
6. `dms-greeter` (requires quickshell-webengine)

### Updating Patches

See [docs/PATCH_MAINTENANCE.md](docs/PATCH_MAINTENANCE.md) for patch regeneration.

```bash
# If QuickShell upstream CMakeLists.txt changes
cd quickshell-webengine
./regenerate-patch.sh <new-version>
```

---

## 🤖 Automation

### GitHub Actions

- **Build Workflow**: Triggers on push or `[build-all]` in commit message
- **Update Workflow**: Checks for new QuickShell versions every 6 hours
- Supports `[build-<package>]` for selective builds

### COPR Integration

Packages are automatically built for:
- Fedora 40 (x86_64)
- Fedora 41 (x86_64)
- Fedora 43 (x86_64)
- Fedora Rawhide (x86_64)

**Monitor builds:** https://copr.fedorainfracloud.org/coprs/mecattaf/packages/

---

## 📊 Build Status

[![COPR Build](https://copr.fedorainfracloud.org/coprs/mecattaf/packages/package/quickshell-webengine/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/mecattaf/packages/package/quickshell-webengine/)

---

## 🐛 Troubleshooting

### WebEngine Not Working

```bash
# Verify WebEngine is available in Qt
qml -c 'import QtWebEngine; console.log("Works!")'

# Check if running under GameScope (if using GameScope)
echo $GAMESCOPE_WAYLAND_DISPLAY
```

### DMS Not Starting

```bash
# Check systemd service status
systemctl --user status dms

# View logs
journalctl --user -u dms -f

# Verify quickshell-webengine is installed
rpm -q quickshell-webengine
```

### Greeter Not Showing

```bash
# Check greetd status
sudo systemctl status greetd

# Verify greeter user exists
id greeter

# Check greetd configuration
cat /etc/greetd/config.toml
```

### Build Failures

```bash
# Check COPR build logs
copr-cli list-builds mecattaf/packages

# View specific build
copr-cli get-build <build-id>
```

---

## 📚 Documentation

- [Testing Guide](docs/TESTING.md) - How to test packages locally
- [Patch Maintenance](docs/PATCH_MAINTENANCE.md) - Updating patches for new versions
- [QuickShell Docs](https://quickshell.outfoxxed.me/) - Official QuickShell documentation
- [Qt WebEngine](https://doc.qt.io/qt-6/qtwebengine-index.html) - Qt WebEngine documentation
- [DankLinux Docs](https://danklinux.com/docs/) - DankLinux ecosystem documentation

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test locally (see docs/TESTING.md)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Spec File Guidelines

- Preserve changelog history (don't modify existing entries)
- Use rpkg macros for git-based packages (`{{{ git_repo_version }}}`)
- Follow Fedora packaging guidelines
- Test on at least one Fedora version before submitting

---

## 📄 License

- **QuickShell**: LGPL-3.0-only AND GPL-3.0-only
- **DankMaterialShell**: MIT (shell), GPL-3.0-only (dms-cli)
- **Breakpad**: BSD-3-Clause
- **DankSearch**: MIT
- **Material Symbols Fonts**: Apache-2.0
- **This Repository**: MIT

---

## 🙏 Credits

- **QuickShell**: [quickshell-mirror/quickshell](https://github.com/quickshell-mirror/quickshell)
- **DankMaterialShell**: [AvengeMedia/DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
- **DankSearch**: [AvengeMedia/danksearch](https://github.com/AvengeMedia/danksearch)
- **Breakpad**: Google Chromium Project
- **GameScope**: [Valve/gamescope](https://github.com/ValveSoftware/gamescope)
- **Inspiration**: duoRPM packaging patterns, Fedora packaging community

---

## 📞 Support

- **GitHub Issues**: https://github.com/mecattaf/packages/issues
- **COPR Repository**: https://copr.fedorainfracloud.org/coprs/mecattaf/packages/
- **DankLinux Website**: https://danklinux.com/

---

## ⚠️ Important Notes

### QuickShell Conflict

`quickshell-webengine` **conflicts** with the official `quickshell` and `quickshell-git` packages. This is intentional:

- Both packages provide `/usr/bin/quickshell`
- WebEngine build includes additional Qt modules
- You can only have one installed at a time

### DMS Dependencies

The `dms` package has been **modified** from the original DankLinux packaging:

- **Changed:** `Requires: quickshell-git` → `Requires: quickshell-webengine`
- **Changed:** `Recommends: quickshell-git` → `Recommends: quickshell-webengine`
- **Removed:** Direct dependency on `avengemedia/danklinux` COPR
- **Reason:** Consolidate all packages in `mecattaf/packages` to avoid conflicts

### Build Dependencies

If building locally:
1. Build `breakpad` first (provides breakpad-static)
2. Then build `quickshell-webengine`
3. Then build `dms` and `dms-greeter`

COPR handles this automatically via build dependencies.

---

**Last Updated:** 2024-11-27
**Maintained By:** mecattaf (thomas@mecattaf.dev)
**Repository:** https://github.com/mecattaf/packages
