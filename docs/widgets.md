---
summary: "WidgetKit snapshot pipeline + visibility troubleshooting for Clawbar widgets."
read_when:
  - Modifying WidgetKit extension behavior or snapshot format
  - Debugging widget update timing
  - Widget gallery shows no Clawbar widgets
---

# Widgets

## Snapshot pipeline
- `WidgetSnapshotStore` writes compact JSON snapshots to the app-group container.
- Widgets read the snapshot and render usage/credits/history states.

## Extension
- `Sources/CodexBarWidget` contains timeline + views.
- Keep data shape in sync with `WidgetSnapshot` in the main app.

## Visibility troubleshooting (macOS 14+)
When widgets do not appear in the gallery at all, the issue is almost always
registration, signing, or daemon caching (not SwiftUI code).

### 1) Verify the extension bundle exists where macOS expects it
```
APP="/Applications/Clawbar.app"
WAPPEX="$APP/Contents/PlugIns/ClawbarWidget.appex"

ls -la "$WAPPEX" "$WAPPEX/Contents" "$WAPPEX/Contents/MacOS"
```

### 2) PlugInKit registration (pkd)
```
pluginkit -m -p com.apple.widgetkit-extension -v | grep -i clawbar || true
pluginkit -m -p com.apple.widgetkit-extension -i com.steipete.clawbar.widget -vv
```
Notes:
- `+` = elected to use, `-` = ignored (PlugInKit elections).
- If missing or ignored, force-add and re-elect:
```
pluginkit -a "$WAPPEX"
pluginkit -e use -p com.apple.widgetkit-extension -i com.steipete.clawbar.widget
```
- Check for duplicates (old installs or version precedence):
```
pluginkit -m -D -p com.apple.widgetkit-extension -i com.steipete.clawbar.widget -vv
```
If multiple paths appear, delete older installs and bump `CFBundleVersion`.

### 3) Code signing + Gatekeeper assessment
Widgets are loaded by system daemons. Any signing failure can hide the widget.
```
codesign --verify --deep --strict --verbose=4 /Applications/Clawbar.app
codesign --verify --strict --verbose=4 "$WAPPEX"
codesign --verify --strict --verbose=4 "$WAPPEX/Contents/MacOS/ClawbarWidget"
spctl --assess --type execute --verbose=4 /Applications/Clawbar.app
```

### 4) Restart the right daemons (NotificationCenter alone is not enough)
```
killall -9 pkd || true
sudo killall -9 chronod || true
killall Dock NotificationCenter || true
```

### 5) Watch logs while opening the widget gallery
```
log stream --style compact --predicate '(process == "pkd" OR process == "chronod" OR subsystem CONTAINS "PlugInKit" OR subsystem CONTAINS "WidgetKit")'
```

### 6) Packaging sanity checks
- Widget bundle id should be `com.steipete.clawbar.widget`.
- `NSExtensionPointIdentifier` must be `com.apple.widgetkit-extension`.
- Bundle folder name should match: `ClawbarWidget.appex`.

Optional: re-seed LaunchServices (rarely helps, but low risk):
```
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -seed
```

## Common post-visibility issue: stale data
If the widget appears but always shows preview data:
- App writes snapshot to fallback path while widget reads app-group container.
- Validate that both app and widget resolve the same app-group container.

See also: `docs/ui.md`, `docs/packaging.md`.
