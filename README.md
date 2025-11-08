# Meshtastic Firmware for Heltec WiFi LoRa 32 (V2) with 26MHz Crystal

This repository contains a build of the Meshtastic firmware that has been confirmed to work on older Heltec WiFi LoRa 32 (V2) boards, which may use a 26MHz crystal. These boards are sometimes not supported by more recent firmware builds, and this project aims to provide a functional firmware to prevent these devices from becoming e-waste.

## About Meshtastic

Meshtastic is an open-source, off-grid, decentralized, mesh networking project. It allows you to use inexpensive LoRa radios as a long-range, encrypted communication platform for text-based messaging.

## Board

- **Device**: Heltec WiFi LoRa 32 (V2)
- **Crystal**: Believed to be 26MHz on this specific revision.

## Firmware

The firmware is based on the Meshtastic project. The source code is provided in this repository.

### Pre-compiled Firmware

The compiled firmware is provided in the `firmware/` directory:
- `firmware.bin`: The application firmware.
- `firmware.factory.bin`: A combined binary for first-time flashing.

### Flashing

You can flash the firmware using PlatformIO.

1.  **Install PlatformIO**: Follow the instructions at [platformio.org](https://platformio.org).
2.  **Connect the board**: Put the board into bootloader mode.
3.  **Flash**: Open a terminal in the project root and run the following command, replacing `/dev/cu.SLAB_USBtoUART` with the correct serial port for your device:

    ```bash
    pio run -e heltec-v2_1 --target upload --upload-port /dev/cu.SLAB_USBtoUART
    ```

## Building from Source

You can also compile the firmware from the source code provided.

1.  **Clone this repository.**
2.  **Open with PlatformIO**: Open the cloned repository folder in VS Code with the PlatformIO extension installed.
3.  **Build**: Use the PlatformIO "Build" command for the `heltec-v2_1` environment.

---

*This project was prepared with the assistance of GitHub Copilot.*
