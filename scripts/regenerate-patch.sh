#!/bin/bash
# Simplified QuickShell WebEngine patch generator
# Generates minimal patch with only essential changes

set -euo pipefail

VERSION=${1:-0.2.1}
UPSTREAM_URL="https://github.com/quickshell-mirror/quickshell"
WORKDIR="/tmp/quickshell-patch-$$"

echo "=================================="
echo "QuickShell WebEngine Patch Generator (Simplified)"
echo "=================================="
echo "Version: $VERSION"
echo "Target: <30 line minimal patch"
echo "=================================="

# Clean and create workspace
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download upstream source
echo ""
echo "[1/5] Downloading QuickShell v${VERSION}..."
if ! wget -q "${UPSTREAM_URL}/archive/v${VERSION}.tar.gz"; then
    echo "❌ Failed to download QuickShell v${VERSION}"
    echo "   Check if version exists: ${UPSTREAM_URL}/releases"
    exit 1
fi

echo "[2/5] Extracting source..."
tar xzf "v${VERSION}.tar.gz"

# Create two copies
cp -r "quickshell-${VERSION}" "quickshell-${VERSION}-original"
cp -r "quickshell-${VERSION}" "quickshell-${VERSION}-patched"

cd "quickshell-${VERSION}-patched"

echo "[3/5] Applying minimal WebEngine modifications..."

# Check if CMakeLists.txt exists
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ CMakeLists.txt not found!"
    exit 1
fi

# Backup original
cp CMakeLists.txt CMakeLists.txt.backup

# Modification 1: Add WEBENGINE option after USE_JEMALLOC option
if ! grep -q "boption(USE_JEMALLOC" CMakeLists.txt; then
    echo "❌ Could not find USE_JEMALLOC option in CMakeLists.txt"
    echo "   Upstream structure may have changed"
    exit 1
fi

sed -i '/^boption(USE_JEMALLOC/a\
boption(WEBENGINE "QtWebEngine" OFF)' CMakeLists.txt

# Modification 2: Add WebEngine find_package and linking after jemalloc
if ! grep -q "pkg_check_modules(JEMALLOC" CMakeLists.txt; then
    echo "❌ Could not find jemalloc section in CMakeLists.txt"
    exit 1
fi

# Add the minimal WebEngine block after the jemalloc endif()
sed -i '/pkg_check_modules(JEMALLOC/,/^endif()/{
    /^endif()/a\
\
if(WEBENGINE)\
\	find_package(Qt6 COMPONENTS WebEngineQuick WebChannel REQUIRED)\
\	target_link_libraries(quickshell Qt6::WebEngineQuick Qt6::WebChannel)\
endif()
}' CMakeLists.txt

echo "[4/5] Generating patch..."
cd "$WORKDIR"

# Generate unified diff
diff -Naur "quickshell-${VERSION}-original/CMakeLists.txt" \
           "quickshell-${VERSION}-patched/CMakeLists.txt" \
           > "quickshell-webengine-${VERSION}.patch" || true

# Check if patch was created
if [ ! -s "quickshell-webengine-${VERSION}.patch" ]; then
    echo "❌ Patch generation failed (empty file)"
    exit 1
fi

# Verify patch is minimal (<30 lines)
PATCH_LINES=$(wc -l < "quickshell-webengine-${VERSION}.patch")
echo "   Patch size: $PATCH_LINES lines"

if [ "$PATCH_LINES" -ge 30 ]; then
    echo "⚠️  Warning: Patch is $PATCH_LINES lines (target: <30)"
fi

echo "[5/5] Verifying patch..."
cd "quickshell-${VERSION}-original"

if patch -p1 --dry-run --silent < "../quickshell-webengine-${VERSION}.patch" 2>&1; then
    echo "✅ Patch applies cleanly!"
else
    echo "❌ Patch verification failed!"
    echo ""
    echo "Trying to apply patch with output:"
    patch -p1 --dry-run < "../quickshell-webengine-${VERSION}.patch" || true
    exit 1
fi

# Show patch stats
cd "$WORKDIR"
echo ""
echo "Patch Statistics:"
echo "-----------------------------------"
echo "Lines: $PATCH_LINES (target: <30)"
if command -v diffstat &> /dev/null; then
    diffstat "quickshell-webengine-${VERSION}.patch"
fi
echo "-----------------------------------"
echo ""
echo "Patch content:"
echo "-----------------------------------"
cat "quickshell-webengine-${VERSION}.patch"
echo "-----------------------------------"

# Success!
echo ""
echo "✅ Simplified patch generated successfully!"
echo ""
echo "📍 Location: ${WORKDIR}/quickshell-webengine-${VERSION}.patch"
echo ""
echo "📋 Next steps:"
echo "   1. Copy to repository:"
echo "      cp ${WORKDIR}/quickshell-webengine-${VERSION}.patch \\"
echo "         quickshell-webengine/quickshell-webengine.patch"
echo ""
echo "   2. Test build:"
echo "      cd quickshell-webengine"
echo "      spectool -g quickshell-webengine.spec"
echo "      rpmbuild -bp quickshell-webengine.spec"
echo ""

# Keep workspace for inspection
echo "🗂️  Workspace preserved at: $WORKDIR"
echo ""
