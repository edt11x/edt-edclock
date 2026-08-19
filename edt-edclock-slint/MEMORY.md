# edt-edclock-slint Project Memory

## Overview
A native Rust implementation of the `edt-edclock` application using the Slint UI framework.

## Project Structure
- `edt-edclock-slint/`
  - `src/main.rs`: Rust backend logic, chrono integration, and sysinfo for disk usage.
  - `ui/appwindow.slint`: Slint UI definition using a dark theme with cyan/lavender accents.
  - `Cargo.toml`: version **0.2.1**, edition **2021**, `rust-version = "1.88"`, dependencies (`slint` 1.16.1, `arboard`, `chrono`, `sysinfo`, `num-traits`, `num-derive`).
  - `src/lib.rs` + `calendar.rs` / `disk.rs` / `cli.rs`: testable core (no display).
  - `SESSION.md`, `PLAN.md`, `DESIGN.md`, `TODO.md`: session resume notes.
  - `Cargo.lock`: lockfile **version 3** so older Ubuntu/Debian cargo can parse it (v4 needs `-Znext-lockfile-bump` or Cargo 1.83+).
  - `build.rs`: Compiles the Slint UI file during the build process.
  - `run.sh`: Script to build and run the application.
  - `setup.sh`: Installs distro packages + rustup when rustc < 1.88, then `cargo build --release`.
  - `install.sh`: Fedora installer (dnf runtime/build deps, build, `~/.local` or `--system`).
  - `build-deb.sh`: Produces `dist/edt-edclock-slint_<ver>_amd64.deb` for Ubuntu/Debian; Depends lists runtime libs.
  - `packaging/linux-deps.sh`: Shared package lists and rustup helper.
  - `packaging/edt-edclock-slint.desktop`: Desktop launcher template.
  - `rust-toolchain.toml`: `stable`, honored only via rustup.

## Why Ubuntu failed to compile
- Our original `edition = "2024"` and lockfile v4, **plus** Slint 1.16.1 itself (`edition = "2024"`, `rust-version = "1.88"`).
- Ubuntu/Debian apt rustc is typically 1.75–1.80: too old. Fix is rustup (setup.sh), not apt rustc.
- The crate edition was lowered to 2021 and the lockfile to v3 so the first errors are gone; rustc 1.88+ is still required to compile Slint.

## Key Implementation Details
- **UI:** Designed to match the Obsidian-like dark theme of the original app. Uses a `VerticalBox` for the main layout.
- **Clock:** Updated every second via a `slint::Timer`.
- **Calendar:** `calendar::calendar_cells` builds a 42-cell grid. Navigation uses `prev_month` / `next_month`. View date is `Rc<Cell<_>>` in `main`.
- **Version:** `edt_edclock_slint::VERSION` / `window_title()`; Slint `app-title`; CLI `--help` / `--version`.
- **Disk Usage:** Fetched using `sysinfo` crate and updated every minute or on startup.
- **Clipboard square:** Lower-right 12×12 control copies `iShouldaBoughtAServerTech!` (`clipboard::CLIPBOARD_PHRASE`), matching `edt-edclock-windows`.

## Packaging notes
- Binary NEEDED: `libfontconfig`, `libgcc_s`, `libm`, `libc`. Wayland/X11/OpenGL are **dlopen**'d (winit): must be Depends/dnf runtime deps even though `ldd` omits them.
- Fedora-built binary currently requires GLIBC_2.39 → Ubuntu 24.04+ / Debian 13+. Older distros: build from source on that machine.
- `.deb` can be assembled with `dpkg-deb` or with `ar`+`tar` on Fedora.

## Development Notes
- To rebuild and run: `./run.sh`
- Tests: `cargo test`
- To check code validity: `cargo check`
- Slint UI files are compiled into Rust modules via `slint::include_modules!()`.
