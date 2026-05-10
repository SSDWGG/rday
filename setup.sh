#!/bin/bash
# Rday iOS App - Open in Xcode
set -e

echo "=== Rday iOS App ==="
echo ""

if ! xcode-select -p &>/dev/null; then
    echo "Error: Xcode is not installed."
    exit 1
fi

echo "Opening project in Xcode..."
open Rday.xcodeproj

echo ""
echo "To build from command line:"
echo "  xcodebuild -project Rday.xcodeproj -scheme Rday -destination 'platform=iOS Simulator,name=iPhone 16' build"
