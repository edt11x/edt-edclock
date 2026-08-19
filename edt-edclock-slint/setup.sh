#!/bin/bash
# setup.sh - Install build/runtime dependencies and a new-enough Rust toolchain.
#
# Ubuntu/Debian "apt install rustc" is not enough: this project (via Slint 1.16)
# needs rustc >= 1.88. An old compiler fails with:
#   - "feature edition2024 is required"
#   - "lock file version 4 requires -Znext-lockfile-bump"
# This script installs rustup's stable toolchain in that case.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' "$PROJECT_DIR/Cargo.toml" | head -n1)"
case "${1:-}" in
    -h|--help)
        cat <<EOF
edt-edclock-slint setup ${VERSION}
Install build/runtime libraries and rustc >= 1.88 (via rustup if needed).

Usage: $0 [OPTIONS]

Options:
  -h, --help     Show this help and exit
  -V, --version  Show version and exit
EOF
        exit 0
        ;;
    -V|--version)
        echo "edt-edclock-slint ${VERSION}"
        exit 0
        ;;
esac
# shellcheck source=packaging/linux-deps.sh
. "$PROJECT_DIR/packaging/linux-deps.sh"

echo "==> Installing system packages (build + runtime)..."
ensure_system_packages all

echo "==> Ensuring rustc >= $MIN_RUSTC..."
ensure_rust

echo "==> Fetching and compiling crate dependencies..."
cd "$PROJECT_DIR"
# Prefer rustup's cargo when present (PATH may still point at apt cargo).
if [ -x "$HOME/.cargo/bin/cargo" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
cargo build --release

echo
echo "Setup complete."
echo "  Run the app:    ./run.sh"
echo "  User install:   ./install.sh"
echo "  Ubuntu/Debian:  ./build-deb.sh   then  sudo apt install ./dist/edt-edclock-slint_*.deb"
