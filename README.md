# edt-edclock

A modern, ultra-compact Linux desktop clock and calendar application built with React, TypeScript, and Electron. Designed for XFCE, GNOME, and other Linux desktop environments.

## Project Versions

This project is available in two implementations:

### 1. React + Electron (Original)
Modern, web-based implementation using React, TypeScript, and Electron.
- **Location**: Root directory
- **Setup**: `./setup.sh`
- **Run**: `./run.sh`

### 2. Python + Qt (PySide6)
Native Python implementation using the Qt framework.
- **Location**: `edt-edclock-py/`
- **Setup**: `cd edt-edclock-py && ./setup-py.sh`
- **Run**: `cd edt-edclock-py && ./run.sh`
- **Background / login autostart**: `cd edt-edclock-py && ./start-background.sh`

## Features

- **Large Digital Clock**: High-visibility time display with a monospace font. In the Python version, hours, minutes, and seconds are rendered in graduated Obsidian accent tones (off-white / lavender / deep violet).
- **Full Date Display**: Shows the day of the week and the complete date.
- **Interactive Calendar**: Navigate through months and years with a compact grid calendar. Today is highlighted, and weekend columns are color-coded.
- **Disk Usage**: A line below the calendar shows home directory filesystem usage — free space, total, and percentage used. Refreshes every 30 seconds.
- **Ultra-Compact Design**: Optimized vertical layout (320×342 px Python / 320×334 px Electron) to save screen real estate.
- **Obsidian-Inspired Aesthetics**: Dark charcoal-violet background (`#1e1e2e`-family), single purple accent (`#7b6cd8`), deep violet today-pill (`#483699`), and muted lavender text — cohesive and easy on the eyes.
- **Desktop Ready**:
    - Frameless window design.
    - "Always on Top" functionality.
    - Draggable window — click anywhere to reposition (Wayland/GNOME compatible in the Python version).
    - Dedicated close button.
    - **Clean Launch**: Automatically detects and terminates previous instances before starting a new one.

## Login Autostart (Python version)

`start-background.sh` launches the clock fully detached from the terminal using `nohup` + `setsid`, so it survives after the calling shell exits. It also kills any previous instance on re-launch. Logs are written to `edclock.log` and the PID is stored in `edclock.pid`.

Wire it into your login using whichever method fits your desktop:

**Shell profile** (any login shell):
```bash
echo '/path/to/edt-edclock/edt-edclock-py/start-background.sh' >> ~/.profile
```

**X11 session start:**
```bash
echo '/path/to/edt-edclock/edt-edclock-py/start-background.sh' >> ~/.xprofile
```

**GNOME autostart .desktop entry** (recommended for GNOME):
```ini
# ~/.config/autostart/edt-edclock.desktop
[Desktop Entry]
Type=Application
Name=edt-edclock
Exec=/path/to/edt-edclock/edt-edclock-py/start-background.sh
X-GNOME-Autostart-enabled=true
```

## Development

To set up the environment (requires [NVM](https://github.com/nvm-sh/nvm)):

```bash
chmod +x setup.sh
./setup.sh
```

To start the application:

```bash
chmod +x run.sh
./run.sh
```

## Building

To create a standalone Linux executable (AppImage or .deb):

```bash
npm run electron:build
```

The output will be located in the `dist-electron` directory.

## Technologies Used

- [React](https://react.dev/)
- [Vite](https://vitejs.dev/)
- [Electron](https://www.electronjs.org/)
- [TypeScript](https://www.typescriptlang.org/)
- [PySide6 / Qt](https://doc.qt.io/qtforpython/)
- [Vanilla CSS](https://developer.mozilla.org/en-US/docs/Web/CSS)
