#!/data/data/com.termux/files/usr/bin/bash

# Gemini CLI is the only AI CLI retained as a best-effort Termux candidate.
# Android/Termux is not an officially supported Gemini CLI platform.
install_ai_tool() {
  local tool="${1:-}" package="@google/gemini-cli" command_name="gemini" label="Gemini CLI"

  if [[ "$tool" != "gemini" ]]; then
    err "Unsupported or removed AI tool: $tool"
    warn "Only Gemini CLI is retained as an experimental Termux candidate."
    return 2
  fi

  show_banner
  printf '%b\n' "${WHITE}${label}${RESET}"
  warn "Android/Termux is not an officially supported Gemini CLI platform."
  warn "This is an experimental install. npm may skip optional native dependency scripts."
  if ! confirm "Attempt experimental installation of ${label}?"; then
    info "Skipped ${label}."
    return 0
  fi

  has_npm || { err "npm missing. Choose Essential Termux Setup first."; return 1; }

  if command -v "$command_name" >/dev/null 2>&1; then
    ok "${label} command found: $(command -v "$command_name")"
    if ! confirm "Reinstall/update it anyway?"; then
      if "$command_name" --version 2>&1 | tee -a "$LOG_FILE"; then
        ok "${label} version check passed."
        return 0
      fi
      warn "Existing Gemini CLI failed its version check."
      return 1
    fi
  fi

  info "Installing ${label}..."
  if npm install -g "$package" --no-fund --no-audit --progress=true --fetch-retries=2 --fetch-timeout=120000 2>&1 | tee -a "$LOG_FILE"; then
    if command -v "$command_name" >/dev/null 2>&1; then
      if "$command_name" --version 2>&1 | tee -a "$LOG_FILE"; then
        ok "${label} installed and version check passed."
        warn "This verifies CLI startup only; test interactive login and features separately."
        return 0
      fi
    fi
    warn "${label} package installed but its command/version check failed."
    warn "Removing the failed package to avoid leaving a broken command."
    npm uninstall -g "$package" 2>&1 | tee -a "$LOG_FILE" || true
    return 1
  else
    err "Installation failed for ${label}."
    npm uninstall -g "$package" >/dev/null 2>&1 || true
    return 1
  fi
}
