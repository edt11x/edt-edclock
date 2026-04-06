# edt-edclock-py

A native Python (PySide6/Qt) implementation of the ultra-compact Linux desktop clock and calendar application.

## Prerequisites

- Python 3.8+
- PySide6

## Setup

It's recommended to use a virtual environment:

```bash
chmod +x setup-py.sh
./setup-py.sh
```

Or manually:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Running

```bash
chmod +x run.sh
./run.sh
```

## Features

- **Large Digital Clock**: High-visibility time display with hours (blue), minutes (violet), and seconds (emerald) in distinct colors.
- **Date Display**: Shows the day of the week and full date (e.g., April 6, 2026).
- **Interactive Calendar**:
    - Navigate through months and years using intuitive controls.
    - **Live Highlight**: The current day is automatically highlighted and updates in real-time when the date changes.
    - Color-coded weekend columns (Sunday/Saturday) and red-tinted weekend day numbers.
- **Ultra-Compact UI**: Optimized 320x318px layout to save screen real estate.
- **Modern Aesthetics**: Dark-themed UI with a subtle purple border glow and interactive hover effects on calendar days.
- **Desktop Ready**:
    - Frameless and transparent window design.
    - "Always on Top" functionality.
    - Draggable — click and drag anywhere on the window to reposition.
- **Background Execution**: Includes `start-background.sh` to launch the application detached from the terminal, suitable for login autostart.
