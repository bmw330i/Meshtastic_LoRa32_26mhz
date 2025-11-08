#!/bin/bash

# Meshtastic Firmware Flashing Script for Heltec WiFi LoRa 32 Boards
# Supports V1 (4MB) and V2/V2.1 (8MB) variants with automatic detection

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BAUD_RATE=115200
PIO_ENV=""
BOARD_TYPE=""
FLASH_SIZE=""
SERIAL_PORT=""

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect serial ports
detect_serial_ports() {
    print_info "Detecting serial ports..."

    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SERIAL_PORTS=$(ls /dev/cu.usbserial* 2>/dev/null || ls /dev/cu.SLAB* 2>/dev/null || ls /dev/cu.wchusbserial* 2>/dev/null || true)
    # Linux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        SERIAL_PORTS=$(ls /dev/ttyUSB* 2>/dev/null || ls /dev/ttyACM* 2>/dev/null || true)
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    if [ -z "$SERIAL_PORTS" ]; then
        print_error "No serial ports detected. Please ensure your Heltec board is connected."
        echo "Common serial port names:"
        echo "  macOS: /dev/cu.usbserial-XXXX, /dev/cu.SLAB_USBtoUART, /dev/cu.wchusbserialXXXX"
        echo "  Linux: /dev/ttyUSB0, /dev/ttyACM0"
        exit 1
    fi

    # Count ports
    PORT_COUNT=$(echo "$SERIAL_PORTS" | wc -l)

    if [ "$PORT_COUNT" -eq 1 ]; then
        SERIAL_PORT=$(echo "$SERIAL_PORTS" | head -n1)
        print_success "Found serial port: $SERIAL_PORT"
    else
        print_warning "Multiple serial ports detected:"
        echo "$SERIAL_PORTS" | nl
        echo ""
        read -p "Enter the number of the correct port: " PORT_NUM
        SERIAL_PORT=$(echo "$SERIAL_PORTS" | sed -n "${PORT_NUM}p")
        if [ -z "$SERIAL_PORT" ]; then
            print_error "Invalid port selection"
            exit 1
        fi
        print_success "Selected serial port: $SERIAL_PORT"
    fi
}

# Function to detect board type
detect_board_type() {
    print_info "Detecting board type..."

    # Check if esptool is available
    if ! command_exists esptool.py && ! command_exists esptool; then
        print_error "esptool not found. Please install it with: pip install esptool"
        exit 1
    fi

    # Use esptool to get flash ID
    ESPTOOL_CMD="esptool.py"
    if ! command_exists esptool.py; then
        ESPTOOL_CMD="esptool"
    fi

    print_info "Reading flash information..."
    FLASH_INFO=$($ESPTOOL_CMD --chip esp32 --port "$SERIAL_PORT" flash_id 2>/dev/null)

    if echo "$FLASH_INFO" | grep -q "4MB"; then
        BOARD_TYPE="V1"
        FLASH_SIZE="4MB"
        PIO_ENV="heltec-v1"
        print_success "Detected Heltec V1 board (4MB flash)"
    elif echo "$FLASH_INFO" | grep -q "8MB"; then
        BOARD_TYPE="V2"
        FLASH_SIZE="8MB"
        PIO_ENV="heltec-v2_1"
        print_success "Detected Heltec V2/V2.1 board (8MB flash)"
    else
        print_warning "Could not determine flash size from:"
        echo "$FLASH_INFO"
        echo ""
        print_info "Please manually select your board type:"
        echo "1) Heltec V1 (4MB flash)"
        echo "2) Heltec V2/V2.1 (8MB flash)"
        read -p "Enter your choice (1 or 2): " BOARD_CHOICE

        case $BOARD_CHOICE in
            1)
                BOARD_TYPE="V1"
                FLASH_SIZE="4MB"
                PIO_ENV="heltec-v1"
                print_success "Selected Heltec V1 board"
                ;;
            2)
                BOARD_TYPE="V2"
                FLASH_SIZE="8MB"
                PIO_ENV="heltec-v2_1"
                print_success "Selected Heltec V2/V2.1 board"
                ;;
            *)
                print_error "Invalid choice"
                exit 1
                ;;
        esac
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check for PlatformIO
    if ! command_exists pio; then
        print_error "PlatformIO not found. Please install it from: https://platformio.org"
        exit 1
    fi
    print_success "PlatformIO found"

    # Check for esptool
    if ! command_exists esptool.py && ! command_exists esptool; then
        print_error "esptool not found. Please install it with: pip install esptool"
        exit 1
    fi
    print_success "esptool found"

    # Check for .env file
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Using default credentials."
        print_info "Consider creating a .env file with secure credentials:"
        echo "MQTT_USERNAME=your_secure_username"
        echo "MQTT_PASSWORD=your_secure_password"
        echo "WIFI_SSID=your_wifi_ssid"
        echo "WIFI_PSK=your_wifi_password"
    else
        print_success ".env file found"
    fi
}

# Function to build firmware
build_firmware() {
    print_info "Building firmware for $BOARD_TYPE board..."

    if ! pio run -e "$PIO_ENV"; then
        print_error "Firmware build failed"
        exit 1
    fi

    print_success "Firmware built successfully"
}

# Function to flash firmware
flash_firmware() {
    print_info "Flashing firmware to $BOARD_TYPE board..."

    FIRMWARE_FILE=".pio/build/$PIO_ENV/firmware.factory.bin"

    if [ ! -f "$FIRMWARE_FILE" ]; then
        print_error "Firmware file not found: $FIRMWARE_FILE"
        exit 1
    fi

    print_info "Firmware file size: $(ls -lh "$FIRMWARE_FILE" | awk '{print $5}')"

    # Use esptool for flashing
    ESPTOOL_CMD="esptool.py"
    if ! command_exists esptool.py; then
        ESPTOOL_CMD="esptool"
    fi

    print_info "Starting flash process (this may take a few minutes)..."

    if $ESPTOOL_CMD --chip esp32 --port "$SERIAL_PORT" --baud "$BAUD_RATE" write_flash -z 0x0 "$FIRMWARE_FILE"; then
        print_success "Firmware flashed successfully!"
        print_info "The board will restart automatically."
        print_info "Check the OLED display for the Meshtastic interface."
    else
        print_error "Flashing failed. Try these troubleshooting steps:"
        echo "1. Check USB connection and try a different cable"
        echo "2. Try a lower baud rate: --baud 9600"
        echo "3. Ensure no other programs are using the serial port"
        echo "4. Try erasing flash first: esptool.py --chip esp32 --port $SERIAL_PORT erase_flash"
        exit 1
    fi
}

# Function to show menu
show_menu() {
    echo ""
    echo "========================================"
    echo " Meshtastic Firmware Flashing Script"
    echo "========================================"
    echo ""
    echo "This script will:"
    echo "1. Detect your Heltec board type"
    echo "2. Build the appropriate firmware"
    echo "3. Flash it to your board"
    echo ""
    echo "Supported boards:"
    echo "- Heltec WiFi LoRa 32 V1 (4MB flash)"
    echo "- Heltec WiFi LoRa 32 V2/V2.1 (8MB flash)"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        exit 0
    fi
}

# Main function
main() {
    echo ""
    echo "========================================"
    echo " Meshtastic Firmware Flashing Script"
    echo "========================================"

    show_menu
    check_prerequisites
    detect_serial_ports
    detect_board_type
    build_firmware
    flash_firmware

    echo ""
    print_success "Flashing completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "1. The board should show the Meshtastic interface on the OLED display"
    echo "2. Use a phone with the Meshtastic app to configure your device"
    echo "3. Change default credentials in the app for security"
    echo "4. Join or create a mesh network"
    echo ""
    print_info "For more information, see README.md and ARCHITECTURE.md"
}

# Run main function
main "$@"