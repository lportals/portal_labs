#!/bin/bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web if not enabled
flutter config --enable-web

# Build the project
flutter build web --release --wasm
