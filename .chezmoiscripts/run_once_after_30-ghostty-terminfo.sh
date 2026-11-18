#!/usr/bin/env bash
# Install Ghostty's terminfo (xterm-ghostty, ghostty) into ~/.terminfo.
# macOS's ncurses doesn't know xterm-ghostty; Ghostty only points to its own copy
# through $TERMINFO, which sudo and other env-cleaning launchers drop. Without it,
# top / htop / less fail with "Error opening terminal: xterm-ghostty".
# ~/.terminfo is always searched, so TUIs work whether $TERMINFO is set or not.
# Runs once. Safe to re-run.
set -euo pipefail

src="/Applications/Ghostty.app/Contents/Resources/terminfo"
if [[ ! -d "$src" ]]; then
  echo "==> Ghostty not installed, skipping terminfo"
  exit 0
fi

echo "==> Installing Ghostty terminfo into ~/.terminfo"
TERMINFO="$src" infocmp -x xterm-ghostty | tic -x -o "$HOME/.terminfo" - 2>/dev/null
