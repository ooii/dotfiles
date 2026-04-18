#!/usr/bin/env bash
# Auto-bootstrap script that runs inside the test container.
# Invoked by test/run.sh — not meant to be run directly on a host.
#
# What it does on every container start:
#   1. Copy /srv/dotfiles → ~/.local/share/chezmoi (writable for chezmoi)
#   2. Install chezmoi if missing
#   3. Run `chezmoi init --apply` (first run) or `chezmoi apply` (re-runs)
#   4. Hand over to an interactive zsh login shell
#
# Because the container is ephemeral (--rm), this runs fresh every time.

set -e

# --- 1. Copy source (idempotent) ---------------------------------------------
if [[ ! -d "$HOME/.local/share/chezmoi" ]]; then
  mkdir -p "$HOME/.local/share"
  cp -r /srv/dotfiles "$HOME/.local/share/chezmoi"
fi

# --- 2. Install chezmoi if missing -------------------------------------------
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "==> Installing chezmoi"
  curl -fsSL https://get.chezmoi.io | sh -s -- -b "$HOME/.local/bin" >/dev/null
fi

# --- 3. Apply dotfiles -------------------------------------------------------
if [[ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]]; then
  # First run — answer prompts with defaults (non-interactive).
  # Values can be overridden by setting CHEZMOI_EMAIL etc. in the environment.
  : "${CHEZMOI_EMAIL:=test@example.com}"
  : "${CHEZMOI_NAME:=Test User}"
  : "${CHEZMOI_HOSTNAME_OVERRIDE:=}"

  chezmoi init \
    --promptString "email=${CHEZMOI_EMAIL}" \
    --promptString "name=${CHEZMOI_NAME}" \
    --promptString "hostname_override=${CHEZMOI_HOSTNAME_OVERRIDE}" \
    --apply
else
  chezmoi apply
fi

# --- 4. Drop into interactive zsh --------------------------------------------
exec zsh -l
