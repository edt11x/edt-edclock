# Design — edt-edclock-slint

Native Linux clock/calendar. Rust + Slint, dark Obsidian-like UI.

## Process split

| Crate part | Role |
| --- | --- |
| `src/calendar.rs` | Month arithmetic and 42-cell grid (no Slint). |
| `src/disk.rs` | Byte and usage-string formatting (no sysinfo). |
| `src/cli.rs` | `--help` / `--version` / run. |
| `src/lib.rs` | Version + window title helpers. |
| `src/main.rs` | Slint window, timers, sysinfo, nav callbacks. |
| `ui/appwindow.slint` | Layout; `app-title` bound to the window title. |

Sysinfo and Slint stay in the binary so `cargo test` does not need a display.

The lower-right 12×12 square copies `clipboard::CLIPBOARD_PHRASE` (`iShouldaBoughtAServerTech!`) via `arboard`, matching `edt-edclock-windows`.

## Packaging

- **Ubuntu/Debian:** `build-deb.sh` stages `/usr/bin` + `.desktop` + copyright and declares `Depends` for fontconfig plus the Wayland/X11/GL libraries winit **dlopens** (`ldd` will not list them).
- **Fedora:** `install.sh` + `packaging/linux-deps.sh` (`dnf`).
- **From source:** `setup.sh` (distro packages + rustup if rustc < 1.88).

glibc of a Fedora 43 build is currently 2.39. Documented in README.

## Calendar navigation

View date is `Rc<Cell<(year, month)>>` equivalent (`Cell` per field). Capturing `Copy` integers in several `move` closures previously gave each button its own date.
