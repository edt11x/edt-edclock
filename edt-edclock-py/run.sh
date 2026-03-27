#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "Virtual environment not found. Running setup.sh first..."
    ./setup.sh
    source venv/bin/activate
fi

# Run the clock
python main.py
