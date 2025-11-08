# Meshtastic Firmware Architecture

This document describes the architecture and supported hardware for this Meshtastic firmware build, specifically optimized for Heltec WiFi LoRa 32 boards with 26MHz crystals.

## Supported Hardware

### Heltec WiFi LoRa 32 Variants

This firmware supports multiple variants of the Heltec WiFi LoRa 32 board:

#### Heltec V1 (4MB Flash)
- **ESP32 Chip**: ESP32-D0WDQ6-V3
- **Flash Memory**: 4MB
- **Crystal Frequency**: 26MHz (confirmed)
- **Display**: OLED SSD1306 (0.96" 128x64)
- **LoRa Module**: SX1276/SX1278
- **Antenna**: SMA connector
- **USB-to-Serial**: CH340/CH341
- **MAC Address Example**: 58:bf:25:05:58:18

**Key Characteristics:**
- Older revision with 4MB flash memory
- Requires specific partition table configuration
- Uses HELTEC_V1 build flag
- App partition limited to ~2.4MB

#### Heltec V2 (8MB Flash)
- **ESP32 Chip**: ESP32-D0WDQ6-V3 or similar
- **Flash Memory**: 8MB
- **Crystal Frequency**: 26MHz (confirmed)
- **Display**: OLED SSD1306 (0.96" 128x64)
- **LoRa Module**: SX1276/SX1278
- **Antenna**: SMA connector
- **USB-to-Serial**: CH340/CH341

**Key Characteristics:**
- Newer revision with 8MB flash memory
- More flexible partition table options
- Uses HELTEC_V2 build flag
- Larger app partitions available

#### Heltec V2.1 (8MB Flash)
- **ESP32 Chip**: ESP32-D0WDQ6-V3 or similar
- **Flash Memory**: 8MB
- **Crystal Frequency**: 26MHz (confirmed)
- **Display**: OLED SSD1306 (0.96" 128x64)
- **LoRa Module**: SX1276/SX1278
- **Antenna**: SMA connector
- **USB-to-Serial**: CH340/CH341

**Key Characteristics:**
- Latest revision with 8MB flash memory
- Enhanced features and stability
- Uses HELTEC_V2_1 build flag
- Optimized for modern Meshtastic features

## Hardware Identification

### How to Identify Your Board Version

1. **Visual Inspection:**
   - V1: Typically has "V1" silkscreen or no version marking
   - V2: May have "V2" silkscreen
   - V2.1: May have "V2.1" silkscreen or updated components

2. **Flash Memory Check:**
   ```bash
   esptool.py --chip esp32 --port /dev/cu.usbserial-XXXX flash_id
   ```
   - 4MB = Heltec V1
   - 8MB = Heltec V2 or V2.1

3. **Bootloader Check:**
   - Connect board and observe boot messages
   - V1 boards may show different behavior with V2/V2.1 firmware

### Common Issues

- **Wrong firmware on wrong board**: V2.x firmware on V1 board causes blank screen/red LED
- **Crystal frequency mismatch**: 26MHz crystal requires specific ESP32 configuration
- **Partition table mismatch**: V1 needs custom 4MB partition table

## Build Configuration

### PlatformIO Environments

- `heltec-v1`: For 4MB Heltec V1 boards
- `heltec-v2`: For 8MB Heltec V2 boards
- `heltec-v2_1`: For 8MB Heltec V2.1 boards

### Key Build Flags

```ini
# Heltec V1 specific
-D HELTEC_V1
-D MESHTASTIC_EXCLUDE_ENVIRONMENTAL_SENSOR=1
-D MESHTASTIC_EXCLUDE_AUDIO=1
-D MESHTASTIC_EXCLUDE_POWERMON=1
-D MESHTASTIC_EXCLUDE_STOREFORWARD=1
-D MESHTASTIC_EXCLUDE_CANNEDMESSAGES=1
-D MESHTASTIC_EXCLUDE_RANGETEST=1
```

### Partition Tables

#### V1 (4MB Flash)
```
nvs: 0x9000, size 0x5000
otadata: 0xe000, size 0x2000
app0: 0x10000, size 0x250000 (2.44MB)
app1: 0x260000, size 0x0A0000 (640KB)
spiffs: 0x300000, size 0x100000 (1MB)
```

#### V2/V2.1 (8MB Flash)
Uses standard Meshtastic partition tables optimized for 8MB flash.

## Firmware Features

### Included Modules
- Text messaging
- GPS/location services
- WiFi connectivity
- MQTT integration
- Bluetooth Low Energy (BLE)
- OLED display support
- LoRa mesh networking

### Excluded Modules (Size Optimization)
- Environmental sensors
- Audio features
- Power monitoring
- Store and forward
- Canned messages
- Range testing

## Security Considerations

### Default Credentials
The firmware includes default insecure credentials that should be changed:

- **MQTT**: Username: "meshdev", Password: "large4cats"
- **WiFi**: SSID: "wifi_ssid", PSK: "wifi_psk"

### Secure Configuration
Use the provided `.env` file and `userPrefs.jsonc` to configure secure credentials:

```bash
# .env file
MQTT_USERNAME=your_secure_username
MQTT_PASSWORD=your_secure_password
WIFI_SSID=your_wifi_ssid
WIFI_PSK=your_wifi_password
```

## Development Notes

### Crystal Frequency
All supported boards use 26MHz crystals, which requires specific ESP32 bootloader and partition configurations.

### Memory Constraints
V1 boards have limited flash space, requiring careful module selection and size optimization.

### Compatibility
This firmware is based on Meshtastic v2.7.13 and may not be compatible with all Meshtastic network features or configurations.</content>
<parameter name="filePath">/Users/david/Documents/Meshtastic_LoRa32_26mhz/ARCHITECTURE.md