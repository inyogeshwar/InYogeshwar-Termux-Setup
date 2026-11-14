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
    printf '%b\n' "${CYAN}1)${RESET} Install Termux Essentials + Gemini CLI (experimental)"
    printf '%b\n' "${CYAN}2)${RESET} Custom Install"
    printf '%b\n' "${CYAN}3)${RESET} Essential Termux Setup"
    printf '%b\n' "${CYAN}4)${RESET} Update Installed Tools"
    printf '%b\n' "${CYAN}5)${RESET} Repair / Diagnostics"
    printf '%b\n' "${CYAN}6)${RESET} Uninstall / Cleanup AI Tools"
    printf '%b\n' "${CYAN}7)${RESET} Colorful Zsh Theme"
    printf '%b\n' "${CYAN}8)${RESET} View Compatibility & Help"
    printf '%b\n' "${CYAN}9)${RESET} Android APK Build Setup"
    printf '%b\n' "${CYAN}0)${RESET} Exit"
    line
    read -r -p "Select an option: " choice
    case "$choice" in
      1)
        if install_base; then
          install_all_tools
          install_colorful_shell || warn "Theme setup had errors."
        else
          warn "Base package setup failed. Gemini CLI was not installed."
        fi
        pause
        ;;
      2) custom_install; pause ;;
      3) install_base || warn "Base package setup failed. Review the error before retrying."; pause ;;
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
  printf '%b\n' "1 Gemini CLI (experimental)"
  printf '%b\n' "2 Colorful Zsh Theme"
  printf '%b\n' "3 Essential Termux packages"
  read -r -p "Your selection (numbers separated by spaces): " selection

  for item in $selection; do
    case "$item" in
      1) install_ai_tool gemini || true ;;
      2) install_colorful_shell || true ;;
      3) install_base || warn "Base package setup failed." ;;
      *) warn "Ignoring unknown selection: $item" ;;
    esac
  done
}

install_all_tools() {
  info "Installing the retained AI CLI candidate..."
  install_ai_tool gemini || warn "Gemini CLI setup did not pass verification."
}

update_tools() {
  install_base || { warn "Package repair failed; tool updates were skipped."; return 1; }
  has_npm || { warn "npm is not installed."; return 1; }

  if npm list -g --depth=0 "@google/gemini-cli" >/dev/null 2>&1; then
    info "Updating @google/gemini-cli..."
    if npm update -g "@google/gemini-cli" --no-fund --no-audit; then
      if command -v gemini >/dev/null 2>&1 && gemini --version 2>&1 | tee -a "$LOG_FILE"; then
        ok "Gemini CLI update and version check passed."
      else
        warn "Gemini CLI update completed, but its version check failed."
      fi
    else
      warn "Gemini CLI update failed. Review the setup log."
    fi
  else
    info "Gemini CLI is not installed; nothing to update."
  fi

  ok "Update check completed."
}

uninstall_menu() {
  has_npm || { warn "npm is not installed."; return 1; }
  printf '%b\n' "1) Uninstall Gemini CLI"
  printf '%b\n' "2) Remove legacy unsupported CLI packages (OpenCode, Claude Code, Codex)"
  printf '%b\n' "3) Remove all AI CLI packages (Gemini + legacy packages)"
  read -r -p "Select: " choice
  case "$choice" in
    1) npm uninstall -g @google/gemini-cli || true ;;
    2) npm uninstall -g @opencode/cli @anthropic-ai/claude-code @openai/codex || true ;;
    3) npm uninstall -g @google/gemini-cli @opencode/cli @anthropic-ai/claude-code @openai/codex || true ;;
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

  for bin in pkg apt git curl node npm python zsh; do
    if command -v "$bin" >/dev/null 2>&1; then
      printf '%b %s: %s\n' "${GREEN}✔${RESET}" "$bin" "$(command -v "$bin")"
    else
      printf '%b %s: not found\n' "${GRAY}•${RESET}" "$bin"
    fi
  done

  if command -v gemini >/dev/null 2>&1; then
    printf '%b\n' "${WHITE}Gemini CLI runtime check:${RESET}"
    if gemini --version 2>&1 | tee -a "$LOG_FILE"; then
      ok "Gemini CLI starts and reports a version. Interactive features remain unverified."
    else
      warn "Gemini command exists but failed its version check."
    fi
  else
    warn "Gemini CLI is not installed."
  fi

  if command -v curl >/dev/null 2>&1; then
    if curl --version >/dev/null 2>&1; then
      ok "curl executable starts successfully."
    else
      warn "curl is installed but cannot start. Run: apt update && apt full-upgrade -y"
    fi
  fi
  printf '\nLog: %s\n' "$LOG_FILE"
}

compatibility_help() {
  show_banner
  printf '%b\n' "${WHITE}ANDROID / TERMUX COMPATIBILITY${RESET}"
  printf '%b\n' "${YELLOW}Gemini CLI${RESET}: retained as the only experimental npm candidate. Android/Termux is not officially listed; install is accepted only if gemini --version passes."
  printf '%b\n' "${RED}OpenCode v2${RESET}: removed from installer. npm package rejects os=android (EBADPLATFORM)."
  printf '%b\n' "${RED}Claude Code${RESET}: removed from installer. Native binary/postinstall is not compatible or verified on Termux/Bionic."
  printf '%b\n' "${RED}Codex CLI${RESET}: removed from installer. Required Linux ARM64 optional dependency is missing on Android."
  printf '%b\n' "${RED}Antigravity CLI${RESET}: removed from installer. Official Linux build requires glibc; Termux uses Android Bionic."
  printf '%b\n' "${YELLOW}Android APK toolchain${RESET}: separate experimental feature; SDK manager and Gradle builds still require device testing."
  printf '\nNever enter API keys into this installer. Authenticate inside Gemini CLI using its own official flow.'
}
