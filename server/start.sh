#!/bin/bash
# Starts the server in this folder. The first start copies the default settings, installs
# NeoForge (which downloads Minecraft's server) and asks you to accept the Minecraft EULA.
# After a crash it restarts the server; after a `stop` or a failed load it exits.
# Arguments pass through to the server. README.txt has the rest.
set -u

NEOFORGE=@NEOFORGE_VERSION@
ARGS_FILE=libraries/net/neoforged/neoforge/$NEOFORGE/unix_args.txt
TEMURIN=https://adoptium.net/temurin/releases/?version=21

cd "$(dirname "$0")" || exit 1

say() { printf '[start] %s\n' "$*"; }

# 1. Java 21: JAVA_HOME, then on macOS java_home, then java on PATH.
java_version() { "$1" -version 2>&1 | sed -nE 's/.*version "([^"]+)".*/\1/p' | head -n1; }
JAVA='' TRIED=''
try_java() {
  [ -n "$JAVA" ] && return
  local v=''
  [ -n "$2" ] && [ -x "$2" ] && v=$(java_version "$2")
  case $v in
    21|21.*) JAVA=$2 ;;
    '') TRIED="$TRIED  $1: none"$'\n' ;;
    *) TRIED="$TRIED  $1: Java $v ($2)"$'\n' ;;
  esac
}
try_java 'JAVA_HOME' "${JAVA_HOME:+$JAVA_HOME/bin/java}"
[ -x /usr/libexec/java_home ] &&
  try_java '/usr/libexec/java_home -v 21' "$(/usr/libexec/java_home -v 21 2>/dev/null)/bin/java"
try_java 'java on PATH' "$(command -v java)"
if [ -z "$JAVA" ]; then
  say "This server needs Java 21, and none was found. Looked at:"
  printf '%s' "$TRIED"
  say "Install Temurin 21 from $TEMURIN"
  say "A newer Java won't do; Java 21 installs alongside it."
  exit 1
fi
say "Java: $JAVA ($(java_version "$JAVA"))"

# 2. Default settings, only where there's no file yet: an update never overwrites them.
for f in server.properties user_jvm_args.txt; do
  [ -e "$f" ] || cp "defaults/$f" "$f"
done

# 3. NeoForge, on the first start and after an update that changes its version. It leaves an
# existing user_jvm_args.txt alone.
if [ ! -f "$ARGS_FILE" ]; then
  say "Installing NeoForge $NEOFORGE. It downloads Minecraft's server, which takes a minute."
  if ! "$JAVA" -jar "neoforge-$NEOFORGE-installer.jar" --installServer . >/dev/null 2>&1 || [ ! -f "$ARGS_FILE" ]; then
    say "The NeoForge installer failed. The end of its log, neoforge-$NEOFORGE-installer.jar.log:"
    tail -n 20 "neoforge-$NEOFORGE-installer.jar.log" 2>/dev/null
    exit 1
  fi
fi

# 4. The EULA, asked once.
if ! grep -qs '^eula=true' eula.txt; then
  say "Minecraft's EULA: https://aka.ms/MinecraftEULA"
  if [ ! -t 0 ]; then
    say "No terminal to ask in. Run ./start.sh in a terminal, or write eula=true into eula.txt here if you accept it."
    exit 1
  fi
  printf 'Do you accept the Minecraft EULA? [y/N] '
  read -r answer
  case $answer in
    y|Y) printf '# Accepted at the start script'"'"'s prompt: https://aka.ms/MinecraftEULA\neula=true\n' >eula.txt ;;
    *) say "Not accepted. The server can't start without it."; exit 1 ;;
  esac
fi

# 5 and 6. Run, and restart only after a crash: the server reached Done in this run, and a crash
# report appeared during it. NeoForge exits 0 after a failed load too, so the exit code can't
# tell a crash from a stop.
STAMP=$(mktemp "${TMPDIR:-/tmp}/start.XXXXXX") || exit 1
trap 'rm -f "$STAMP"' EXIT
trap 'exit 130' INT TERM
while :; do
  touch "$STAMP"
  "$JAVA" @user_jvm_args.txt "@$ARGS_FILE" nogui "$@"
  code=$?
  if [ logs/latest.log -nt "$STAMP" ] && grep -q 'Done (' logs/latest.log &&
    [ -n "$(find crash-reports -type f -newer "$STAMP" 2>/dev/null)" ]; then
    say 'Server crashed. Restarting in 10 seconds, Ctrl+C to quit.'
    # In the background, so Ctrl+C or a signal to this script ends the wait at once.
    sleep 10 &
    wait $!
    continue
  fi
  say "The server stopped (exit code $code)."
  exit "$code"
done
