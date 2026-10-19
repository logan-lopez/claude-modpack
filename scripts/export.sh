#!/bin/bash
# Builds dist/<name>-<version>.mrpack from pack/, for importing into Prism or sharing a build.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PACK="$ROOT/pack"

PACKWIZ=$(command -v packwiz || true)
[[ -z $PACKWIZ && -x "$(go env GOPATH 2>/dev/null)/bin/packwiz" ]] && PACKWIZ="$(go env GOPATH)/bin/packwiz"
[[ -n $PACKWIZ ]] || { echo "packwiz not found: go install github.com/packwiz/packwiz@latest" >&2; exit 1; }

toml_value() { sed -nE "s/^$1 = \"(.*)\"$/\\1/p" "$PACK/pack.toml" | head -n1; }
NAME=$(toml_value name | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9.' '-' | sed 's/^-//; s/-$//')
VERSION=$(toml_value version)
OUT="$ROOT/dist/$NAME-$VERSION.mrpack"

mkdir -p "$ROOT/dist"
cd "$PACK"
"$PACKWIZ" refresh >/dev/null
"$PACKWIZ" modrinth export -o "$OUT"
echo "$OUT"
