#!/usr/bin/env bash
# Iteration loop for testing dotfiles in a fresh Ubuntu container.
#
# Usage:
#   ./test/run.sh                 # hostname "testbox"
#   ./test/run.sh proliant        # simulate a specific machine
#   ./test/run.sh -b              # force rebuild of the image
#   ./test/run.sh -p proliant     # persist atuin/zinit state between runs
#
# The container auto-bootstraps: it copies the repo, installs chezmoi,
# applies the dotfiles, and drops you into zsh. No manual steps.

set -euo pipefail

cd "$(dirname "$0")/.."

IMAGE="dotfiles-test"
PERSIST=false
REBUILD=false
HOST="testbox"

# --- args parsing ------------------------------------------------------------
while (( "$#" )); do
  case "$1" in
    -b|--build)   REBUILD=true; shift ;;
    -p|--persist) PERSIST=true; shift ;;
    -*)           echo "Unknown flag: $1" >&2; exit 1 ;;
    *)            HOST="$1"; shift ;;
  esac
done

# --- build if needed ---------------------------------------------------------
if $REBUILD || ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "==> Building $IMAGE"
  docker build -t "$IMAGE" -f test/Dockerfile.ubuntu .
fi

# --- persistence volume (optional) -------------------------------------------
PERSIST_ARGS=()
if $PERSIST; then
  VOL="dotfiles-test-home-${HOST}"
  echo "==> Using persistent volume: $VOL"
  PERSIST_ARGS=(-v "${VOL}:/home/farid/.local/share")
fi

echo "==> Launching container as hostname=$HOST"
echo ""

docker run --rm -it \
  -h "$HOST" \
  -v "$(pwd):/srv/dotfiles:ro" \
  ${PERSIST_ARGS[@]+"${PERSIST_ARGS[@]}"} \
  --entrypoint bash \
  "$IMAGE" \
  /srv/dotfiles/test/bootstrap-inside.sh