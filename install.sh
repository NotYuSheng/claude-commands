#!/usr/bin/env bash
# install.sh — symlink Claude commands into ~/.claude/commands/
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/commands"

mkdir -p "$TARGET_DIR"

echo "Installing commands into $TARGET_DIR ..."

for cmd in "$REPO_DIR/commands/"*.md; do
  name="$(basename "$cmd")"
  dest="$TARGET_DIR/$name"
  if [ -L "$dest" ]; then
    echo "  (update) $name"
  elif [ -e "$dest" ]; then
    echo "  (skip)   $name — file already exists at $dest (not a symlink, skipping)"
    continue
  else
    echo "  (add)    $name"
  fi
  ln -sf "$cmd" "$dest"
done

installed=$(ls "$REPO_DIR/commands/"*.md | xargs -I{} basename {} .md | tr '\n' ' ')
echo ""
echo "Done. Commands available: $installed"
