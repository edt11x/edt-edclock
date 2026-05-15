#!/bin/bash
# setup.sh - Check for dependencies
set -e

echo "Checking for Rust..."
if ! command -v cargo &> /dev/null; then
    echo "Rust is not installed. Please install it from https://rustup.rs/"
    exit 1
fi

echo "Rust is installed: $(cargo --version)"

echo "Building the application to ensure all dependencies are fetched..."
cargo build

echo "Setup complete. Run the app with ./run.sh"
