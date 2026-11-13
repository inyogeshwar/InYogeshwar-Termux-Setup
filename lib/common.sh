#!/data/data/com.termux/files/usr/bin/bash
PROJECT_NAME="InYogeshwar Termux Setup"
PROJECT_VERSION="0.1.0"
CONFIG_DIR="${HOME}/.config/inyogeshwar-termux-setup"
LOG_DIR="${HOME}/.local/state/inyogeshwar-termux-setup"
LOG_FILE="${LOG_DIR}/setup.log"
mkdir -p "$CONFIG_DIR" "$LOG_DIR"

RESET='\033[0m'; BOLD='\033[1m'
RED='\033[38;5;203m'; GREEN='\033[38;5;82m'; YELLOW='\033[38;5;220m'
BLUE='\033[38;5;75m'; MAGENTA='\033[38;5;177m'; CYAN='\033[38;5;51m'
WHITE='\033[38;5;255m'; GRAY='\033[38;5;245m'

line() { printf '%b\n' "${GRAY}────────────────────────────────────────────────────────${RESET}"; }
ok() { printf '%b\n' "${GREEN}✔${RESET} $*"; }
warn() { printf '%b\n' "${YELLOW}⚠${RESET} $*"; }
err() { printf '%b\n' "${RED}✖${RESET} $*" >&2; }
info() { printf '%b\n' "${CYAN}➜${RESET} $*"; }
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG_FILE"; }
pause() { printf '\n'; read -r -p "Press Enter to continue..." _; }
confirm() {
  local answer
  read -r -p "${YELLOW}${1} [y/N]: ${RESET}" answer
  [[ "$answer" =~ ^([yY]|[yY][eE][sS])$ ]]
}
require_termux() {
  if [[ -z "${PREFIX:-}" || "$PREFIX" != *com.termux* ]] || ! command -v pkg >/dev/null 2>&1; then
    err "This installer is designed for Termux on Android only."
    err "Open Termux from a trusted installation and run this script there."
    exit 1
  fi
}
show_banner() {
  clear 2>/dev/null || true
  printf '%b\n' "${MAGENTA}╔══════════════════════════════════════════════════════╗${RESET}"
  printf '%b\n' "${MAGENTA}║${RESET}  ${CYAN}InYogeshwar${RESET} ${WHITE}TERMUX SETUP${RESET}  ${YELLOW}v${PROJECT_VERSION}${RESET}             ${MAGENTA}║${RESET}"
  printf '%b\n' "${MAGENTA}║${RESET}  ${GRAY}Android • AI Coding CLIs • Colorful Terminal${RESET}     ${MAGENTA}║${RESET}"
  printf '%b\n' "${MAGENTA}╚══════════════════════════════════════════════════════╝${RESET}"
  printf '\n'
}
run_cmd() {
  log "RUN: $*"
  "$@" 2>&1 | tee -a "$LOG_FILE"
}
has_npm() { command -v npm >/dev/null 2>&1; }
