#!/bin/bash

# Load NVM if it exists
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
    # Use version from .nvmrc if available
    if [ -f ".nvmrc" ]; then
        nvm use
    fi
fi

echo "🧹 Cleaning up previous instances..."
# Kill any existing processes related to this app
pkill -f "electron . --type=render" || true
pkill -f "electron ." || true

echo "🕒 Launching edt-edclock..."
# Use wait-on with a timeout and electron via npx
npx concurrently "npm run dev" "npx wait-on http://localhost:5173 --timeout 30000 && npx electron ."
