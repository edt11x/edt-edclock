#!/bin/bash
# run.sh - Build and run the Slint application
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' "$SCRIPT_DIR/Cargo.toml" | head -n1)"
case "${1:-}" in
    -h|--help)
        cat <<EOF
edt-edclock-slint run ${VERSION}
Build (release) and start the clock.

Usage: $0 [OPTIONS] [-- APP_ARGS...]

Options:
  -h, --help     Show this help and exit
  -V, --version  Show version and exit

Any arguments after -- are passed to the app (e.g. -- --version).
EOF
        exit 0
        ;;
    -V|--version)
        echo "edt-edclock-slint ${VERSION}"
        exit 0
        ;;
    --)
        shift
        ;;
esac
cd "$SCRIPT_DIR"
cargo run --release -- "$@"
