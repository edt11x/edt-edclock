# edt-edclock (Slint + Rust)

A native Linux clock and calendar application built with Rust and the Slint UI framework.

## Features
- Digital clock (HH:MM:SS).
- Full interactive calendar with month/year navigation.
- Disk usage indicator.
- Minimal dependencies (compiled to a standalone binary).

## Requirements
- Rust (Cargo)

## How to Install
To install the application to your local user directory (`~/.local/bin`) and add it to your desktop application menu:
```bash
./install.sh
```

## How to Run
```bash
./run.sh
```
Or manually after installation:
```bash
edt-edclock-slint
```

## How to Build
```bash
cargo build --release
```
The binary will be located at `target/release/edt-edclock-slint`.
