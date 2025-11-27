#!/bin/bash
# QuickShell WebEngine patch generator
# Generates patch for adding QtWebEngine support to QuickShell

set -euo pipefail

VERSION=${1:-0.2.1}
UPSTREAM_URL="https://github.com/quickshell-mirror/quickshell"
WORKDIR="/tmp/quickshell-patch-$$"

echo "=================================="
echo "QuickShell WebEngine Patch Generator"
echo "=================================="
echo "Version: $VERSION"
echo "=================================="

# Clean and create workspace
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download upstream source
echo ""
echo "[1/5] Downloading QuickShell v${VERSION}..."
if ! wget -q "${UPSTREAM_URL}/archive/v${VERSION}.tar.gz" -O source.tar.gz; then
    echo "❌ Failed to download QuickShell v${VERSION}"
    echo "   Check if version exists: ${UPSTREAM_URL}/releases"
    exit 1
fi

echo "[2/5] Extracting source..."
tar xzf source.tar.gz

# Create two copies
cp -r "quickshell-${VERSION}" "original"
cp -r "quickshell-${VERSION}" "patched"

cd "patched"

echo "[3/5] Applying WebEngine modifications..."

# Check if CMakeLists.txt exists
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ CMakeLists.txt not found!"
    exit 1
fi

# Find the line numbers for insertion points
SOCKETS_LINE=$(grep -n "^boption(SOCKETS " CMakeLists.txt | cut -d: -f1)
WAYLAND_ENDIF_LINE=$(grep -n "^endif()" CMakeLists.txt | head -3 | tail -1 | cut -d: -f1)
JEMALLOC_ENDIF_LINE=$(grep -n "^endif()" CMakeLists.txt | head -4 | tail -1 | cut -d: -f1)

if [ -z "$SOCKETS_LINE" ]; then
    echo "❌ Could not find SOCKETS boption"
    exit 1
fi

echo "   Found SOCKETS at line $SOCKETS_LINE"
echo "   Found WAYLAND endif at line $WAYLAND_ENDIF_LINE"
echo "   Found JEMALLOC endif at line $JEMALLOC_ENDIF_LINE"

# Create the patched file using ed for precise line-based editing
cp CMakeLists.txt CMakeLists.txt.backup

# Modification 1: Add WEBENGINE option after SOCKETS
# Find the exact line and insert after it
sed -i "/^boption(SOCKETS /a boption(WEBENGINE \"QtWebEngine\" ON)" CMakeLists.txt

# Modification 2: Add WebEngine deps after WAYLAND block (after the endif following WAYLAND)
# We need to insert after the endif that closes the WAYLAND block
# The WAYLAND block is: if (WAYLAND) ... endif()

# Find the pattern: endif() that follows the WaylandClientPrivate line
sed -i '/list(APPEND QT_PRIVDEPS WaylandClientPrivate)/,/^endif()/{
    /^endif()/ a\
\
# WebEngine support (optional)\
if (WEBENGINE_effective)\
\	list(APPEND QT_FPDEPS WebEngineQuick WebChannel)\
endif()
}' CMakeLists.txt

# Modification 3: Add WebEngine linking after jemalloc block
sed -i '/target_link_libraries(quickshell PRIVATE \${JEMALLOC_LIBRARIES})/,/^endif()/{
    /^endif()/ a\
\
# WebEngine linking\
if (WEBENGINE_effective)\
\	target_link_libraries(quickshell PRIVATE Qt6::WebEngineQuick Qt6::WebChannel)\
\	target_compile_definitions(quickshell PRIVATE QS_WEBENGINE)\
endif()
}' CMakeLists.txt

echo "[4/5] Generating patch..."
cd "$WORKDIR"

# Generate unified diff
diff -Naur "original/CMakeLists.txt" "patched/CMakeLists.txt" > "quickshell-webengine.patch" || true

# Check if patch was created
if [ ! -s "quickshell-webengine.patch" ]; then
    echo "❌ Patch generation failed (empty file)"
    echo "Showing diff between files:"
    diff "original/CMakeLists.txt" "patched/CMakeLists.txt" || true
    exit 1
fi

PATCH_LINES=$(wc -l < "quickshell-webengine.patch")
echo "   Patch size: $PATCH_LINES lines"

echo "[5/5] Verifying patch..."
cd "original"

if patch -p1 --dry-run < "../quickshell-webengine.patch" 2>&1; then
    echo "✅ Patch applies cleanly!"
else
    echo "❌ Patch verification failed!"
    echo ""
    echo "Trying to apply patch with output:"
    patch -p1 --dry-run < "../quickshell-webengine.patch" || true
    exit 1
fi

# Show patch
echo ""
echo "=================================="
echo "Generated Patch:"
echo "=================================="
cat "../quickshell-webengine.patch"
echo "=================================="

# Success!
echo ""
echo "✅ Patch generated successfully!"
echo ""
echo "📍 Location: ${WORKDIR}/quickshell-webengine.patch"
echo ""
echo "📋 Next steps:"
echo "   1. Copy to repository:"
echo "      cp ${WORKDIR}/quickshell-webengine.patch quickshell-webengine/"
echo ""
echo "   2. Test build:"
echo "      cd quickshell-webengine"
echo "      spectool -g quickshell-webengine.spec"
echo "      rpmbuild -bp quickshell-webengine.spec"
echo ""
