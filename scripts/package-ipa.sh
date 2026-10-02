#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
app=".theos/_/Applications/Solitaire.app"
if [[ ! -d "$app" ]]; then echo "Run make package FINALPACKAGE=1 first." >&2; exit 1; fi
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/Payload" dist
cp -R "$app" "$stage/Payload/"
output="$PWD/dist/Solitaire-1.0.0.ipa"
rm -f "$output"
(cd "$stage" && zip -qr "$output" Payload)
echo "$output"
