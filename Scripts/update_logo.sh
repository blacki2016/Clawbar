#!/usr/bin/env bash
# update_logo.sh — Replace Clawbar app icon with a new PNG.
# Usage: ./Scripts/update_logo.sh ~/Downloads/Design\ ohne\ Titel.png
# The source PNG should be at least 512×512 px (1024×1024 or larger is ideal).

set -euo pipefail

SOURCE_PNG="${1:-}"
if [[ -z "$SOURCE_PNG" ]] || [[ ! -f "$SOURCE_PNG" ]]; then
    echo "Usage: $0 <path-to-new-icon.png>"
    echo "  Example: $0 ~/Downloads/Design\ ohne\ Titel.png"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RESOURCES="$REPO_ROOT/Sources/Clawbar/Resources"
ICON_ICON="$REPO_ROOT/Icon.icon"
TMP_DIR="$(mktemp -d)"

echo "→ Source PNG: $SOURCE_PNG"
echo "→ Repo root:  $REPO_ROOT"

# 1. Copy the source PNG to the repo as the main logo
cp "$SOURCE_PNG" "$RESOURCES/AppIcon.png"
cp "$SOURCE_PNG" "$REPO_ROOT/clawbar-logo.png"
echo "✓ Copied PNG to Resources/AppIcon.png and clawbar-logo.png"

# 2. Build an iconset from the source PNG using sips
ICONSET="$TMP_DIR/AppIcon.iconset"
mkdir -p "$ICONSET"

declare -a sizes=(16 32 128 256 512)
for sz in "${sizes[@]}"; do
    sips -z "$sz" "$sz" "$SOURCE_PNG" --out "$ICONSET/icon_${sz}x${sz}.png" >/dev/null
    dbl=$((sz * 2))
    sips -z "$dbl" "$dbl" "$SOURCE_PNG" --out "$ICONSET/icon_${sz}x${sz}@2x.png" >/dev/null
done
echo "✓ Generated iconset at sizes: 16, 32, 128, 256, 512 (+ @2x variants)"

# 3. Compile iconset → .icns
iconutil -c icns "$ICONSET" -o "$TMP_DIR/AppIcon.icns"
echo "✓ Compiled AppIcon.icns"

# 4. Install into all relevant locations
cp "$TMP_DIR/AppIcon.icns" "$RESOURCES/AppIcon.icns"
cp "$TMP_DIR/AppIcon.icns" "$ICON_ICON/AppIcon.icns"
echo "✓ Installed AppIcon.icns into Resources/ and Icon.icon/"

# 5. Also update the Icon.icon/AppIcon.png (used as quick preview)
sips -z 512 512 "$SOURCE_PNG" --out "$ICON_ICON/AppIcon.png" >/dev/null
echo "✓ Updated Icon.icon/AppIcon.png"

# 6. Update the round iconset sizes (used for notifications etc.)
ROUND_ICONSET="$ICON_ICON/round.iconset"
if [[ -d "$ROUND_ICONSET" ]]; then
    for f in "$ROUND_ICONSET"/icon_*.png; do
        # Detect size from filename
        fname=$(basename "$f")
        if [[ "$fname" =~ icon_([0-9]+)\.png ]]; then
            sz="${BASH_REMATCH[1]}"
            sips -z "$sz" "$sz" "$SOURCE_PNG" --out "$f" >/dev/null
        fi
    done
    echo "✓ Updated round.iconset"
fi

# 7. Clean up
rm -rf "$TMP_DIR"
echo ""
echo "Done! Rebuild the app (swift build or Xcode) to see the new icon."
echo "Note: For the Dock/Finder to pick up the change immediately, run:"
echo "  touch '$REPO_ROOT/Clawbar.app'"
echo "  killall Dock"
