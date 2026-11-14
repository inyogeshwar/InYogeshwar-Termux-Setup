#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO_URL="https://github.com/inyogeshwar/InYogeshwar-Termux-Setup.git"
INSTALL_DIR="$HOME/InYogeshwar-Termux-Setup"
BRANCH="main"

if [[ -z "${PREFIX:-}" || "$PREFIX" != *com.termux* ]] || ! command -v pkg >/dev/null 2>&1; then
  echo "Error: Run this installer inside Termux on Android." >&2
  exit 1
fi

echo "InYogeshwar Termux Setup — bootstrap"
if ! command -v git >/dev/null 2>&1; then
  pkg install -y git
fi

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Existing project found. Updating from GitHub..."
  current_remote="$(git -C "$INSTALL_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ "$current_remote" != "$REPO_URL" && "$current_remote" != "https://github.com/inyogeshwar/InYogeshwar-Termux-Setup" ]]; then
    echo "Error: $INSTALL_DIR exists but origin is not the expected repository." >&2
    echo "No files were changed. Inspect the folder before proceeding." >&2
    exit 1
  fi
  if ! git -C "$INSTALL_DIR" diff --quiet || ! git -C "$INSTALL_DIR" diff --cached --quiet; then
    echo "Error: Local changes detected in $INSTALL_DIR." >&2
    echo "Commit or back up those changes, then rerun this command." >&2
    exit 1
  fi
  git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"
elif [[ -e "$INSTALL_DIR" ]]; then
  echo "Error: $INSTALL_DIR exists but is not a Git repository." >&2
  echo "Move or rename that folder yourself; installer will not overwrite it." >&2
  exit 1
else
  echo "Downloading project..."
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

echo
echo "Launching the interactive setup menu..."
exec bash "$INSTALL_DIR/install.sh"
