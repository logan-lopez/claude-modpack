#!/bin/bash
# Boots a headless NeoForge server from pack/ and fails when a mod crashes or a dependency is
# missing. Exits 0 when the server reaches "Done" with no mod-loading failure.
#
#   CHECK_PORT     port for `packwiz serve` (default 8080)
#   CHECK_TIMEOUT  seconds to wait for "Done" (default 300)
#
# Running it accepts the Minecraft EULA for the throwaway server in run/server/.
# How it works and what it can't catch: docs/architecture/server-check.md.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PACK="$ROOT/pack"
CACHE="$ROOT/run/cache"
SERVER="$ROOT/run/server"
PORT=${CHECK_PORT:-8080}
TIMEOUT=${CHECK_TIMEOUT:-300}
SEED=20261019

# Mod-loading failures in latest.log, copied from a real NeoForge 21.1.264 failure (a missing
# dependency). The server exits 0 after one, so the exit code can't be the signal. See
# docs/architecture/server-check.md before changing them.
FAIL_PATTERNS=(
  'Missing or unsupported mandatory dependencies'
  'Error during pre-loading phase'
  'Failed to start the minecraft server'
)

say() { printf '[check] %s\n' "$*"; }
die() { printf '[check] FAIL: %s\n' "$*" >&2; exit 1; }

# 1. Java 21. The default java here may be older, and run.sh calls whatever is on PATH.
JAVA_HOME=$(/usr/libexec/java_home -v 21 2>/dev/null) || die "no Java 21 found (/usr/libexec/java_home -v 21)"
export JAVA_HOME PATH="$JAVA_HOME/bin:$PATH"

PACKWIZ=$(command -v packwiz || true)
[[ -z $PACKWIZ && -x "$(go env GOPATH 2>/dev/null)/bin/packwiz" ]] && PACKWIZ="$(go env GOPATH)/bin/packwiz"
[[ -n $PACKWIZ ]] || die "packwiz not found: go install github.com/packwiz/packwiz@latest"

toml_value() { sed -nE "s/^$1 = \"(.*)\"$/\\1/p" "$PACK/pack.toml" | head -n1; }
NEOFORGE=$(toml_value neoforge)
[[ -n $NEOFORGE ]] || die "no neoforge version in pack/pack.toml"

# No job control (set -m): its setpgid races here ("child setpgid ... Operation not permitted"),
# and a lost race would aim the kill at a process group that doesn't exist. Kill by PID instead. run.sh doesn't exec java, so kill its
# children first.
SERVE_PID='' SERVER_PID=''
kill_tree() { pkill -P "$1" 2>/dev/null || true; kill "$1" 2>/dev/null || true; wait "$1" 2>/dev/null || true; }
cleanup() {
  exec 3>&- 2>/dev/null || true
  [[ -n $SERVER_PID ]] && kill_tree "$SERVER_PID"
  [[ -n $SERVE_PID ]] && kill_tree "$SERVE_PID"
  rm -f "$SERVER/stdin.fifo"
}
trap cleanup EXIT
trap 'exit 130' INT TERM
trap '' PIPE

# 2. Refresh the index.
(cd "$PACK" && "$PACKWIZ" refresh >/dev/null) || die "packwiz refresh failed"

# 3. Serve the pack.
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  die "port $PORT is in use (a packwiz serve for Prism?). Stop it or set CHECK_PORT."
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

# 4. Install the NeoForge server if the installed one doesn't match the pack.
fetch() { [[ -s $CACHE/$2 ]] || curl -fsSL -o "$CACHE/$2" "$1" || die "download failed: $1"; }
if [[ ! -f "$SERVER/libraries/net/neoforged/neoforge/$NEOFORGE/unix_args.txt" ]]; then
  say "installing NeoForge $NEOFORGE server"
  fetch "https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE/neoforge-$NEOFORGE-installer.jar" \
    "neoforge-$NEOFORGE-installer.jar"
  rm -rf "$SERVER" && mkdir -p "$SERVER"
  (cd "$SERVER" && java -jar "$CACHE/neoforge-$NEOFORGE-installer.jar" --installServer . >"$CACHE/install.log" 2>&1) ||
    die "NeoForge installer failed, see run/cache/install.log"
fi

# 5. Sync the server-side mods, and start from a fresh world.
fetch https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar \
  packwiz-installer-bootstrap.jar
say "syncing mods from http://localhost:$PORT/pack.toml"
(cd "$SERVER" && java -jar "$CACHE/packwiz-installer-bootstrap.jar" --bootstrap-main-jar "$CACHE/packwiz-installer.jar" \
  -g -s server "http://localhost:$PORT/pack.toml" >"$CACHE/sync.log" 2>&1) ||
  die "packwiz-installer failed: $(tail -n10 "$CACHE/sync.log")"
kill_tree "$SERVE_PID"
SERVE_PID=''

cd "$SERVER"
rm -rf world crash-reports logs/latest.log
echo 'eula=true' >eula.txt
printf 'level-seed=%s\n' "$SEED" >server.properties
JARS=$( (find mods -maxdepth 1 -name '*.jar' 2>/dev/null || true) | wc -l | tr -d ' ')

# 6. Start the server, stdin on a FIFO so we can send `stop`.
rm -f stdin.fifo && mkfifo stdin.fifo
say "starting NeoForge $NEOFORGE with $JARS mod jar(s), timeout ${TIMEOUT}s"
START=$SECONDS
./run.sh nogui <stdin.fifo >console.log 2>&1 &
SERVER_PID=$!
exec 3>stdin.fifo

# 7. Watch the log.
LOG=logs/latest.log
RESULT='' REASON=''
while :; do
  if [[ -f $LOG ]] && grep -qE 'Done \([0-9.]+s\)!' "$LOG"; then
    RESULT=pass
    break
  fi
  for p in "${FAIL_PATTERNS[@]}"; do
    if [[ -f $LOG ]] && grep -qF "$p" "$LOG"; then RESULT=fail REASON="log: $p"; break 2; fi
  done
  if compgen -G 'crash-reports/*' >/dev/null; then RESULT=fail REASON="crash report: $(ls crash-reports | head -n1)"; break; fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then RESULT=fail REASON='server exited before Done'; break; fi
  if (( SECONDS - START >= TIMEOUT )); then RESULT=fail REASON="no Done after ${TIMEOUT}s"; break; fi
  sleep 1
done
ELAPSED=$((SECONDS - START))

if [[ $RESULT == pass ]]; then
  echo stop >&3 2>/dev/null || true
  for _ in {1..60}; do kill -0 "$SERVER_PID" 2>/dev/null || break; sleep 1; done
fi
exec 3>&-
kill_tree "$SERVER_PID"
SERVER_PID=''

# 8. Summary.
[[ -f $LOG ]] || LOG=console.log
# The mod table: "Mod List:", a header, then one "\t\tName Version (modid)" row per mod.
LOADED=$(awk '/Mod List:/ {on=1; next} on && /^\[/ {exit} on && /^\t\t.* \([^)]+\)$/ && !/\(Mod Id\)$/ {n++} END {if (on) print n}' "$LOG")
RUNNING=$(sed -nE 's/.*--fml\.neoForgeVersion, ([^,]+),.*/\1/p' "$LOG" | head -n1)
DONE_LINE=$(grep -oE 'Done \([0-9.]+s\)!' "$LOG" | head -n1 || true)
echo
echo "== server check: $(tr '[:lower:]' '[:upper:]' <<<"$RESULT") =="
echo "NeoForge:  ${RUNNING:-$NEOFORGE (from pack.toml, not seen in the log)} (Minecraft $(toml_value minecraft))"
echo "Mods:      ${LOADED:-?} loaded (incl. minecraft and neoforge), $JARS jar(s) in mods/"
echo "Boot:      ${ELAPSED}s wall${DONE_LINE:+, server says $DONE_LINE}"
if [[ $RESULT == pass ]]; then
  ERRORS=$(grep -E '^\[[^]]+\] \[[^]]+/ERROR\]' "$LOG" || true)
  if [[ -n $ERRORS ]]; then
    echo "Warnings:  $(wc -l <<<"$ERRORS" | tr -d ' ') ERROR line(s) in the log (not failing on them):"
    head -n20 <<<"$ERRORS" | sed 's/^/  /'
  fi
  exit 0
fi
echo "Reason:    $REASON"
echo "Log:       run/server/$LOG"
case $REASON in
  log:*)
    grep -nF -A12 "${REASON#log: }" "$LOG" | head -n30 | sed 's/^/  /' ;;
  crash*)
    f=$(ls crash-reports/* | head -n1)
    echo "Crash:     run/server/$f"
    # The description, the exception under it, and for mod-loading crashes each mod's issue.
    grep -E '^Description:|^[[:alnum:]_.$]+(Exception|Error)[:[:space:]]|^-- Mod loading issue|Failure message:' "$f" |
      head -n20 | sed 's/^[[:space:]]*/  /' || true ;;
  *)
    tail -n25 "$LOG" | sed 's/^/  /' ;;
esac
exit 1
