#!/bin/bash
# install.sh - Install edt-edclock-slint to ~/.local/

set -e

# Configuration
APP_NAME="edt-edclock-slint"
BINARY_NAME="edt-edclock-slint"
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building $APP_NAME in release mode..."
cd "$PROJECT_DIR"
cargo build --release

echo "Creating installation directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"

echo "Installing binary..."
cp "$PROJECT_DIR/target/release/$BINARY_NAME" "$INSTALL_DIR/"

echo "Generating .desktop file..."
cat > "$DESKTOP_DIR/$APP_NAME.desktop" <<EOF
[Desktop Entry]
Name=EDT EdClock (Rust)
Comment=Ultra-compact digital clock and calendar
Exec=$INSTALL_DIR/$BINARY_NAME
Icon=office-calendar
Terminal=false
Type=Application
Categories=Utility;Clock;
Keywords=Clock;Calendar;Rust;Slint;
EOF

echo "Installation complete!"
echo "You can now find '$APP_NAME' in your application menu (e.g., XFCE4 or GNOME)."
echo "Binary installed to: $INSTALL_DIR/$BINARY_NAME"
