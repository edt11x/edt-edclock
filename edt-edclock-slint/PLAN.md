# Plan — edt-edclock-slint

## Done (v0.2.0)

- Ubuntu rustc / lockfile v4 diagnosis and crate edition + lockfile v3.
- `.deb` builder and Fedora `install.sh` with runtime/build deps.
- Shared calendar date, unit tests, CLI/version in the title bar.
- Global commit-workflow skill + workflow.

## Next

- Build the `.deb` in Ubuntu 22.04 (or equivalent) if Ubuntu 22.04 / Debian 12 glibc is required.
- Optional: RPM via `fpm` or `cargo generate-rpm`.
- `cargo clippy` / `rustfmt` once those components are installed (not on this Fedora rustc package).
- Event markers on calendar days (called out in MEMORY.md).
- Confirm `package-lock.json` at the repo root (Electron app) separately; it was not part of this landing.
