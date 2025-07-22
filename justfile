# Default recipe - show available commands
default:
    @just --list

# Configure the project using preset
configure:
    cmake --preset=drone-firmware-debug-macos

# Build the project using preset
build: configure
    cmake --build --preset=drone-firmware-debug-macos

# Clean build directory
clean:
    rm -rf build/

# Full rebuild (clean + build)
rebuild: clean build

# Flash firmware to Pico (drag & drop method)
flash: build
    @echo "Put your Pico into BOOTSEL mode (hold BOOTSEL while plugging in USB)"
    @echo "Then drag build/debug/src/DroneFirmware_main.uf2 to the RPI-RP2 drive"
    @echo "UF2 file location: build/debug/src/DroneFirmware_main.uf2"
    @ls -la build/debug/src/*.uf2 2>/dev/null || echo "UF2 file not found - build may have failed"

# Auto-flash using picotool (if installed)
flash-auto: build
    picotool load build/debug/src/DroneFirmware_main.uf2 --force
    picotool reboot

# Monitor serial output
monitor:
    @echo "Monitoring USB serial output (Ctrl+C to exit)..."
    screen /dev/tty.usbmodem* 115200

# Show build info
info:
    @echo "Project: DroneFirmware"
    @echo "Preset: drone-firmware-debug-macos"
    @echo "Build dir: build/debug"
    @echo "Target board: seeed_xiao_rp2350"

# Install dependencies (macOS)
install-deps-macos:
    @echo "Installing dependencies via Homebrew..."
    brew install cmake ninja
    @echo "Consider installing picotool: brew install picotool"

# Development workflow - build and prepare for flash
dev: build
    @echo "Build complete! Ready to flash:"
    @echo "1. Hold BOOTSEL button on Pico"
    @echo "2. Connect USB cable"
    @echo "3. Release BOOTSEL button"
    @echo "4. Run: just flash"

# Watch for changes and rebuild (requires entr)
watch:
    find src/ -name "*.c" -o -name "*.h" -o -name "*.cpp" | entr -r just build