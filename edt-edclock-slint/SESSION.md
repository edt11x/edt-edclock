# Session notes — edt-edclock-slint

Prompts and answers through **v0.2.1**, so this tree can be resumed later.

## Prompt 1 — packaging and Ubuntu rustc

**User:** Work on `edt-edclock-slint`. Ubuntu reports `feature edition2024 is required` and lock file version 4 requires `-Znext-lockfile-bump`. Add `.deb` installers for Ubuntu/Debian and an `install.sh` for Fedora that install needed dependencies.

**Done:**
- Crate `edition = "2021"`, `rust-version = "1.88"`, `Cargo.lock` version **3**.
- Slint 1.16.1 itself is edition 2024 / rustc 1.88+; `setup.sh` installs rustup when apt `rustc` is too old.
- `build-deb.sh` writes `dist/edt-edclock-slint_*_amd64.deb` with runtime `Depends`.
- Fedora `install.sh` uses `dnf` for runtime (and build, if needed) packages.
- Calendar month/year buttons share one `Rc<Cell<_>>` (Copy ints were stale per button).

**Decision:** One amd64 `.deb` for both Ubuntu and Debian. A Fedora-built binary needs glibc 2.39 (Ubuntu 24.04+ / Debian 13+). Older releases build from source.

## Prompt 2 — commit workflow

**User:** Create/update this as the global “Commit Workflow”, run it, store prompts, tests, version in UI/CLI, memory/plan files, lint, clean debug+release builds, Cursor/Snyk trust+scan, commit, push. No recursion or duplicated steps. Ask rather than guess.

**Done:**
- Global skill `~/.grok/skills/commit-workflow/SKILL.md` (single-pass phases; anti-reentry).
- Global workflow `~/.grok/workflows/commit-workflow.rhai` (smoke-checked; not launched live in this session to avoid a second commit).
- This in-session run **is** the commit workflow (skill executed once).
- Version **0.2.0** in Cargo.toml, window title, `--help` / `--version` on the binary and helper scripts.
- Unit tests for calendar nav, grid, disk formatting, CLI.

**Unrelated / left unstaged:** root `package-lock.json` npm lockfile churn present before this session. Not part of the Slint change.

**Scanners:** Snyk CLI and Cursor code-scan CLI were not available. Substitutes: `cargo test`, `cargo check`. Workspace trust files added under `.vscode/` and `.cursor/`; `.snyk` policy at repo root.

## Prompt 3 — Windows clipboard square

**User:** The Windows app has a small grey dot that copies a magic string to the clipboard. Port that to Slint.

**Done:** 12×12 lower-right square copies `iShouldaBoughtAServerTech!` via `arboard` (X11 + Wayland). Phrase in `src/clipboard.rs`. Version **0.2.1**.

## Prompt 4 — commit workflow + push

**User:** Run the commit workflow and push.

**Done:** This landing. `package-lock.json` left unstaged again (unrelated npm lockfile).

## Resume hints

- App crate: `edt-edclock-slint/` (lib + binary).
- Tests: `cd edt-edclock-slint && cargo test`
- Deb: `./build-deb.sh` (rebuild after a version bump).
- Do not use Ubuntu `apt install rustc` to compile; use `./setup.sh` / rustup.
