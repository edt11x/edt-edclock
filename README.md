# edt-edclock

A modern, ultra-compact Linux desktop clock and calendar application built with React, TypeScript, and Electron. Designed for XFCE, Gnome, and other Linux desktop environments.

## Features

- **Large Digital Clock**: High-visibility time display with a sleek monospace font.
- **Full Date Display**: Shows the day of the week and the complete date.
- **Interactive Calendar**: Navigate through months and years with a compact, grid-based calendar highlighting the current day.
- **Ultra-Compact Design**: Optimized vertical layout (320x380px) to save screen real estate.
- **Modern Aesthetics**: Dark-themed UI with glassmorphism (background blur), transparency, and subtle transitions.
- **Desktop Ready**: 
    - Frameless window design.
    - "Always on Top" functionality.
    - Integrated drag handle for easy positioning.
    - Dedicated close button.

## Development

To start the application in development mode with hot-reloading:

```bash
npm install
npm run electron:dev
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
