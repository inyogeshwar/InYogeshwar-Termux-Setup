#!/data/data/com.termux/files/usr/bin/bash
install_ai_tool() {
  local tool="$1" package="" command_name="" label="" status="experimental"
  case "$tool" in
    gemini) package="@google/gemini-cli"; command_name="gemini"; label="Gemini CLI" ;;
    opencode) package="@opencode/cli"; command_name="opencode"; label="OpenCode v2" ;;
    claude) package="@anthropic-ai/claude-code"; command_name="claude"; label="Claude Code" ;;
    codex) package="@openai/codex"; command_name="codex"; label="Codex CLI" ;;
    antigravity)
      warn "Antigravity CLI is not installed: its official Linux build requires glibc; Termux uses Android Bionic."
      warn "No unsupported binary or unofficial installer will be forced onto this device."
      return 2 ;;
    *) err "Unknown tool: $tool"; return 2 ;;
  esac

  show_banner
  printf '%b\n' "${WHITE}${label}${RESET}"
  warn "Termux/Android is not listed as an officially supported OS for this tool."
  warn "This is an experimental npm installation; it may fail or run incompletely."
  if ! confirm "Attempt experimental installation of ${label}?"; then
    info "Skipped ${label}."
    return 0
  fi
  has_npm || { err "npm missing. Choose Essential Termux Setup first."; return 1; }

  if command -v "$command_name" >/dev/null 2>&1; then
    ok "${label} already exists: $(command -v "$command_name")"
    if ! confirm "Reinstall/update it anyway?"; then return 0; fi
  fi

  info "Installing ${label}..."
  if npm install -g "$package" --no-fund --no-audit --progress=true --fetch-retries=2 --fetch-timeout=120000 2>&1 | tee -a "$LOG_FILE"; then
    if command -v "$command_name" >/dev/null 2>&1; then
      if "$command_name" --version 2>&1 | tee -a "$LOG_FILE"; then
        ok "${label} installed and command check passed."
        return 0
      fi
    fi
    warn "${label} package installed but its executable did not pass verification."
    warn "Removing the failed package to avoid a broken command."
    npm uninstall -g "$package" 2>&1 | tee -a "$LOG_FILE" || true
    return 1
  else
    err "Installation failed for ${label}."
    npm uninstall -g "$package" >/dev/null 2>&1 || true
    return 1
  fi
}
