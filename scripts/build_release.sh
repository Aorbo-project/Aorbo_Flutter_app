#!/usr/bin/env bash
# Aorbo release builds — ALWAYS obfuscated.
#
#   scripts/build_release.sh aab   # Play Console upload (bump pubspec +N first!)
#   scripts/build_release.sh apk   # arm64-v8a split APK for sideload testing
#
# --obfuscate renames Dart classes/functions in the compiled app so a
# decompiled APK no longer reads like our source (R8 already does the same
# for the Java/Kotlin side — minifyEnabled in android/app/build.gradle).
#
# --split-debug-info writes the symbol map to debug-symbols/<version>/
# (gitignored). KEEP IT for every build that ships: without it, obfuscated
# stack traces (Crashlytics, admin Crash Analytics) cannot be decoded.
#   Decode one:  flutter symbolize -i trace.txt -d debug-symbols/<version>/app.android-arm64.symbols
#   Crashlytics: firebase crashlytics:symbols:upload --app=<android appId> debug-symbols/<version>
#                (done automatically below when the firebase CLI is installed)
set -euo pipefail
cd "$(dirname "$0")/.."

kind="${1:-}"
version="$(grep -E '^version:' pubspec.yaml | awk '{print $2}')"
symbols="debug-symbols/${version}"
android_app_id="1:979616910593:android:fad40c7486469a7e9d9f00"

case "$kind" in
  aab)
    flutter build appbundle --release --obfuscate --split-debug-info="$symbols"
    out="build/app/outputs/bundle/release/app-release.aab"
    ;;
  apk)
    flutter build apk --release --split-per-abi --target-platform android-arm64 \
      --obfuscate --split-debug-info="$symbols"
    out="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
    ;;
  *)
    echo "usage: $0 aab|apk" >&2
    exit 2
    ;;
esac

if command -v firebase >/dev/null 2>&1; then
  firebase crashlytics:symbols:upload --app="$android_app_id" "$symbols" \
    || echo "WARN: Crashlytics symbol upload failed — upload $symbols manually."
else
  echo "NOTE: firebase CLI not found — Crashlytics symbols NOT uploaded ($symbols)."
fi

echo "Built  : $out"
echo "Version: $version"
echo "Symbols: $symbols   <-- keep this folder"
