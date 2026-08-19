# edt-edclock (Slint + Rust)

A native Linux clock and calendar application built with Rust and the Slint UI framework.

## Features
- Digital clock (HH:MM:SS).
- Full interactive calendar with month/year navigation.
- Disk usage indicator.
- Lower-right grey square copies a preset phrase to the clipboard (same as the Windows app).
- Ships as a standalone binary plus a few desktop libraries (fontconfig, Wayland/X11, OpenGL).

## Requirements

**Do not use Ubuntu/Debian `apt install rustc` to build this project.** Slint 1.16 is
Rust edition 2024 and needs **rustc 1.88+**. The distro compiler (often 1.75–1.80) fails with:

- `feature edition2024 is required`
- `lock file version 4 requires -Znext-lockfile-bump`

`./setup.sh` installs rustup's stable toolchain when the system compiler is too old,
plus the C libraries needed to compile and run.

| Distro | How to install the app |
| --- | --- |
| Ubuntu / Debian | `./build-deb.sh` then `sudo apt install ./dist/edt-edclock-slint_*.deb` |
| Fedora | `./install.sh` (uses `dnf` for dependencies) |

A `.deb` built on Fedora 43 needs **glibc 2.39+** (Ubuntu 24.04+, Debian 13+). On older
releases, build on the target machine with `./setup.sh && ./install.sh`.

## How to Install

### Ubuntu and Debian (.deb)

```bash
./build-deb.sh
sudo apt install ./dist/edt-edclock-slint_*.deb
```

`apt` installs the runtime libraries the package `Depends` on (fontconfig, libxkbcommon,
Wayland, X11, OpenGL, …). Prefer `apt install ./file.deb` over `dpkg -i` so dependencies
are pulled automatically.

### Fedora (`install.sh`)

```bash
./install.sh              # ~/.local/bin + desktop launcher
./install.sh --system     # /usr/local (needs sudo)
```

This installs the dnf packages the app needs, compiles a release binary if one is not
already built, and installs the launcher.

### From source (any distro)

```bash
./setup.sh
./install.sh
```

## How to Run
```bash
./run.sh
```
Or after installation:
```bash
edt-edclock-slint
edt-edclock-slint --version
edt-edclock-slint --help
```
The window title includes the crate version (`edt-edclock (Slint) v0.2.1`).

## Tests
```bash
cargo test
```

## How to Build
```bash
cargo build --release
```
The binary will be located at `target/release/edt-edclock-slint`.
