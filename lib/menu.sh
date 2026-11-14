#!/data/data/com.termux/files/usr/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../modules/base.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../modules/ai-tools.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../modules/terminal.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../modules/android-build.sh"

main_menu() {
  while true; do
    show_banner
    printf '%b\n' "${WHITE}MAIN MENU${RESET}"
    line
    printf '%b\n' "${CYAN}1)${RESET} Install All Compatible Tools"
    printf '%b\n' "${CYAN}2)${RESET} Custom Install (choose tools)"
    printf '%b\n' "${CYAN}3)${RESET} Essential Termux Setup"
    printf '%b\n' "${CYAN}4)${RESET} Update Installed Tools"
    printf '%b\n' "${CYAN}5)${RESET} Repair / Diagnostics"
    printf '%b\n' "${CYAN}6)${RESET} Uninstall AI Tools"
    printf '%b\n' "${CYAN}7)${RESET} Colorful Zsh Theme"
    printf '%b\n' "${CYAN}8)${RESET} View Compatibility & Help"
    printf '%b\n' "${CYAN}9)${RESET} Android APK Build Setup"
    printf '%b\n' "${CYAN}0)${RESET} Exit"
    line
    read -r -p "Select an option: " choice
    case "$choice" in
      1) install_base || warn "Base setup had errors; continuing with selected tools."; install_all_tools; install_colorful_shell || warn "Theme setup had errors."; pause ;;
      2) custom_install; pause ;;
      3) install_base || warn "Base setup had errors."; pause ;;
      4) update_tools; pause ;;
      5) diagnostics; pause ;;
      6) uninstall_menu; pause ;;
      7) install_colorful_shell; pause ;;
      8) compatibility_help; pause ;;
      9) android_build_menu ;;
      0) ok "Setup closed."; exit 0 ;;
      *) warn "Invalid option." ; sleep 1 ;;
    esac
  done
}

custom_install() {
  show_banner
  printf '%b\n' "${WHITE}CUSTOM INSTALL${RESET}"
  printf '%b\n' "Enter numbers separated by spaces (example: 1 2 4)."
  printf '%b\n' "1 OpenCode v2  2 Gemini CLI  3 Claude Code  4 Codex CLI"
  printf '%b\n' "5 Antigravity CLI  6 Colorful Zsh  7 Essential packages"
  read -r -p "Your selection: " selection
  [[ " $selection " == *" 7 "* ]] && install_base
  for item in $selection; do
    case "$item" in
      1) install_ai_tool opencode || true ;;
      2) install_ai_tool gemini || true ;;
      3) install_ai_tool claude || true ;;
      4) install_ai_tool codex || true ;;
      5) install_ai_tool antigravity || true ;;
      6) install_colorful_shell || true ;;
      *) warn "Ignoring unknown selection: $item" ;;
    esac
  done
}

install_all_tools() {
  info "Installing base dependencies first..."
  # Supported and experimental npm tools are attempted only after a clear warning.
  install_ai_tool gemini || true
  install_ai_tool opencode || true
  install_ai_tool claude || true
  install_ai_tool codex || true
  install_ai_tool antigravity || true
}

update_tools() {
  install_base
  has_npm || { warn "npm is not installed."; return; }
  for item in "@google/gemini-cli" "@opencode/cli" "@anthropic-ai/claude-code" "@openai/codex"; do
    if npm list -g --depth=0 "$item" >/dev/null 2>&1; then
      info "Updating $item"
      npm update -g "$item" || warn "Update failed: $item"
    fi
  done
  ok "Update check completed. Review the log for any failures."
}

uninstall_menu() {
  has_npm || { warn "npm is not installed."; return; }
  printf '%b\n' "1 OpenCode  2 Gemini  3 Claude  4 Codex  5 All npm AI tools"
  read -r -p "Select: " choice
  case "$choice" in
    1) npm uninstall -g @opencode/cli || true ;;
    2) npm uninstall -g @google/gemini-cli || true ;;
    3) npm uninstall -g @anthropic-ai/claude-code || true ;;
    4) npm uninstall -g @openai/codex || true ;;
    5)
      npm uninstall -g @opencode/cli @google/gemini-cli @anthropic-ai/claude-code @openai/codex || true ;;
    *) warn "No action taken." ;;
  esac
}

diagnostics() {
  show_banner
  printf '%b\n' "${WHITE}DIAGNOSTICS${RESET}"
  printf 'Android/Termux prefix: %s\n' "${PREFIX:-unknown}"
  printf 'Architecture: %s\n' "$(uname -m)"
  printf 'Shell: %s\n' "${SHELL:-unknown}"
  printf 'Storage available: '; df -h "$HOME" | awk 'NR==2 {print $4 " free"}'
  for bin in pkg git curl node npm python zsh opencode gemini claude codex agy; do
    if command -v "$bin" >/dev/null 2>&1; then
      printf '%b %s: %s\n' "${GREEN}✔${RESET}" "$bin" "$(command -v "$bin")"
    else
      printf '%b %s: not found\n' "${GRAY}•${RESET}" "$bin"
    fi
  done
  printf '\nLog: %s\n' "$LOG_FILE"
}

compatibility_help() {
  show_banner
  printf '%b\n' "${WHITE}ANDROID / TERMUX COMPATIBILITY${RESET}"
  printf '%b\n' "${GREEN}Gemini CLI${RESET}: npm-based; experimental on Termux because Android is not in official OS list."
  printf '%b\n' "${YELLOW}OpenCode v2${RESET}: experimental; official npm package platform gating and Android wrapper issues need validation."
  printf '%b\n' "${YELLOW}Claude Code${RESET}: experimental; official OS list does not include Android/Termux."
  printf '%b\n' "${YELLOW}Codex CLI${RESET}: experimental; official native binaries target Linux/macOS/Windows, not Android/Bionic."
  printf '%b\n' "${RED}Antigravity CLI${RESET}: not installed on Termux; official Linux build requires glibc, while Termux uses Android Bionic."
  printf '%b\n' "${YELLOW}Android APK toolchain${RESET}: experimental; SDK manager and Gradle builds may fail depending on device, architecture and Termux packages."
  printf '\nNever enter API keys into this installer. Authenticate inside each CLI using its own official flow.'
}
