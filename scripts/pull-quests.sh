#!/bin/bash
# Copies the quest book from a Prism instance back into pack/config/ftbquests/quests/, so changes
# made in FTB Quests' in-game editor can be committed. It doesn't commit.
#
#   scripts/pull-quests.sh [instance's minecraft folder]
#     default: ~/Library/Application Support/PrismLauncher/instances/Claude Modpack/minecraft
#   FORCE=1  copy even when pack/'s quest book has uncommitted changes
#
# The pack's book is the source of truth: docs/architecture/quests.md.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PACK="$ROOT/pack"
QUESTS="$PACK/config/ftbquests/quests"
SOURCE=${1:-"$HOME/Library/Application Support/PrismLauncher/instances/Claude Modpack/minecraft"}
FROM="$SOURCE/config/ftbquests/quests"

say() { printf '[pull-quests] %s\n' "$*"; }
die() { printf '[pull-quests] FAIL: %s\n' "$*" >&2; exit 1; }

# FTB Quests writes editor changes when the world saves, so a running game may not have yet.
say "quit the world (to the title screen or out of the game) first, so FTB Quests has saved the editor's changes"

PACKWIZ=$(command -v packwiz || true)
[[ -z $PACKWIZ && -x "$(go env GOPATH 2>/dev/null)/bin/packwiz" ]] && PACKWIZ="$(go env GOPATH)/bin/packwiz"
[[ -n $PACKWIZ ]] || die "packwiz not found: go install github.com/packwiz/packwiz@latest"

[[ -d $FROM ]] || die "no quest book at $FROM (is that an instance's minecraft folder, and has it synced?)"

# Uncommitted changes could be quests another tool just wrote; the copy would wipe them.
cd "$ROOT"
DIRTY=$(git status --porcelain -- "${QUESTS#"$ROOT"/}")
if [[ -n $DIRTY && ${FORCE:-} != 1 ]]; then
  printf '%s\n' "$DIRTY" | sed 's/^/  /' >&2
  die "pack/config/ftbquests/quests has uncommitted changes (above). Commit or stash them, or run with FORCE=1 to overwrite them."
fi

say "copying $FROM"
mkdir -p "$QUESTS"
# *.tmp: FTB Library writes each file to <name>.tmp and renames it, so one is only left by a crash.
rsync -a --delete --exclude '*.tmp' "$FROM/" "$QUESTS/"
(cd "$PACK" && "$PACKWIZ" refresh >/dev/null) || die "packwiz refresh failed"

echo
git status --short -- pack/config/ftbquests pack/index.toml
git diff --stat -- pack/config/ftbquests pack/index.toml
