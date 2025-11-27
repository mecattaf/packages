# QuickShell WebEngine - COPR Package Repository

Automated COPR repository for QuickShell with QtWebEngine support, optimized for web-based desktop shells running on GameScope.

## 🎯 Purpose

This repository provides:
- **quickshell-webengine**: QuickShell with QtWebEngine and QtWebChannel support
- **dms**: DankMaterialShell with React-based web UI components

## 🏗️ Architecture

```
Hardware GPU → Vulkan → GameScope → QuickShell+WebEngine → React UI
```

**Why GameScope?**
- Valve's proven Vulkan microcompositor (powers Steam Deck)
- Hardware-accelerated WebEngine rendering
- Solves GPU/Wayland compatibility concerns
- Battle-tested at scale

## 📦 Repository Structure

```
.
├── quickshell-webengine/
│   ├── quickshell-webengine.spec    # RPM spec with WebEngine
│   └── quickshell-webengine.patch   # CMake modifications
├── dms/
│   └── dms.spec                     # DankMaterialShell package
├── .copr/
│   └── Makefile                     # COPR build automation
├── .github/workflows/
│   ├── build.yml                    # Package building
│   └── update.yml                   # Version checking
└── docs/
    ├── TESTING.md                   # Testing instructions
    └── PATCH_MAINTENANCE.md         # Patch update guide
```

## 🚀 Installation

### Enable COPR Repository

```bash
sudo dnf copr enable mecattaf/packages
```

### Install QuickShell with WebEngine

```bash
sudo dnf install quickshell-webengine
```

### Install DankMaterialShell

```bash
sudo dnf install dms gamescope
```

## 🔧 What's Different?

### QuickShell WebEngine vs Official QuickShell

| Feature | Official | WebEngine |
|---------|----------|-----------|
| QtWebEngine | ❌ | ✅ |
| QtWebChannel | ❌ | ✅ |
| Web UI Support | ❌ | ✅ |
| Chromium Rendering | ❌ | ✅ |
| QML ↔ JS Bridge | ❌ | ✅ |
| GameScope Optimized | - | ✅ |

### CMake Changes

The patch adds:
```cmake
option(WEBENGINE "Enable QtWebEngine support" OFF)

find_package(Qt6 COMPONENTS WebEngineQuick WebChannel)
target_link_libraries(quickshell-module Qt6::WebEngineQuick Qt6::WebChannel)
```

That's it! Minimal, surgical changes.

## 📋 Usage Example

### QML with WebEngine

```qml
import QtQuick
import QtWebEngine
import QtWebChannel

ApplicationWindow {
    Component.onCompleted: {
        QtWebEngine.initialize()
    }
    
    WebEngineView {
        anchors.fill: parent
        url: "https://your-web-ui.dev"
        
        webChannel: WebChannel {
            id: channel
            registeredObjects: [bridge]
        }
    }
    
    QtObject {
        id: bridge
        WebChannel.id: "backend"
        
        signal dataChanged(string data)
        
        function sendToWeb(data) {
            dataChanged(data)
        }
    }
}
```

### Run with GameScope

```bash
gamescope -f -- quickshell -c /path/to/config.qml
```

## 🔨 Development

### Local Testing

See [TESTING.md](docs/TESTING.md) for detailed instructions.

```bash
# Clone repository
git clone https://github.com/mecattaf/packages
cd packages

# Build locally
cd quickshell-webengine
spectool -g quickshell-webengine.spec
rpmbuild -bb quickshell-webengine.spec
```

### Updating the Patch

See [PATCH_MAINTENANCE.md](docs/PATCH_MAINTENANCE.md) for patch regeneration.

```bash
# If QuickShell upstream CMakeLists.txt changes:
./scripts/regenerate-patch.sh
```

## 🤖 Automation

### GitHub Actions

- **Build Workflow**: Triggers on push or `[build-webengine]` in commit
- **Update Workflow**: Checks for new QuickShell versions every 6 hours

### COPR Integration

Packages are automatically built for:
- Fedora 40 (x86_64)
- Fedora 41 (x86_64)
- Fedora Rawhide (x86_64)

## 📊 Build Status

[![COPR Build](https://copr.fedorainfracloud.org/coprs/mecattaf/packages/package/quickshell-webengine/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/mecattaf/packages/package/quickshell-webengine/)

Monitor builds: https://copr.fedorainfracloud.org/coprs/mecattaf/packages/

## 🛠️ Dependencies

### Build Time
- cmake, ninja-build, gcc-c++
- qt6-qtbase-devel, qt6-qtbase-private-devel
- qt6-qtdeclarative-devel, qt6-qtwayland-devel
- qt6-qtwebengine-devel, qt6-qtwebchannel-devel
- Various system libraries (see spec file)

### Runtime
- qt6-qtwebengine
- qt6-qtwebchannel
- gamescope (recommended)

## 🐛 Troubleshooting

### WebEngine Not Working

```bash
# Verify WebEngine is available
qml -c 'import QtWebEngine; console.log("Works!")'

# Check if running in GameScope
echo $GAMESCOPE_WAYLAND_DISPLAY
```

### Build Failures

```bash
# Check COPR build logs
copr-cli list-builds mecattaf/packages

# View specific build
copr-cli get-build <build-id>
```

### Patch Doesn't Apply

```bash
# QuickShell updated CMakeLists.txt
cd quickshell-webengine
./regenerate-patch.sh <new-version>
```

## 📚 Documentation

- [Testing Guide](docs/TESTING.md) - How to test packages locally
- [Patch Maintenance](docs/PATCH_MAINTENANCE.md) - Updating the patch
- [QuickShell Docs](https://quickshell.outfoxxed.me/) - Official QuickShell documentation
- [Qt WebEngine](https://doc.qt.io/qt-6/qtwebengine-index.html) - Qt WebEngine documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally (see TESTING.md)
5. Submit a pull request

## 📄 License

- QuickShell: LGPL-3.0-only AND GPL-3.0-only
- This repository: MIT
- DMS: GPL-3.0-only

## 🙏 Credits

- **QuickShell**: [quickshell-mirror/quickshell](https://github.com/quickshell-mirror/quickshell)
- **GameScope**: [Valve/gamescope](https://github.com/ValveSoftware/gamescope)
- **Inspiration**: duoRPM packaging patterns

## 📞 Support

- **Issues**: https://github.com/mecattaf/packages/issues
- **COPR**: https://copr.fedorainfracloud.org/coprs/mecattaf/packages/
- **QuickShell Discord**: (if applicable)

---

**Status**: ✅ Active | **COPR**: `mecattaf/packages` | **Fedora**: 40, 41, Rawhide
