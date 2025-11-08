# Meshtastic Firmware for Heltec WiFi LoRa 32 Boards (V1 & V2) with 26MHz Crystal

## ⚠️ CRITICAL SAFETY WARNING: LiPo Battery Fire Hazard

**🚨 DANGER: DO NOT USE LiPo BATTERIES WITH THIS FIRMWARE! 🚨**

This firmware is designed **exclusively for USB-powered operation only**. Using LiPo batteries poses a **severe fire hazard** and is **strictly prohibited**.

### Why LiPo Batteries Are Dangerous
- **Thermal Runaway**: LiPo batteries can overheat, catch fire, or explode
- **No Safety Circuit**: This firmware does not include battery management or protection
- **Overvoltage Risk**: Uncontrolled charging can damage batteries and cause fires
- **Fire Hazard**: Lithium polymer batteries have caused numerous fires in electronics

### Supported Power Sources
- ✅ **USB Power Only** (5V regulated power from USB port)
- ✅ **External Regulated 5V Power Supplies**
- ❌ **LiPo Batteries** (NEVER use - fire hazard)
- ❌ **Unregulated Power Sources**

### If You Have a Battery Connector
**IMMEDIATELY DISABLE OR REMOVE IT:**
- Configure auto-shutdown on battery detection (see Safety Configuration below)
- Physically remove the battery connector from the PCB
- Cut traces to the battery connector if necessary
- Use electrical tape to insulate any exposed contacts

**This firmware is for USB-powered devices ONLY. Battery usage will void any safety considerations and is done at your own risk.**

---

This repository contains customized builds of the Meshtastic firmware specifically adapted for Heltec WiFi LoRa 32 boards that use 26MHz crystals. These boards may not be fully supported by standard Meshtastic firmware builds, and this project provides working firmware for both V1 (4MB) and V2/V2.1 (8MB) variants.

## About Meshtastic

Meshtastic is an open-source, off-grid, decentralized, mesh networking project. It allows you to use inexpensive LoRa radios as a long-range, encrypted communication platform for text-based messaging.

## Supported Boards

### Heltec WiFi LoRa 32 V1 (4MB Flash)
- **ESP32 Chip**: ESP32-D0WDQ6-V3
- **Flash Memory**: 4MB
- **Crystal**: 26MHz
- **PlatformIO Environment**: `heltec-v1`
- **Partition Table**: Custom 4MB layout

### Heltec WiFi LoRa 32 V2/V2.1 (8MB Flash)
- **ESP32 Chip**: ESP32-D0WDQ6-V3
- **Flash Memory**: 8MB
- **Crystal**: 26MHz
- **PlatformIO Environment**: `heltec-v2` or `heltec-v2_1`
- **Partition Table**: Standard 8MB layout

## Hardware Identification

To determine which board you have:

1. **Check flash size**:
   ```bash
   esptool.py --chip esp32 --port /dev/cu.usbserial-XXXX flash_id
   ```
   - 4MB = Heltec V1
   - 8MB = Heltec V2 or V2.1

2. **Visual inspection**: Look for version markings on the board silkscreen

## Quick Start

### Option 1: Automated Flashing Script (Recommended)

Use the provided flashing script for easy board detection and flashing:

```bash
# Make script executable
chmod +x flash_meshtastic.sh

# Run the flashing script
./flash_meshtastic.sh
```

The script will:
- Detect connected Heltec boards
- Identify V1 vs V2/V2.1 automatically
- Flash the appropriate firmware
- Provide status updates

### Option 2: Manual Flashing

#### Prerequisites
- Install PlatformIO: https://platformio.org
- Install esptool: `pip install esptool`

#### Flash V1 Board (4MB)
```bash
# Build for V1
pio run -e heltec-v1

# Flash using esptool
esptool.py --chip esp32 --port /dev/cu.usbserial-XXXX --baud 115200 write_flash -z 0x0 .pio/build/heltec-v1/firmware.factory.bin
```

#### Flash V2/V2.1 Board (8MB)
```bash
# Build for V2.1
pio run -e heltec-v2_1

# Flash using PlatformIO
pio run -e heltec-v2_1 --target upload --upload-port /dev/cu.usbserial-XXXX
```

## Configuration

### Secure Credentials

**Important**: Change the default insecure credentials before use!

The firmware includes default credentials that should be replaced:

- MQTT Username: "meshdev"
- MQTT Password: "large4cats"
- WiFi SSID: "wifi_ssid"
- WiFi Password: "wifi_psk"

#### Using Environment Variables

1. Copy `.env.sample` to `.env`:
   ```bash
   cp .env.sample .env
   ```

2. Edit `.env` with your secure credentials (see `.env.sample` for detailed instructions)

3. The `userPrefs.jsonc` file references these environment variables

### Build Customization

Edit `userPrefs.jsonc` to customize:
- Device name and location
- LoRa frequency and power settings
- MQTT server configuration
- WiFi settings
- Display preferences

## Firmware Features

### Included Features
- ✅ Text messaging over LoRa mesh
- ✅ GPS location sharing
- ✅ WiFi connectivity for internet bridging
- ✅ MQTT integration for remote monitoring
- ✅ Bluetooth Low Energy (BLE) configuration
- ✅ OLED display interface
- ✅ Range testing tools

### Size Optimizations (V1)
Due to limited flash space on V1 boards, some features are excluded:
- ❌ Environmental sensors
- ❌ Audio features
- ❌ Power monitoring
- ❌ Store and forward messaging
- ❌ Canned message templates
- ❌ Extended range testing

## Using Routers and Mesh Networks

### Router Configuration (LilyGo T22 v1.1)

Your LilyGo T22 v1.1 with GPS capabilities is perfect for router duty! Here's how to set it up and use it with your smaller TTGO boards:

#### Router Benefits
- **Extended Range**: Routers relay messages between nodes that can't directly communicate
- **GPS Tracking**: Your LilyGo has GPS for location sharing and mapping
- **Battery Power**: Can operate independently with LiPo battery
- **Network Backbone**: Creates a more robust mesh network

#### Configuring as Router
1. **In Meshtastic App**: Set device role to "ROUTER"
2. **Position**: Enable GPS for location tracking
3. **Power**: Configure for battery operation if using LiPo

### Client Node Setup (Heltec V1/V2 Boards)

Your smaller TTGO boards work perfectly as client nodes in the mesh network:

#### Client Node Roles
- **CLIENT** (default): Full messaging, GPS, all features
- **CLIENT_MUTE**: Receives but doesn't transmit (saves power)
- **LOST_AND_FOUND**: Helps find lost devices
- **TAK_TRACKER**: Specialized tracking device

#### Connecting to Router Network
1. **Same Channel**: All devices must use the same:
   - LoRa frequency band (868/915 MHz)
   - Channel name and settings
   - Network key (PSK)

2. **Range Testing**: Use the range test feature to verify connectivity

3. **Position Sharing**: Enable GPS on nodes that have it for mapping

### Network Topology Examples

#### Simple Mesh (2-3 devices)
```
TTGO V1 ─── Router (LilyGo) ─── TTGO V2
   │              │
   └──────────────┘
```

#### Extended Mesh (4+ devices)
```
TTGO V1 ─── Router 1 (LilyGo) ─── Router 2 ─── TTGO V2
   │              │                     │          │
   └──────────────┴─────────────────────┴──────────┘
```

### Router-Specific Features

#### GPS & Mapping
- **Location Sharing**: Router broadcasts its position
- **Node Mapping**: See all devices on map
- **Waypoint Navigation**: GPS-guided navigation

#### Power Management
- **Battery Monitoring**: Track battery levels
- **Sleep Modes**: Conserve power when not routing
- **Solar Charging**: Compatible with solar panels

#### Advanced Routing
- **Message Relaying**: Automatically forwards messages
- **Network Optimization**: Chooses best paths
- **Store & Forward**: Queues messages when nodes are offline

### Configuration Tips

#### For Router (LilyGo T22):
```json
{
  "device": {
    "role": "ROUTER"
  },
  "position": {
    "gpsEnabled": true,
    "gpsUpdateInterval": 30
  },
  "power": {
    "isPowerSaving": false,
    "onBatteryShutdownAfterSecs": 0
  }
}
```

#### For Client Nodes (TTGO V1/V2):
```json
{
  "device": {
    "role": "CLIENT"
  },
  "position": {
    "gpsEnabled": true
  }
}
```

### Use Cases

#### Outdoor Adventures
- **Hiking Groups**: Stay connected over long distances
- **Search & Rescue**: GPS tracking and communication
- **Camping**: Coordinate group activities

#### Community Networks
- **Neighborhood Mesh**: Local communication network
- **Event Coordination**: Large gatherings with multiple groups
- **Emergency Communication**: Backup when cell service fails

#### IoT Applications
- **Sensor Networks**: Environmental monitoring
- **Asset Tracking**: Equipment location monitoring
- **Remote Monitoring**: Farm/ranch operations

### Monitoring Your Network

#### Via Mobile App
- View node map with GPS positions
- Monitor signal strength and connectivity
- Send/receive messages through the mesh

#### Via MQTT (if configured)
- Remote monitoring and logging
- Integration with other systems
- Data collection and analysis

### Troubleshooting Router Networks

#### Connectivity Issues
- **Check Channel Settings**: All devices must match
- **Verify Frequency Band**: 868 vs 915 MHz
- **Test Range**: Use range test feature
- **Check Power Levels**: Ensure adequate transmission power

#### GPS Problems
- **Clear Sky View**: GPS needs open sky
- **Cold Start**: May take longer to get first fix
- **Antenna Position**: Keep away from metal interference

#### Battery Issues
- **Monitor Voltage**: Use app to check battery levels
- **Charging**: Ensure proper charging setup
- **Power Saving**: Configure appropriate sleep settings

### Advanced Configuration

#### Channel Settings
- **Name**: Same across all devices
- **Modem Preset**: Match for compatibility
- **PSK**: Secure your network

#### Security
- **Change Defaults**: Update all default passwords
- **Channel Encryption**: Use strong PSK
- **Admin Access**: Secure admin channels

Your LilyGo T22 v1.1 router + TTGO client nodes create a powerful, portable mesh network perfect for outdoor adventures, community communication, or IoT applications! 🗼📡

## Bluetooth Connectivity & Mobile Apps

**Yes!** All your Meshtastic devices (LilyGo router + TTGO clients) can connect to phones and computers via Bluetooth for full configuration and messaging capabilities.

### Mobile Apps

#### **Meshtastic App (Primary)**
- **Platforms**: iOS, Android
- **Features**: Full device management, messaging, mapping
- **Download**: App Store / Google Play Store

#### **Alternative Apps**
- **Meshtastic Web Client**: Browser-based interface
- **Meshtastic CLI**: Command-line interface
- **Custom MQTT clients**: For automation

### Bluetooth Pairing Process

#### **Step 1: Enable Bluetooth on Device**
1. Power on your TTGO/LilyGo board
2. Device appears as "Meshtastic_XXXX" in Bluetooth settings
3. The XXXX is the last 4 digits of the device MAC address

#### **Step 2: Pair with Phone**
1. Open Meshtastic app
2. Tap **+** to add new device
3. Select your device from Bluetooth list
4. Wait for connection (may take 10-30 seconds)

#### **Step 3: Initial Configuration**
- Set device name
- Configure region (US, EU, etc.)
- Set up channels and security
- Configure GPS and telemetry

### What You Can Do via Bluetooth

#### **Messaging**
- ✅ Send/receive text messages
- ✅ Group chats
- ✅ Direct messaging to specific nodes
- ✅ Message history

#### **Device Management**
- ✅ Change device settings
- ✅ Update firmware (OTA)
- ✅ Configure LoRa parameters
- ✅ Set up MQTT integration

#### **Network Monitoring**
- ✅ View node map with GPS positions
- ✅ Monitor signal strength
- ✅ Check battery levels
- ✅ See network topology

#### **Advanced Features**
- ✅ Range testing
- ✅ Channel management
- ✅ Security settings
- ✅ Telemetry configuration

### Bluetooth Range & Performance

#### **Typical Range**
- **Line-of-sight**: 10-30 meters
- **Through walls**: 5-15 meters
- **Depends on**: Device antennas, interference, obstacles

#### **Connection Tips**
- Keep devices within Bluetooth range during setup
- Once configured, devices work independently via LoRa
- Bluetooth is only needed for configuration changes

### Computer Connectivity

#### **Via Bluetooth**
- Use Meshtastic CLI tools
- Python scripts for automation
- Custom monitoring dashboards

#### **Via USB Serial**
- Direct firmware updates
- Debug logging
- Advanced configuration

### Your Setup with Bluetooth

#### **LilyGo Router**
- Configure as ROUTER role
- Enable GPS tracking
- Set up battery monitoring
- Connect via Bluetooth for status monitoring

#### **TTGO Clients**
- Configure as CLIENT role
- Set up messaging preferences
- Enable position sharing
- Use app for sending messages

### Bluetooth Security

#### **Pairing Security**
- Devices use Bluetooth LE (Low Energy)
- Secure pairing process
- No internet connection required

#### **Message Security**
- End-to-end encryption via LoRa
- Channel-specific encryption keys
- No Bluetooth message interception

### Troubleshooting Bluetooth

#### **Can't Find Device**
- Ensure device is powered on
- Check Bluetooth is enabled on phone
- Try restarting both devices
- Check battery level

#### **Connection Drops**
- Move closer to device
- Reduce Bluetooth interference
- Restart Meshtastic app
- Check device firmware version

#### **App Not Responding**
- Force close and restart app
- Clear app cache
- Check for app updates
- Try different phone if possible

### Bluetooth vs LoRa

| Feature | Bluetooth | LoRa Mesh |
|---------|-----------|-----------|
| **Range** | 10-30m | 1-20km |
| **Power** | Low | Very Low |
| **Setup** | Phone app | Independent |
| **Messages** | Direct | Mesh routed |
| **GPS** | Phone GPS | Device GPS |
| **Offline** | Limited | Full offline |

**Perfect combination**: Use Bluetooth for setup/configuration, LoRa for the actual mesh networking!

Your devices are now fully controllable via Bluetooth! 📱🔗

## Understanding OLED Display Messages

The small OLED screen on your TTGO boards shows various status messages and network activity:

### Common Messages You Might See

#### **PING33** (What you're seeing!)
- **Meaning**: Ping message received from node #33
- **What it means**: Another device in your mesh network sent a connectivity test
- **Action**: Normal network activity - no action needed

#### Other Common Messages
- **From: NodeName** - Text message received
- **Pos: NodeName** - GPS position update received
- **Route: NodeName** - Message being routed through network
- **MQTT: Connected** - Internet bridge active
- **Battery: 85%** - Power status
- **Nodes: 5** - Number of devices in mesh

#### Status Indicators
- **📶 Signal bars** - LoRa signal strength
- **🔋 Battery icon** - Power level
- **📍 GPS icon** - Location fix status
- **📡 Mesh icon** - Network connectivity

### Message Types in Mesh Networks

#### Routing Messages
- **PING** - Connectivity tests between nodes
- **ACK** - Message delivery confirmations
- **ROUTE** - Message forwarding notifications

#### Position Updates
- **POS** - GPS coordinate sharing
- **TRACK** - Movement tracking data

#### Telemetry
- **TEMP** - Temperature readings
- **BATT** - Battery level reports
- **ENV** - Environmental sensor data

### Customizing Display Behavior

#### In Meshtastic App Settings:
1. **Display Config** → **Screen On Duration** - How long screen stays on
2. **Display Config** → **Screen Carousel** - What info to show
3. **Display Config** → **Display Units** - Metric vs Imperial

#### Reducing Screen Activity:
- Set **Device Role** to **CLIENT_MUTE** for receive-only
- Adjust **Position Update Interval** to reduce GPS messages
- Disable **Telemetry** if not needed

## Safety Configuration: Disabling LiPo Battery Usage

**⚠️ IMPORTANT SAFETY NOTICE:** If your board has a LiPo battery connector that poses a fire hazard, you can disable battery functionality entirely through firmware configuration.

### 🚨 CRITICAL: This Firmware is USB-Only

**DO NOT use LiPo batteries with this firmware under any circumstances:**
- LiPo batteries are a **FIRE HAZARD** when used improperly
- This firmware has **NO battery management or safety circuits**
- Battery charging/usage can cause **thermal runaway and fires**
- Only use **regulated USB power (5V)**

### Firmware Safety Features
- **Auto-Shutdown on Battery Detection**: Devices automatically shut down 1 second after detecting any battery connection
- **Charging Disabled**: Battery charging circuits are completely disabled in firmware to prevent overvoltage
- **USB-Only Operation**: This firmware is designed exclusively for USB-powered operation

### Configuration Applied
The firmware includes these safety settings by default:
```jsonc
"USERPREFS_CONFIG_POWER_ON_BATTERY_SHUTDOWN_AFTER_SECS": "1"
```
This causes immediate shutdown (1 second) when any battery power is detected.

### Additional Safety Measures
For maximum safety, the firmware also disables battery charging at the hardware level:
- **Charging Current**: Set to 0mA (disabled)
- **No Battery Charging**: Hardware charging circuits are inactive
- **Overvoltage Protection**: No charging means no overvoltage risk

### Option 1: Automatic Shutdown on Battery Detection (REQUIRED)

Configure the device to **immediately shut down** when ANY battery power is detected:

#### **Via Meshtastic App:**
1. Connect to your device via Bluetooth
2. Go to **Settings** → **Power Config**
3. Set **"Shutdown after X seconds on battery"** to **1 second**
4. This prevents any battery usage that could cause fires

#### **Via Configuration:**
In your `userPrefs.jsonc`, add:
```jsonc
{
  "USERPREFS_CONFIG_POWER_ON_BATTERY_SHUTDOWN_AFTER_SECS": "1"
}
```

### Option 2: Build-Time Battery Disable (Maximum Safety)

For maximum safety, exclude ALL battery functionality at compile time:

#### **Add to build_flags in userPrefs.jsonc:**
```jsonc
"build_flags": "-D HELTEC_V1 -D MESHTASTIC_EXCLUDE_ENVIRONMENTAL_SENSOR=1 -D MESHTASTIC_EXCLUDE_AUDIO=1 -D MESHTASTIC_EXCLUDE_POWERMON=1 -D MESHTASTIC_EXCLUDE_STOREFORWARD=1 -D MESHTASTIC_EXCLUDE_CANNEDMESSAGES=1 -D MESHTASTIC_EXCLUDE_RANGETEST=1 -D DISABLE_BATTERY_SENSE=1 -D DISABLE_BATTERY_CHARGING=1",
```

### Option 3: Hardware Removal (Most Safe - RECOMMENDED)

For ultimate safety with LiPo-equipped boards:
- **Physically remove** the LiPo battery connector from the PCB
- **Cut the traces** leading to the battery connector
- Use electrical tape to insulate any exposed contacts
- **DO NOT** connect any batteries to this board

### Safety Recommendations

#### **Immediate Actions (REQUIRED):**
1. **NEVER connect LiPo batteries** to boards running this firmware
2. **Configure auto-shutdown** as described above
3. **Use only regulated USB power** (5V from USB port)
4. **Monitor device temperature** during operation
5. **Keep devices away from flammable materials**

#### **Why This Matters:**
- **LiPo batteries can explode** if overcharged or damaged
- **No BMS (Battery Management System)** in this firmware
- **Thermal runaway** can occur without proper management
- **Fire risk** is real and documented in electronics failures

### Testing Battery Disable

After configuration, test that:
- Device runs normally on USB power only
- Device shuts down within 1 second if battery power is detected
- No battery charging occurs under any circumstances
- OLED display shows "USB Power" status only

**🚨 SAFETY FIRST: This firmware is designed for USB-powered operation only. Battery usage creates unacceptable fire hazards and is strictly prohibited.**

## Troubleshooting

### Board Not Responding
- **Symptom**: Blank screen, red LED flashing
- **Cause**: Wrong firmware version on board (V2 firmware on V1 hardware)
- **Solution**: Erase flash and flash correct firmware

### Flashing Issues
- **Symptom**: "Chip stopped responding"
- **Cause**: Communication issues during flash
- **Solution**: Try lower baud rate (115200) or check USB connection

### Build Errors
- **Symptom**: Compilation failures
- **Cause**: Missing dependencies or configuration
- **Solution**: Ensure PlatformIO is properly installed and updated

## Development

### Building from Source

1. **Clone this repository**
2. **Install dependencies**:
   ```bash
   pio pkg install
   ```
3. **Build for your board**:
   ```bash
   # For V1 (4MB)
   pio run -e heltec-v1

   # For V2/V2.1 (8MB)
   pio run -e heltec-v2_1
   ```

### Project Structure

```
├── src/                    # Firmware source code
├── variants/               # Board-specific configurations
│   └── esp32/
│       ├── heltec_v1/      # V1 board configuration
│       ├── heltec_v2/      # V2 board configuration
│       └── heltec_v2.1/    # V2.1 board configuration
├── platformio.ini          # PlatformIO configuration
├── userPrefs.jsonc         # Build preferences
├── partition-table.csv     # Flash partition layout
├── .env.sample             # Sample environment configuration
├── flash_meshtastic.sh     # Automated flashing script
├── ARCHITECTURE.md         # Detailed hardware info
├── LILYGO_ROUTER_GUIDE.md  # LilyGo router setup guide
└── README.md               # This file
```

## Contributing

This project welcomes contributions! Please:

1. Test changes on both V1 and V2/V2.1 hardware
2. Update documentation for any hardware-specific changes
3. Ensure backward compatibility

## License

This project is based on Meshtastic firmware, which is licensed under the GPL-3.0 license.

---

*This project was prepared with the assistance of GitHub Copilot.*

## Community & Support

### Getting Help
- **Meshtastic Discord**: Join the official community at [discord.gg/ktMAKGB2Bs](https://discord.gg/ktMAKGB2Bs)
- **GitHub Issues**: Report bugs or request features in this repository
- **Meshtastic Forums**: Community discussions at [meshtastic.discourse.group](https://meshtastic.discourse.group)

### Contributing
- **Hardware Testing**: Test on additional 26MHz crystal boards
- **Documentation**: Improve setup guides and troubleshooting
- **Bug Reports**: Help identify and fix issues
- **Feature Requests**: Suggest improvements for unsupported hardware

### Related Communities
- **Meshtastic Subreddit**: r/meshtastic
- **LoRa Communities**: r/LoRa, r/RTLSDR
- **ESP32 Communities**: ESP32 forums and Discord servers
- **Ham Radio**: Digital modes communities

## Sharing This Project

### Quick Share Links
- **GitHub Repository**: https://github.com/bmw330i/Meshtastic_LoRa32_26mhz
- **Direct Download**: Latest release assets
- **Documentation**: This README and guides

### Community Outreach
If you found this helpful for your Heltec/TTGO boards, please share with others who might benefit!

**Share on:**
- Meshtastic Discord #hardware channel
- Reddit (r/meshtastic, r/LoRa, r/esp32)
- Meshtastic forums
- GitHub discussions on the main Meshtastic repo

**Helpful message:**
*"If you have Heltec WiFi LoRa 32 boards with 26MHz crystals that aren't supported by standard Meshtastic firmware, check out this community solution: https://github.com/bmw330i/Meshtastic_LoRa32_26mhz"*

See `COMMUNITY_OUTREACH.md` for detailed sharing strategies and target communities.

---

**Found this useful? ⭐ Star this repo and share with fellow Meshtastic enthusiasts!**
