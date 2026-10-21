#!/bin/bash
# Boots a headless NeoForge server from pack/ and fails when a mod crashes or a dependency is
# missing, or when the quest book in pack/config/ftbquests/quests/ doesn't load as written. Exits 0
# when the server reaches "Done" with no mod-loading failure and the book loads clean.
#
#   CHECK_PORT     port for `packwiz serve` (default 8080)
#   CHECK_TIMEOUT  seconds to wait for "Done" (default 300)
#   CHECK_UPDATE_BASELINE=1  after a pass, rewrite scripts/server-check.known-errors.txt from this run
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
BASELINE="$ROOT/scripts/server-check.known-errors.txt"

# Mod-loading failures in latest.log, copied from a real NeoForge 21.1.264 failure (a missing
# dependency). The server exits 0 after one, so the exit code can't be the signal. See
# docs/architecture/server-check.md before changing them.
FAIL_PATTERNS=(
  'Missing or unsupported mandatory dependencies'
  'Error during pre-loading phase'
  'Failed to start the minecraft server'
)

# The quest book, when pack/ has one. FTB Quests 2101.1.36 loads it after Done (on server start)
# and logs these two lines around the load even when a chapter fails to parse; every ERROR line
# between them is about the book. Copied from a real run, see docs/architecture/quests.md.
QUESTS="$PACK/config/ftbquests/quests"
SERVER_QUESTS="$SERVER/config/ftbquests/quests"
QUEST_LOADING='[FTB Quests/]: Loading quests from '
QUEST_LOADED='\[FTB Quests/\]: Loaded [0-9]+ chapter groups, [0-9]+ chapters, [0-9]+ quests, [0-9]+ reward tables'

say() { printf '[check] %s\n' "$*"; }
die() { printf '[check] FAIL: %s\n' "$*" >&2; exit 1; }

# Load errors keyed by kind and ID ("recipe create:foo"), sorted and unique: the baseline's format.
# Data loads twice per boot, so most IDs are logged twice. KEYED matches the lines this keys, so
# the summary can show the rest raw; change both together.
ERROR_LINE='^\[[^]]+\] \[[^]]+/ERROR\]'
KEYED='Parsing error loading recipe |Couldn.t parse element ResourceKey\[minecraft:root / minecraft:loot_table\]:|Couldn.t parse data file |DataMapLoader/[^]]*\]: Object with ID |Couldn.t load advancements: \['
load_error_keys() {
  local errors
  errors=$(grep -E "$ERROR_LINE" "$1" || true)
  {
    sed -nE \
      -e 's/.*: Parsing error loading recipe ([^ ]+): .*/recipe \1/p' \
      -e 's/.*: Couldn.t parse element ResourceKey\[minecraft:root \/ minecraft:loot_table\]:([^ ]+) - .*/loot \1/p' \
      -e 's/.*: Couldn.t parse data file ([^ ]+) from .*/datafile \1/p' \
      -e 's/.*DataMapLoader\/[^]]*\]: Object with ID ([^ ]+) .*/datamap \1/p' <<<"$errors"
    sed -nE 's/.*: Couldn.t load advancements: \[(.*)\].*/\1/p' <<<"$errors" | tr ',' '\n' | sed -E 's/^ *//; /^$/d; s/^/advancement /'
  } | LC_ALL=C sort -u
}
# Prints up to 20 lines of $2, indented under the label $1, and a count of the rest.
list_some() {
  [[ -n $2 ]] || return 0
  local n
  n=$(wc -l <<<"$2" | tr -d ' ')
  head -n20 <<<"$2" | sed "s/^/  $1 /"
  (( n > 20 )) && echo "  ... and $((n - 20)) more"
  return 0
}

# 1. Java 21: JAVA_HOME, then on macOS java_home, then java on PATH. The default java may be older.
java_version() { "$1" -version 2>&1 | sed -nE 's/.*version "([^"]+)".*/\1/p' | head -n1; }
JAVA=''
for j in "${JAVA_HOME:+$JAVA_HOME/bin/java}" \
  "$([[ -x /usr/libexec/java_home ]] && /usr/libexec/java_home -v 21 2>/dev/null)/bin/java" \
  "$(command -v java || true)"; do
  [[ -n $j && -x $j ]] || continue
  case $(java_version "$j") in 21|21.*) JAVA=$j; break ;; esac
done
[[ -n $JAVA ]] || die "no Java 21 found (JAVA_HOME, /usr/libexec/java_home -v 21, java on PATH)"
# NeoForge's installer writes the JVM arguments for each system; Git Bash on Windows needs win_args.
case $(uname -s) in MINGW*|MSYS*|CYGWIN*) ARGS_TXT=win_args.txt ;; *) ARGS_TXT=unix_args.txt ;; esac

PACKWIZ=$(command -v packwiz || true)
[[ -z $PACKWIZ && -x "$(go env GOPATH 2>/dev/null)/bin/packwiz" ]] && PACKWIZ="$(go env GOPATH)/bin/packwiz"
[[ -n $PACKWIZ ]] || die "packwiz not found: go install github.com/packwiz/packwiz@latest"

toml_value() { sed -nE "s/^$1 = \"(.*)\"$/\\1/p" "$PACK/pack.toml" | head -n1; }
NEOFORGE=$(toml_value neoforge)
[[ -n $NEOFORGE ]] || die "no neoforge version in pack/pack.toml"

# No job control (set -m): its setpgid races here ("child setpgid ... Operation not permitted"),
# and a lost race would aim the kill at a process group that doesn't exist. Kill by PID instead.
# Both PIDs are the program itself (exec, and java run directly), so there are no children to kill.
SERVE_PID='' SERVER_PID=''
kill_pid() { kill "$1" 2>/dev/null || true; wait "$1" 2>/dev/null || true; }
# `wait` on the server waits for its whole pipeline, and the stdin loop in it ends only once
# stop-requested exists, so every stop creates it first, a fail too. Without it, a fail hangs.
stop_server() { touch "$SERVER/stop-requested"; kill_pid "$SERVER_PID"; SERVER_PID=''; }
# Returns 0 itself: under set -e, a false test in an EXIT trap becomes the script's exit code.
cleanup() {
  if [[ -n $SERVER_PID ]]; then stop_server; fi
  if [[ -n $SERVE_PID ]]; then kill_pid "$SERVE_PID"; fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM
trap '' PIPE

# 2. Refresh the index.
(cd "$PACK" && "$PACKWIZ" refresh >/dev/null) || die "packwiz refresh failed"

# 3. Serve the pack. Git Bash on Windows has netstat but no lsof.
port_in_use() {
  if command -v lsof >/dev/null; then lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1
  else netstat -an 2>/dev/null | grep -Eq "[:.]$1[[:space:]].*LISTEN"; fi
}
if port_in_use "$PORT"; then
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
ARGS="libraries/net/neoforged/neoforge/$NEOFORGE/$ARGS_TXT"
if [[ ! -f "$SERVER/$ARGS" ]]; then
  say "installing NeoForge $NEOFORGE server"
  fetch "https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE/neoforge-$NEOFORGE-installer.jar" \
    "neoforge-$NEOFORGE-installer.jar"
  rm -rf "$SERVER" && mkdir -p "$SERVER"
  (cd "$SERVER" && "$JAVA" -jar "$CACHE/neoforge-$NEOFORGE-installer.jar" --installServer . >"$CACHE/install.log" 2>&1) ||
    die "NeoForge installer failed, see run/cache/install.log"
fi

# 5. Sync the server-side mods, and start from a fresh world. The quest book goes first: configs
# persist between runs, and FTB Quests writes its folder, so the server must read only pack/'s.
fetch https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar \
  packwiz-installer-bootstrap.jar
rm -rf "$SERVER_QUESTS"
say "syncing mods from http://localhost:$PORT/pack.toml"
(cd "$SERVER" && "$JAVA" -jar "$CACHE/packwiz-installer-bootstrap.jar" --bootstrap-main-jar "$CACHE/packwiz-installer.jar" \
  -g -s server "http://localhost:$PORT/pack.toml" >"$CACHE/sync.log" 2>&1) ||
  die "packwiz-installer failed: $(tail -n10 "$CACHE/sync.log")"
kill_pid "$SERVE_PID"
SERVE_PID=''
if [[ -d $QUESTS ]] && ! DIFF=$(diff -rq "$QUESTS" "$SERVER_QUESTS" 2>&1); then
  die "the sync didn't install pack/config/ftbquests/quests as it is: $DIFF"
fi

cd "$SERVER"
rm -rf world crash-reports logs/latest.log stop-requested
echo 'eula=true' >eula.txt
printf 'level-seed=%s\n' "$SEED" >server.properties
JARS=$( (find mods -maxdepth 1 -name '*.jar' 2>/dev/null || true) | wc -l | tr -d ' ')

# 6. Start the server: java run directly, as run.sh and run.bat do. Its stdin is a pipe from a loop
# that sends `stop` once the file stop-requested exists, and gives up when this script is gone.
# A pipe rather than a FIFO, because Git Bash's FIFOs don't reach a Windows program.
say "starting NeoForge $NEOFORGE with $JARS mod jar(s), timeout ${TIMEOUT}s"
START=$SECONDS
{
  until [[ -e stop-requested ]]; do kill -0 $$ 2>/dev/null || exit 0; sleep 1; done
  echo stop
} | "$JAVA" @user_jvm_args.txt "@$ARGS" nogui >console.log 2>&1 &
SERVER_PID=$!

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
  # The quest book loads a fraction of a second after Done.
  if [[ -d $QUESTS ]]; then
    for _ in {1..10}; do grep -qE "$QUEST_LOADED" "$LOG" && break; sleep 1; done
  fi
  touch stop-requested
  for _ in {1..60}; do kill -0 "$SERVER_PID" 2>/dev/null || break; sleep 1; done
fi
stop_server

# Log4j ends lines with CRLF on Windows, so read the log through tr.
[[ -f $LOG ]] || LOG=console.log
TEXT=$CACHE/check.log
tr -d '\r' <"$LOG" >"$TEXT"

# The quest book loaded as written: no ERROR line during the load, every chapter and reward table
# in pack/ counted, and nothing rewritten when the server saved it on stop. FTB Quests skips a
# chapter it can't parse, and quietly renumbers a bad or duplicate ID and writes the book back.
# On Windows it writes CRLF, so the comparison ignores carriage returns.
QUEST_LOAD='' QUEST_ERRORS='' QUEST_WRITES=''
if [[ $RESULT == pass && -d $QUESTS ]]; then
  QUEST_LOAD=$(grep -oE "$QUEST_LOADED" "$TEXT" | tail -n1 | sed -E 's/.*Loaded //')
  QUEST_ERRORS=$(awk -v from="$QUEST_LOADING" 'index($0, from) {on=1; next} on && /\[FTB Quests\/\]: Loaded / {exit}
    on && /^\[[^]]+\] \[Server thread\/ERROR\]/' "$TEXT" | sed -E 's/^\[[^]]+\] //')
  QUEST_WRITES=$(diff -rq --strip-trailing-cr "$QUESTS" "$SERVER_QUESTS" 2>&1 | sed -e "s|$QUESTS/*|pack: |g" -e "s|$SERVER_QUESTS/*|server: |g" || true)
  have=$( (find "$QUESTS/chapters" -maxdepth 1 -name '*.snbt' 2>/dev/null || true) | wc -l | tr -d ' ')
  tables=$( (find "$QUESTS/reward_tables" -maxdepth 1 -name '*.snbt' 2>/dev/null || true) | wc -l | tr -d ' ')
  problems=()
  if [[ -z $QUEST_LOAD ]]; then
    problems+=("no 'Loaded ... reward tables' line from FTB Quests")
  else
    loaded=$(sed -E 's/.*, ([0-9]+) chapters,.*/\1/' <<<"$QUEST_LOAD")
    loaded_tables=$(sed -E 's/.*, ([0-9]+) reward tables/\1/' <<<"$QUEST_LOAD")
    (( loaded < have )) && problems+=("loaded $loaded of $have chapters")
    (( loaded_tables < tables )) && problems+=("loaded $loaded_tables of $tables reward tables")
  fi
  [[ -n $QUEST_ERRORS ]] && problems+=("$(wc -l <<<"$QUEST_ERRORS" | tr -d ' ') ERROR line(s) while loading the book")
  [[ -n $QUEST_WRITES ]] && problems+=("FTB Quests rewrote the book on save ($(wc -l <<<"$QUEST_WRITES" | tr -d ' ') file(s))")
  if (( ${#problems[@]} )); then
    RESULT=fail REASON="quests: $(printf '%s; ' "${problems[@]}" | sed 's/; $//')"
  fi
fi

# 8. Summary.
# The mod table: "Mod List:", a header, then one "\t\tName Version (modid)" row per mod.
LOADED=$(awk '/Mod List:/ {on=1; next} on && /^\[/ {exit} on && /^\t\t.* \([^)]+\)$/ && !/\(Mod Id\)$/ {n++} END {if (on) print n}' "$TEXT")
RUNNING=$(sed -nE 's/.*--fml\.neoForgeVersion, ([^,]+),.*/\1/p' "$TEXT" | head -n1)
DONE_LINE=$(grep -oE 'Done \([0-9.]+s\)!' "$TEXT" | head -n1 || true)
echo
echo "== server check: $(tr '[:lower:]' '[:upper:]' <<<"$RESULT") =="
echo "NeoForge:  ${RUNNING:-$NEOFORGE (from pack.toml, not seen in the log)} (Minecraft $(toml_value minecraft))"
echo "Mods:      ${LOADED:-?} loaded (incl. minecraft and neoforge), $JARS jar(s) in mods/"
echo "Boot:      ${ELAPSED}s wall${DONE_LINE:+, server says $DONE_LINE}"
if [[ $RESULT == pass ]]; then
  [[ -n $QUEST_LOAD ]] && echo "Quests:    $QUEST_LOAD"
  # Load errors against the baseline. New ones are reported, never failed on.
  KEYS=$(load_error_keys "$TEXT")
  count() { [[ -n $1 ]] && wc -l <<<"$1" | tr -d ' ' || echo 0; }
  if [[ -f $BASELINE ]]; then
    KNOWN=$(tr -d '\r' <"$BASELINE" | LC_ALL=C sort -u)
    NEW=$(LC_ALL=C comm -13 <(echo "$KNOWN") <(echo "$KEYS") | sed '/^$/d')
    GONE=$(LC_ALL=C comm -23 <(echo "$KNOWN") <(echo "$KEYS") | sed '/^$/d')
    STILL=$(LC_ALL=C comm -12 <(echo "$KNOWN") <(echo "$KEYS") | sed '/^$/d')
    echo "Load errors: $(count "$STILL") known, $(count "$NEW") new, $(count "$GONE") gone"
    list_some 'new: ' "$NEW"
    list_some 'gone:' "$GONE"
  else
    echo "Load errors: $(count "$KEYS") keys, no baseline (CHECK_UPDATE_BASELINE=1 writes ${BASELINE#"$ROOT"/})"
  fi
  # ERROR lines of no known kind, without their timestamps, so repeats collapse.
  OTHER=$(grep -E "$ERROR_LINE" "$TEXT" | grep -vE "$KEYED" | sed -E 's/^\[[^]]+\] //' || true)
  if [[ -n $OTHER ]]; then
    echo "Warnings:  $(count "$OTHER") other ERROR line(s) in the log (not failing on them):"
    awk '!seen[$0]++' <<<"$OTHER" | head -n20 | sed 's/^/  /'
  fi
  if [[ ${CHECK_UPDATE_BASELINE:-} == 1 ]]; then
    printf '%s\n' "$KEYS" | sed '/^$/d' >"$BASELINE"
    echo "Baseline:  rewrote ${BASELINE#"$ROOT"/} ($(count "$KEYS") keys)"
  fi
  exit 0
fi
echo "Reason:    $REASON"
echo "Log:       run/server/$LOG"
case $REASON in
  quests:*)
    [[ -n $QUEST_LOAD ]] && echo "Quests:    $QUEST_LOAD"
    [[ -n $QUEST_ERRORS ]] && awk '!seen[$0]++' <<<"$QUEST_ERRORS" | head -n20 | sed 's/^/  /'
    if [[ -n $QUEST_WRITES ]]; then
      echo "Rewritten: (pack: is pack/config/ftbquests/quests, server: is what FTB Quests saved)"
      sed 's/^/  /' <<<"$QUEST_WRITES"
      diff -r --strip-trailing-cr "$QUESTS" "$SERVER_QUESTS" 2>/dev/null | sed -e "s|$QUESTS/*|pack: |g" -e "s|$SERVER_QUESTS/*|server: |g" |
        head -n30 | sed 's/^/  /' || true
    fi ;;
  log:*)
    grep -nF -A12 "${REASON#log: }" "$TEXT" | head -n30 | sed 's/^/  /' ;;
  crash*)
    f=$(ls crash-reports/* | head -n1)
    echo "Crash:     run/server/$f"
    # The description, the exception under it, and for mod-loading crashes each mod's issue.
    grep -E '^Description:|^[[:alnum:]_.$]+(Exception|Error)[:[:space:]]|^-- Mod loading issue|Failure message:' "$f" |
      head -n20 | sed 's/^[[:space:]]*/  /' || true ;;
  *)
    tail -n25 "$TEXT" | sed 's/^/  /' ;;
esac
exit 1
