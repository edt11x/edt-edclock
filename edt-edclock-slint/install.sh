#!/bin/bash
# install.sh - Fedora installer for edt-edclock-slint.
#
# Installs runtime (and, if needed, build) dependencies with dnf, builds the
# binary if necessary, then installs it plus a .desktop launcher.
#
# Usage:
#   ./install.sh              # user install to ~/.local  (default)
#   ./install.sh --system     # system install to /usr/local (needs sudo)
#   ./install.sh --prefix DIR
#
# Ubuntu/Debian: prefer the .deb from ./build-deb.sh
#   sudo apt install ./dist/edt-edclock-slint_*.deb

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' "$PROJECT_DIR/Cargo.toml" | head -n1)"
# shellcheck source=packaging/linux-deps.sh
. "$PROJECT_DIR/packaging/linux-deps.sh"

APP_NAME="edt-edclock-slint"
BINARY_NAME="edt-edclock-slint"
PREFIX="${PREFIX:-$HOME/.local}"
SYSTEM_INSTALL=0

usage() {
    cat <<EOF
edt-edclock-slint install ${VERSION}
Fedora installer (dnf deps + binary + desktop launcher).

Usage: $0 [OPTIONS]

  --system         Install to /usr/local (requires sudo)
  --prefix DIR     Install to DIR (bin/, share/applications/)
  -h, --help       Show this help and exit
  -V, --version    Show version and exit

Ubuntu/Debian: use ./build-deb.sh and sudo apt install ./dist/${APP_NAME}_*.deb
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --system)
            SYSTEM_INSTALL=1
            PREFIX="/usr/local"
            shift
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -V|--version)
            echo "edt-edclock-slint ${VERSION}"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

FAMILY="$(detect_os_family)"
INSTALL_DIR="$PREFIX/bin"
DESKTOP_DIR="$PREFIX/share/applications"
NEED_SUDO=0
if [ ! -w "$(dirname "$PREFIX")" ] 2>/dev/null || [ "$SYSTEM_INSTALL" -eq 1 ]; then
    NEED_SUDO=1
fi

if [ "$FAMILY" = debian ]; then
    echo "This tree is on Ubuntu/Debian. The packaged installer is a .deb:"
    echo "  ./build-deb.sh"
    echo "  sudo apt install ./dist/${APP_NAME}_*.deb"
    echo
    echo "Continuing with a source install (apt packages + cargo)..."
fi

echo "==> Installing runtime libraries..."
ensure_system_packages runtime

BINARY_SRC="$PROJECT_DIR/target/release/$BINARY_NAME"
if [ ! -x "$BINARY_SRC" ]; then
    echo "==> Release binary not found; installing build dependencies and compiling..."
    ensure_system_packages build
    ensure_rust
    if [ -x "$HOME/.cargo/bin/cargo" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    (cd "$PROJECT_DIR" && cargo build --release)
fi

if [ ! -x "$BINARY_SRC" ]; then
    echo "Build failed: $BINARY_SRC is missing." >&2
    exit 1
fi

echo "==> Installing to $PREFIX ..."
install_cmd() {
    if [ "$NEED_SUDO" -eq 1 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

install_cmd mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR"
install_cmd install -m 0755 "$BINARY_SRC" "$INSTALL_DIR/$BINARY_NAME"

DESKTOP_TMP="$(mktemp)"
sed "s|^Exec=.*|Exec=$INSTALL_DIR/$BINARY_NAME|" \
    "$PROJECT_DIR/packaging/edt-edclock-slint.desktop" > "$DESKTOP_TMP"
install_cmd install -m 0644 "$DESKTOP_TMP" "$DESKTOP_DIR/$APP_NAME.desktop"
rm -f "$DESKTOP_TMP"

if have_cmd update-desktop-database; then
    install_cmd update-desktop-database -q "$DESKTOP_DIR" 2>/dev/null || true
fi

echo
echo "Installation complete."
echo "  Binary:  $INSTALL_DIR/$BINARY_NAME"
echo "  Launcher: $DESKTOP_DIR/$APP_NAME.desktop"
echo "Add $INSTALL_DIR to PATH if 'edt-edclock-slint' is not found."
