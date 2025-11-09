# Meshtastic for TTGO LoRa32 V1 (26MHz) – Reliable Flash Kit

This folder contains a minimal, reproducible kit to flash Meshtastic onto a TTGO LoRa32 V1 with a 26MHz crystal. These boards often fail at high baud with: `Invalid head of packet (0x00)`. The fix is to upload at 115200 baud.

## What’s here
- `platformio_override.ini` – forces `upload_speed = 115200` for the `ttgo-lora32-oled` environment.
- `flash_ttgo.sh` – helper script to detect the serial port and flash.
- This README – step-by-step instructions and troubleshooting.

## Prerequisites
- PlatformIO CLI installed (`pio`). If not, install the VS Code PlatformIO extension or use `pipx install platformio`.
- Meshtastic firmware source available. If using the parent workspace layout, the Meshtastic project is in `../firmware` from the repo root. Adjust the `-d` flag accordingly.
- A data-capable USB cable.

## Quick start
1) Identify your Meshtastic project root (contains `platformio.ini`). Commonly:
   - `…/Ansible/firmware` in this workspace
2) Ensure the override is present (already provided here):
   - `platformio_override.ini` contains:
     
     [env:ttgo-lora32-oled]
     upload_speed = 115200

3) Put board in bootloader (if needed): Hold BOOT, tap RESET, release RESET, release BOOT.

4) Flash using the helper script:

```bash
# From this folder
./flash_ttgo.sh -d ../firmware
```

The script will auto-detect the serial port (via unplug/plug delta) and upload to the `ttgo-lora32-oled` environment at 115200.

## Manual flash (no script)
If you prefer manual control:

```bash
# Ensure override exists in <project_root>/platformio_override.ini
# Then run (replace PORT):
pio run -d <project_root> -e ttgo-lora32-oled --target upload --upload-port /dev/cu.usbserial-XXXXXXXX
```

If you encounter the 0x00 packet error at higher speeds, drop to 115200 (already enforced by the override).

## Port discovery (macOS)
- Unplug the board, list ports:

```bash
ls /dev/cu.*
```

- Plug the board in, list again; the new entry is the port. Examples:
  - `/dev/cu.usbserial-531C0092231`
  - `/dev/cu.SLAB_USBtoUART`

## Why 115200?
Older TTGO LoRa32 V1 units with 26MHz crystals are flaky at 921600. Dropping to 115200 eliminates packet corruption (“Invalid head of packet (0x00)”). It’s slower but reliable.

## Troubleshooting
- Connecting… and times out:
  - Re-enter bootloader (hold BOOT, tap RESET).
  - Try a different USB port/cable.
- Port busy:
  - Close serial monitors (VS Code, `pio device monitor`, `screen`).
- Still failing with 0x00 head:
  - Confirm `platformio_override.ini` has `upload_speed = 115200` under `[env:ttgo-lora32-oled]`.
  - Try another USB cable/port.
- Blank OLED after success:
  - Power cycle the board. If still blank, reflash once more.

## Next steps
- Use `pio device monitor --port <PORT> --baud 115200` to see logs after flashing.
- Configure Meshtastic via the mobile app or CLI as needed.
