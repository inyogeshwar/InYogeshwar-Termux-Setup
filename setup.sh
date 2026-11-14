#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO_URL="https://github.com/inyogeshwar/InYogeshwar-Termux-Setup.git"
INSTALL_DIR="$HOME/InYogeshwar-Termux-Setup"
BRANCH="main"

if [[ -z "${PREFIX:-}" || "$PREFIX" != *com.termux* ]] || ! command -v apt >/dev/null 2>&1; then
  echo "Error: Run this installer inside Termux on Android." >&2
  exit 1
fi

echo "InYogeshwar Termux Setup — safe bootstrap"
echo "Step 1/4: Refreshing package indexes..."
apt update || {
  echo "Error: apt update failed. Check Termux repository and network." >&2
  exit 1
}

echo "Step 2/4: Upgrading installed packages..."
apt full-upgrade -y || {
  echo "Error: apt full-upgrade failed. Setup has stopped before installing tools." >&2
  echo "Fix the package manager state, then rerun this script." >&2
  exit 1
}

echo "Step 3/4: Checking Git..."
if ! command -v git >/dev/null 2>&1; then
  apt install -y git || {
    echo "Error: Could not install Git after package upgrade." >&2
    exit 1
  }
fi

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Existing project found. Checking for local changes..."
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
  echo "Downloading project with Git (curl is not required)..."
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

echo "Step 4/4: Launching setup menu..."
exec bash "$INSTALL_DIR/install.sh"
