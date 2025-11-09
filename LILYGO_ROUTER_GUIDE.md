# LilyGo T22 v1.1 Router + TTGO Client Setup Guide

## 🚨 USE AT YOUR OWN RISK - SAFETY WARNING 🚨

**This software is provided "AS IS" without warranty of any kind. Use entirely at your own risk.**

### ⚠️ REPORTED BATTERY SAFETY ISSUES
Community members have reported that **battery connectors on some boards can cause batteries to overheat**, potentially leading to thermal runaway, fires, or explosions. While this patched version has implemented safety measures to disable battery charging and enable auto-shutdown on battery detection, **these issues may still occur due to hardware limitations**.

### 🔧 REMEDIATION STEPS TAKEN
This firmware includes the following safety measures:
- **Battery charging disabled** at hardware level (0mA charging current)
- **Auto-shutdown** within 1 second of battery detection
- **USB-only operation** enforced through firmware configuration
- **Explicit warnings** against battery usage

### ⚠️ OUT OF AN ABUNDANCE OF CAUTION
Despite these safety measures, we **strongly advise against using any batteries** with this firmware. The underlying hardware limitations and reported overheating issues mean that **battery usage remains a significant risk**. Only proceed with battery usage if you fully understand and accept these risks.

**For maximum safety: Use USB power only and physically disable/remove battery connectors.**

---

## ⚠️ CRITICAL SAFETY WARNING: LiPo Battery Fire Hazard

**🚨 DANGER: DO NOT USE LiPo BATTERIES WITH THIS FIRMWARE! 🚨**

This firmware is designed **exclusively for USB-powered operation only**. The LilyGo T22 v1.1 board has a LiPo battery connector that poses a **severe fire hazard** if used.

### Why LiPo Batteries Are Dangerous
- **Thermal Runaway**: LiPo batteries can overheat, catch fire, or explode
- **No Safety Circuit**: This firmware does not include battery management or protection
- **Overvoltage Risk**: Uncontrolled charging can damage batteries and cause fires
- **Fire Hazard**: Lithium polymer batteries have caused numerous fires in electronics
- **Connector Overheating**: Community reports indicate battery connectors can cause excessive heating, potentially leading to thermal runaway even with safety measures in place

### Supported Power Sources
- ✅ **USB Power Only** (5V regulated power from USB port)
- ❌ **LiPo Batteries** (NEVER use - fire hazard)

### If You Have a Battery Connector
**IMMEDIATELY DISABLE OR REMOVE IT:**
- Configure auto-shutdown on battery detection (see below)
- Physically remove the battery connector from the PCB
- Cut traces to the battery connector if necessary
- Use electrical tape to insulate any exposed contacts

**This firmware is for USB-powered devices ONLY. Battery usage will void any safety considerations and is done at your own risk. Despite remediation steps, reported connector overheating issues may still pose fire hazards.**

---

## Your Hardware Setup

**Router (LilyGo T22 v1.1):**
- TTGO LoRa32 868/915MHz module
- Neo-6M GPS module
- LiPo battery holder
- Configured as ROUTER role

**Client Nodes (TTGO V1/V2):**
- Heltec WiFi LoRa 32 boards
- Smaller form factor
- Configured as CLIENT role

## Quick Setup Steps

### 1. Configure Router (LilyGo T22)
1. Open Meshtastic app on phone
2. Connect to LilyGo device via Bluetooth
3. Go to **Device Settings** → **Role** → Select **ROUTER**
4. Go to **Position** → Enable **GPS** and set update interval to 30 seconds
2. Go to **Radio** → Configure channel settings (note these down)

### Bluetooth Connection for Setup

**All your devices connect via Bluetooth for configuration:**

#### **Connect LilyGo Router**
1. Power on LilyGo T22
2. Open Meshtastic app
3. Device appears as "Meshtastic_XXXX"
4. Tap to connect (may take 10-30 seconds)
5. Configure as ROUTER role

#### **Connect TTGO Clients**
1. Power on each TTGO board
2. They appear as separate devices in app
3. Connect and configure as CLIENT role
4. Match channel settings exactly

#### **What You Can Do via Bluetooth**
- ✅ Send/receive messages
- ✅ Configure device settings
- ✅ Monitor network status
- ✅ View GPS positions on map
- ✅ Update firmware over-the-air

#### **Bluetooth Tips**
- Keep devices within 10-30 meters during setup
- Once configured, devices work independently via LoRa
- Bluetooth is only needed for configuration changes

## Expected Behavior

### 2. Configure Client Nodes (TTGO V1/V2)
1. Connect each TTGO board to Meshtastic app
2. Set **Device Role** to **CLIENT** (default)
3. Go to **Radio** → **Channels** → Match EXACTLY with router:
   - Same channel name
   - Same modem preset
   - Same frequency band (868 or 915 MHz)
   - Same PSK (network key)

### 3. Test Connectivity
1. Place devices within LoRa range (start close together)
2. Send test messages between devices
3. Use **Range Test** feature to verify routing
4. Check **Node Map** to see all devices

## Expected Behavior

### Router Functions
- ✅ Relays messages between client nodes
- ✅ Shares GPS position for mapping
- ✅ Maintains network connectivity
- ✅ Can operate on battery power

### Client Node Functions
- ✅ Send/receive messages through router
- ✅ Share location if GPS enabled
- ✅ Participate in mesh network
- ✅ Connect to phone app for configuration

## Network Topologies

### Basic Setup (2 devices)
```
TTGO Client ─── LilyGo Router
```

### Extended Setup (3+ devices)
```
TTGO V1 ─── LilyGo Router ─── TTGO V2
```

### Mobile Network
```
TTGO V1 ─── LilyGo Router (mobile) ─── TTGO V2
                    │
                 (GPS tracking)
```

## Troubleshooting

### No Communication
- **Check**: All devices on same channel/frequency
- **Check**: Router has power and is functioning
- **Test**: Range test between devices
- **Fix**: Reset channel settings and reconfigure

### GPS Not Working
- **Check**: Clear sky view for GPS satellites
- **Check**: GPS module properly connected
- **Test**: Wait 2-3 minutes for cold start
- **Fix**: Move device outdoors away from buildings

### Router Not Routing
- **Check**: Router role is set to ROUTER
- **Check**: Router has adequate power
- **Test**: Direct communication between clients
- **Fix**: Re-flash router firmware if needed

## Advanced Features

### GPS Tracking
- Router broadcasts position every 30 seconds
- View all nodes on map in Meshtastic app
- Set waypoints for navigation

### Power Management
- Router can run on LiPo battery
- Monitor battery levels in app
- Configure sleep modes for power saving

### Range Extension
- Position router at high elevation
- Use directional antennas if available
- Add more routers for larger coverage

## Use Cases for Your Setup

### Outdoor Activities
- Hiking group coordination
- Mountain biking trails
- Camping communication
- Search and rescue operations

### Community Networks
- Neighborhood watch
- Event coordination
- Emergency backup communication

### IoT Monitoring
- Environmental sensors
- Asset tracking
- Remote equipment monitoring

## Pro Tips

1. **Start Simple**: Test with 2 devices close together first
2. **Same Channel**: All devices MUST use identical channel settings
3. **GPS Outdoors**: Test GPS functionality outside
4. **Power Planning**: Router needs consistent power for best performance
5. **Backup Config**: Note down all channel settings
6. **Regular Testing**: Test range and connectivity periodically

## Understanding OLED Messages

### What "PING33" Means
- **PING** = Connectivity test message
- **33** = Node number of the sending device
- **Normal Activity** = Your mesh network is working!

### Other Common Messages
- **From: NodeName** - Text messages
- **Pos: NodeName** - GPS position updates
- **Route: NodeName** - Message routing
- **ACK** - Message delivery confirmation

### Router-Specific Indicators
- **Nodes: 5** - Total devices in network
- **Route: Active** - Router is forwarding messages
- **GPS: Fixed** - Location lock acquired

Your LilyGo router + TTGO clients create a robust, portable mesh network! 🚀📡

## ⚠️ Safety Notice: LiPo Battery Connector

**IMPORTANT:** The LilyGo T22 v1.1 board has a LiPo battery connector that poses a **SEVERE FIRE HAZARD**.

### 🚨 CRITICAL SAFETY REQUIREMENTS
1. **NEVER connect LiPo batteries** to this board
2. **Configure auto-shutdown** on battery detection immediately
3. **Use USB power ONLY** (5V regulated from USB port)
4. **Physically disable** the battery connector if possible

### Firmware Safety Features Applied
- **Auto-Shutdown**: Device shuts down 1 second after detecting battery power
- **Charging Disabled**: Hardware charging circuits set to 0mA (disabled)
- **USB-Only Operation**: Designed exclusively for regulated USB power

### Quick Safety Configuration (REQUIRED)
1. **Via Bluetooth App**: Set "Shutdown after X seconds on battery" to 1 second
2. **Via Config**: Add `"USERPREFS_CONFIG_POWER_ON_BATTERY_SHUTDOWN_AFTER_SECS": "1"` to userPrefs.jsonc
3. **Hardware Option**: Physically remove or disable the battery connector

### Why This Matters
- **LiPo batteries can explode** if overcharged or damaged
- **No BMS (Battery Management System)** in this firmware
- **Thermal runaway** can occur without proper management
- **Fire risk** is real and documented in electronics failures
- **Connector overheating** has been reported by community members despite safety measures

**Safety First!** Despite remediation steps, reported battery connector overheating issues mean you must configure auto-shutdown and use USB power only - this firmware remains high-risk for battery usage.</content>
<parameter name="filePath">/Users/david/Documents/Meshtastic_LoRa32_26mhz/LILYGO_ROUTER_GUIDE.md