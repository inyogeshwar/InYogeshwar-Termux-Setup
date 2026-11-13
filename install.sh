#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/menu.sh"
require_termux
mkdir -p "$LOG_DIR"
log "Starting InYogeshwar Termux Setup"
show_banner
main_menu
