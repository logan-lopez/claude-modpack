#!/bin/bash
# Builds dist/<name>-<version>-server.zip: a server that unzips and starts with start.sh or
# start.bat, with the server-side mods, configs, KubeJS data and gun packs inside. NeoForge's
# installer runs on the server's first start, because Minecraft's server jar can't be shipped.
#
#   SERVE_PORT  port for `packwiz serve` (default 8080)
#
# How it works and what the start scripts do: docs/architecture/server-pack.md.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PACK="$ROOT/pack"
CACHE="$ROOT/run/cache"
PORT=${SERVE_PORT:-8080}

say() { printf '[server-pack] %s\n' "$*"; }
die() { printf '[server-pack] FAIL: %s\n' "$*" >&2; exit 1; }

# 1. Java 21, packwiz, and the pack's name and versions.
JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null) || die "no Java 21 found (/usr/libexec/java_home -v 21)"
export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"

PACKWIZ=$(command -v packwiz || true)
[[ -z $PACKWIZ && -x "$(go env GOPATH 2>/dev/null)/bin/packwiz" ]] && PACKWIZ="$(go env GOPATH)/bin/packwiz"
[[ -n $PACKWIZ ]] || die "packwiz not found: go install github.com/packwiz/packwiz@latest"

toml_value() { sed -nE "s/^$1 = \"(.*)\"$/\\1/p" "$PACK/pack.toml" | head -n1; }
TITLE=$(toml_value name)
NAME=$(tr '[:upper:]' '[:lower:]' <<<"$TITLE" | tr -cs 'a-z0-9.' '-' | sed 's/^-//; s/-$//')
VERSION=$(toml_value version)
NEOFORGE=$(toml_value neoforge)
[[ -n $NEOFORGE ]] || die "no neoforge version in pack/pack.toml"
DIR="$NAME-$VERSION-server"
STAGE="$ROOT/run/server-pack"
OUT="$ROOT/dist/$DIR.zip"

SERVE_PID=''
kill_serve() { [[ -n $SERVE_PID ]] || return 0; kill "$SERVE_PID" 2>/dev/null || true; wait "$SERVE_PID" 2>/dev/null || true; SERVE_PID=''; }
trap kill_serve EXIT
trap 'exit 130' INT TERM

(cd "$PACK" && "$PACKWIZ" refresh >/dev/null) || die "packwiz refresh failed"

# 2. Serve the pack.
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  die "port $PORT is in use (a packwiz serve for Prism?). Stop it or set SERVE_PORT."
fi
mkdir -p "$CACHE"
(cd "$PACK" && exec "$PACKWIZ" serve -p "$PORT" >"$CACHE/serve.log" 2>&1) &
SERVE_PID=$!
for _ in {1..30}; do
  curl -fsS "http://localhost:$PORT/pack.toml" >/dev/null 2>&1 && break
  kill -0 "$SERVE_PID" 2>/dev/null || die "packwiz serve exited: $(tail -n5 "$CACHE/serve.log")"
  sleep 0.5
done
curl -fsS "http://localhost:$PORT/pack.toml" >/dev/null || die "packwiz serve not answering on port $PORT"

# 3. The NeoForge installer and the packwiz bootstrap, cached.
fetch() { [[ -s $CACHE/$2 ]] || curl -fsSL -o "$CACHE/$2" "$1" || die "download failed: $1"; }
INSTALLER="neoforge-$NEOFORGE-installer.jar"
fetch "https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE/$INSTALLER" "$INSTALLER"
fetch https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar \
  packwiz-installer-bootstrap.jar

# 4. Sync the server side of the pack into a fresh staging folder.
rm -rf "$STAGE" && mkdir -p "$STAGE/$DIR"
say "syncing the server side of the pack from http://localhost:$PORT/pack.toml"
(cd "$STAGE/$DIR" && java -jar "$CACHE/packwiz-installer-bootstrap.jar" --bootstrap-main-jar "$CACHE/packwiz-installer.jar" \
  -g -s server "http://localhost:$PORT/pack.toml" >"$CACHE/server-pack-sync.log" 2>&1) ||
  die "packwiz-installer failed: $(tail -n10 "$CACHE/server-pack-sync.log")"
kill_serve
rm -f "$STAGE/$DIR/packwiz.json"

# 5. The installer, the start scripts, the README and the defaults.
cd "$STAGE/$DIR"
cp "$CACHE/$INSTALLER" .
cp "$ROOT/server/start.sh" "$ROOT/server/start.bat" "$ROOT/server/README.txt" .
cp -R "$ROOT/server/defaults" .
for f in start.sh start.bat defaults/server.properties; do
  sed -i '' -e "s/@NEOFORGE_VERSION@/$NEOFORGE/g" -e "s/@MOTD@/$TITLE $VERSION/g" "$f"
done
# CRLF whatever the checkout did: cmd.exe misreads labels and goto in a .bat with LF endings.
perl -pi -e 's/\r?\n/\r\n/' start.bat
chmod 755 start.sh
if grep -rlE '@(NEOFORGE_VERSION|MOTD)@' start.sh start.bat README.txt defaults; then
  die "a placeholder is left in the files above"
fi
JARS=$(find mods -maxdepth 1 -name '*.jar' | wc -l | tr -d ' ')

# 6. Zip it. zip -r would add to an old zip of the same name, so replace it.
mkdir -p "$ROOT/dist"
rm -f "$OUT"
(cd "$STAGE" && zip -qrX "$OUT" "$DIR")
echo
echo "== server pack: $(du -h "$OUT" | cut -f1 | tr -d ' ') =="
echo "NeoForge:  $NEOFORGE (installed on first start)"
echo "Mods:      $JARS jar(s) in mods/"
echo "$OUT"
