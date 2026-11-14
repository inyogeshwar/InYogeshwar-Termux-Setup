#!/data/data/com.termux/files/usr/bin/bash

install_base() {
  show_banner
  info "Refreshing Termux package indexes..."
  if ! apt update; then
    err "APT index refresh failed. Check your Termux repository and network."
    return 1
  fi

  info "Upgrading installed packages to prevent mixed library versions..."
  if ! apt full-upgrade -y; then
    err "Package upgrade failed. No dependency installation will be attempted."
    err "Run: apt update && apt full-upgrade"
    return 1
  fi

  info "Installing base development packages..."
  if ! pkg install -y git curl wget ca-certificates openssl nodejs-lts python python-pip nano vim zip unzip tar jq zsh; then
    err "Base package installation failed. Review the log and repair packages before retrying."
    return 1
  fi

  ok "Base package step finished."
  printf 'Node: '; node --version 2>/dev/null || true
  printf 'npm: '; npm --version 2>/dev/null || true
  printf 'Python: '; python --version 2>/dev/null || true
}
