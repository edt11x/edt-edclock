# edt-edclock

A modern, ultra-compact Linux desktop clock and calendar application built with React, TypeScript, and Electron. Designed for XFCE, Gnome, and other Linux desktop environments.

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

## Features

- **Large Digital Clock**: High-visibility time display with a sleek monospace font.
- **Full Date Display**: Shows the day of the week and the complete date.
- **Interactive Calendar**: Navigate through months and years with a compact, grid-based calendar highlighting the current day.
- **Ultra-Compact Design**: Optimized vertical layout (320x310px) to save screen real estate.
- **Modern Aesthetics**: Dark-themed UI with glassmorphism (background blur), transparency, and subtle transitions.
- **Desktop Ready**:
    - Frameless window design.
    - "Always on Top" functionality.
    - Draggable window — click anywhere on the window to reposition it (Wayland/GNOME compatible in the Python version).
    - Dedicated close button.
    - **Clean Launch**: Automatically detects and terminates previous instances before starting a new one.

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
- [Vanilla CSS](https://developer.mozilla.org/en-US/docs/Web/CSS)
