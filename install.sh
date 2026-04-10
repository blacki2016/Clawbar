#!/usr/bin/env bash
set -euo pipefail

# Clawbar Installer — curl -fsSL https://raw.githubusercontent.com/blacki2016/Clawbar/main/install.sh | bash

REPO="blacki2016/Clawbar"
APP_NAME="Clawbar"
APP_PATH="/Applications/${APP_NAME}.app"
CLI_HELPER="/Applications/${APP_NAME}.app/Contents/Helpers/clawbar"
INSTALL_PATH="/usr/local/bin/clawbar"

# Detect if running with sudo (common when piped from curl)
if [ "$(uname)" != "Darwin" ]; then
    echo "Clawbar is only supported on macOS."
    exit 1
fi

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
if [ "$MACOS_VERSION" -lt 14 ]; then
    echo "Clawbar requires macOS 14 (Sonoma) or later."
    exit 1
fi

echo "🦞 Installing Clawbar..."

# Get latest release info
LATEST_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tarball_url',''))" 2>/dev/null || echo "")

# Try to find a macOS release asset (zip or tar.gz)
ASSET_URL=""
ASSET_NAME=""
for ext in zip tar.gz; do
    URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); [print(a['browser_download_url']) for a in d.get('assets',[]) if '${ext}' in a['name'].lower()]" 2>/dev/null | head -1)
    if [ -n "$URL" ]; then
        ASSET_URL="$URL"
        ASSET_NAME="Clawbar.${ext}"
        break
    fi
done

if [ -z "$ASSET_URL" ]; then
    echo "Error: Could not find a release asset for macOS."
    echo "Please download manually from: https://github.com/${REPO}/releases"
    exit 1
fi

# Download to temp
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

echo "Downloading ${ASSET_NAME}..."
curl -fsSL "$ASSET_URL" -o "${TMPDIR}/${ASSET_NAME}"

# Extract / unzip
echo "Installing to ${APP_PATH}..."
if [[ "$ASSET_NAME" == *.zip ]]; then
    unzip -q "${ASSET_NAME}" -d /Applications/
elif [[ "$ASSET_NAME" == *.tar.gz ]]; then
    tar -xzf "${ASSET_NAME}" -C /Applications/
fi

# Handle case where archive extracts to a subdirectory
EXTRACTED=$(ls /Applications/ | grep -i clawbar | head -1)
if [ -n "$EXTRACTED" ] && [ -d "/Applications/${EXTRACTED}" ] && [ "$EXTRACTED" != "Clawbar.app" ]; then
    # Move extracted dir to expected name
    if [ -d "/Applications/Clawbar.app" ]; then
        rm -rf "/Applications/Clawbar.app.bak" 2>/dev/null || true
        mv "/Applications/Clawbar.app" "/Applications/Clawbar.app.bak"
    fi
    mv "/Applications/${EXTRACTED}" "/Applications/Clawbar.app"
fi

# Verify app exists
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: Installation failed — ${APP_PATH} not found."
    exit 1
fi

# Create CLI symlink
echo "Setting up CLI (${INSTALL_PATH})..."
if [ ! -x "${CLI_HELPER}" ]; then
    echo "Warning: CLI helper not found at ${CLI_HELPER}"
fi

# Prefer existing symlink location, otherwise create in PATH
if [ -w "$(dirname "$INSTALL_PATH")" ]; then
    ln -sf "${CLI_HELPER}" "$INSTALL_PATH" 2>/dev/null || sudo ln -sf "${CLI_HELPER}" "$INSTALL_PATH"
elif [ -w "/usr/local/bin" ] || [ -w "/opt/homebrew/bin" ]; then
    BIN_DIR="/opt/homebrew/bin"
    [ -w "/usr/local/bin" ] && BIN_DIR="/usr/local/bin"
    ln -sf "${CLI_HELPER}" "${BIN_DIR}/clawbar" 2>/dev/null || sudo ln -sf "${CLI_HELPER}" "${BIN_DIR}/clawbar"
else
    echo "Warning: Could not create CLI symlink. Run manually:"
    echo "  sudo ln -sf '${CLI_HELPER}' '${INSTALL_PATH}'"
fi

# Cleanup
rm -rf "$TMPDIR"

echo ""
echo "✅ Clawbar installed!"
echo ""
echo "  App:  ${APP_PATH}"
echo "  CLI:  clawbar"
echo ""
echo "Run with: open ${APP_PATH}"
echo "CLI:     clawbar --help"
