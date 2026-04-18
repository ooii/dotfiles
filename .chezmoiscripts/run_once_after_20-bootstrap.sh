#!/usr/bin/env bash
# Bootstrap atuin DB on first apply (creates ~/.local/share/atuin).
# Runs once. Safe to re-run.
set -euo pipefail

if command -v atuin >/dev/null 2>&1; then
  if [[ ! -d "$HOME/.local/share/atuin" ]]; then
    echo "==> Initializing atuin local history database"
    # Try to import existing shell history if any; silence the "NO_SHELL" noise
    # (harmless — just means there's nothing to import on a fresh system)
    atuin import auto >/dev/null 2>&1 || true
  fi
fi

echo "==> Dotfiles apply complete. Start a new zsh session to see the prompt."