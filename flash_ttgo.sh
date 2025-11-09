#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "$0")" && pwd)/../firmware}" # default assume Meshtastic sources one level up in firmware/
ENV_NAME="ttgo-lora32-oled"
PORT=""
MONITOR="false"
SHOW_LOG="false"

usage() {
  cat <<'EOF'
Flash Meshtastic to a TTGO LoRa32 V1 (26MHz crystal) reliably.

Environment: ttgo-lora32-oled
Required override: upload_speed = 115200

Options:
  -d <project_dir>   Path to Meshtastic project root (contains platformio.ini). Default: $PROJECT_DIR
  -p <port>          Serial port (skip auto-detect)
  -m                 Start serial monitor after flash
  -l                 Show port detection logs verbosely
  -h                 Help

Auto-detect strategy (macOS):
  1. Snapshot existing /dev/cu.*
  2. Prompt to (un)plug board
  3. Snapshot again; new entry assumed port
If multiple new ports, require manual specification.
EOF
}

log() { printf "[flash_ttgo] %s\n" "$*"; }
err() { printf "[flash_ttgo][ERROR] %s\n" "$*" >&2; }

while getopts ":d:p:mlh" opt; do
  case $opt in
    d) PROJECT_DIR="$OPTARG" ;;
    p) PORT="$OPTARG" ;;
    m) MONITOR="true" ;;
    l) SHOW_LOG="true" ;;
    h) usage; exit 0 ;;
    :) err "Option -$OPTARG requires an argument"; exit 1 ;;
    \?) err "Invalid option -$OPTARG"; usage; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ ! -f "$PROJECT_DIR/platformio.ini" ]; then
  err "platformio.ini not found in $PROJECT_DIR"; exit 1
fi

ensure_override() {
  local override_file="$PROJECT_DIR/platformio_override.ini"
  if grep -qi "\[env:$ENV_NAME\]" "$override_file" 2>/dev/null; then
    if grep -qi "upload_speed *= *115200" "$override_file"; then
      log "Override already sets upload_speed=115200"
      return
    fi
  fi
  log "Writing upload_speed override to $override_file"
  printf "[env:%s]\nupload_speed = 115200\n" "$ENV_NAME" > "$override_file"
}

if [ -z "$PORT" ]; then
  BEFORE=$(ls /dev/cu.* 2>/dev/null || true)
  log "Disconnect the board (if connected), press Enter when ready..."; read -r _
  BEFORE=$(ls /dev/cu.* 2>/dev/null || true)
  log "Connect the board now (data-capable cable), press Enter when the LED/OLED lights (or after 2s)..."; read -r _
  AFTER=$(ls /dev/cu.* 2>/dev/null || true)
  # Normalize lists to newline separated tokens for comm
  NEW=$(comm -13 <(printf "%s\n" $BEFORE | tr ' ' '\n' | sort) <(printf "%s\n" $AFTER | tr ' ' '\n' | sort))
  if [ -z "$NEW" ]; then
    err "No new serial port detected. Specify with -p <port>."; exit 1
  fi
  COUNT=$(printf "%s\n" $NEW | wc -l | tr -d ' ')
  if [ "$COUNT" -gt 1 ]; then
    err "Multiple new ports detected:\n$NEW\nSpecify one with -p."; exit 1
  fi
  PORT="$NEW"
fi

if [ "$SHOW_LOG" = "true" ]; then
  log "Using port: $PORT"
fi

if [[ ! "$PORT" =~ ^/dev/cu. ]]; then
  err "Port '$PORT' does not look like a macOS /dev/cu.* device"; exit 1
fi

ensure_override

log "Entering bootloader (if needed): hold BOOT, tap RESET, release RESET, release BOOT."
log "Flashing Meshtastic ($ENV_NAME) to $PORT from $PROJECT_DIR"

# Perform the upload with PlatformIO
pio run -d "$PROJECT_DIR" -e "$ENV_NAME" --target upload --upload-port "$PORT" || {
  err "PlatformIO upload failed. If error shows 'Invalid head of packet (0x00)', try a different USB cable or port, ensure override is present, and re-enter bootloader."; exit 1
}

log "Flash SUCCESS"

if [ "$MONITOR" = "true" ]; then
  log "Starting serial monitor (Ctrl+C to exit)"
  pio device monitor --port "$PORT" --baud 115200
fi
