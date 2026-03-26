#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting setup for edt-edclock..."

# Check if nvm is installed
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo "📦 Loading NVM..."
    source "$HOME/.nvm/nvm.sh"
    
    # Use version in .nvmrc if it exists
    if [ -f ".nvmrc" ]; then
        echo "📌 Using Node version from .nvmrc..."
        nvm install
        nvm use
    fi
else
    echo "⚠️  NVM not found. Please ensure Node.js (v24+) is installed manually."
fi

echo "📥 Installing dependencies..."
npm install

echo "🏗️  Running initial build check..."
npm run build

echo "✅ Setup complete!"
echo "💡 To start development, run: npm run electron:dev"
