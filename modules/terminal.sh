#!/data/data/com.termux/files/usr/bin/bash
install_colorful_shell() {
  show_banner
  pkg install -y zsh git || { err "Could not install zsh/git."; return 1; }
  local theme_dir="${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
  if [[ ! -d "$theme_dir" ]]; then
    mkdir -p "$(dirname "$theme_dir")"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir" || {
      warn "Powerlevel10k clone failed."; return 1;
    }
  fi
  local zshrc="${HOME}/.zshrc"
  local marker="# >>> InYogeshwar Termux Setup >>>"
  if [[ -f "$zshrc" ]] && ! grep -Fq "$marker" "$zshrc"; then
    cp "$zshrc" "${zshrc}.backup.$(date +%Y%m%d%H%M%S)"
  fi
  if ! grep -Fq "$marker" "$zshrc" 2>/dev/null; then
    cat >> "$zshrc" <<'ZSHCFG'

# >>> InYogeshwar Termux Setup >>>
if [[ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
fi
# OpenCode keeps its own TUI theme and configuration.
# <<< InYogeshwar Termux Setup <<<
ZSHCFG
  fi
  ok "Colorful Zsh theme files are ready."
  info "Start it with: zsh"
  info "For prompt configuration, run: p10k configure (if available)."
}
