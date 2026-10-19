#!/bin/zsh
# Regenerates the AppIcon and LaunchMark PNGs in BranchiOS/App/Assets.xcassets from the SwiftUI logo views.
set -euo pipefail
here="${0:A:h}"; root="${here:h}"
tmp="$(mktemp -d)"
cp "$here/render-app-assets.swift" "$tmp/main.swift"
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
swiftc -o "$tmp/render" "$root/Sources/BranchiOS/YaYaLogo.swift" "$root/Sources/BranchiOS/BlinkClock.swift" "$tmp/main.swift"
"$tmp/render" "$root/App/Assets.xcassets"
rm -rf "$tmp"
