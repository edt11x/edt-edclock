# edt-edclock-slint Project Memory

## Overview
A native Rust implementation of the `edt-edclock` application using the Slint UI framework.

## Project Structure
- `edt-edclock-slint/`
  - `src/main.rs`: Rust backend logic, chrono integration, and sysinfo for disk usage.
  - `ui/appwindow.slint`: Slint UI definition using a dark theme with cyan/lavender accents.
  - `Cargo.toml`: Project dependencies (`slint`, `chrono`, `sysinfo`, `num-traits`, `num-derive`).
  - `build.rs`: Compiles the Slint UI file during the build process.
  - `run.sh`: Script to build and run the application.
  - `setup.sh`: Script to verify Rust installation and fetch dependencies.
  - `install.sh`: Installs the binary to `~/.local/bin` and creates a `.desktop` entry.

## Key Implementation Details
- **UI:** Designed to match the Obsidian-like dark theme of the original app. Uses a `VerticalBox` for the main layout.
- **Clock:** Updated every second via a `slint::Timer`.
- **Calendar:** Dynamically generated in Rust using `chrono`. Supports navigation (prev/next month/year). Highlight's today's date.
- **Disk Usage:** Fetched using `sysinfo` crate and updated every minute or on startup.

## Development Notes
- To rebuild and run: `./run.sh`
- To check code validity: `cargo check`
- Slint UI files are compiled into Rust modules via `slint::include_modules!()`.

## Future Improvements
- Add more interactivity to the calendar (e.g., event markers).
- Package as a `.deb` or `AppImage` for easier distribution.
- Support for multiple disk partitions in the usage indicator.
