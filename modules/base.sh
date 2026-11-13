#!/data/data/com.termux/files/usr/bin/bash
install_base() {
  show_banner
  info "Updating Termux package indexes..."
  pkg update -y || { err "pkg update failed. Check network and Termux repository."; return 1; }
  info "Installing base development packages..."
  pkg install -y git curl wget ca-certificates openssl nodejs-lts python python-pip nano vim zip unzip tar jq zsh || {
    warn "Some packages may have failed. Review the log."
  }
  ok "Base package step finished."
  printf 'Node: '; node --version 2>/dev/null || true
  printf 'npm: '; npm --version 2>/dev/null || true
  printf 'Python: '; python --version 2>/dev/null || true
}
