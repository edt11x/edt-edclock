#!/bin/bash

# Load NVM if it exists
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
    # Use version from .nvmrc if available
    if [ -f ".nvmrc" ]; then
        nvm use
    fi
fi

echo "🕒 Launching edt-edclock..."
npm run electron:dev
