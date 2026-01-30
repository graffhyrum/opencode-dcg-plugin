#!/bin/bash
set -euo pipefail

echo "Installing OpenCode DCG Plugin..."

PLUGIN_DIR="${HOME}/.config/opencode/plugin"
PLUGIN_URL="https://raw.githubusercontent.com/jms830/opencode-dcg-plugin/main/plugin/dcg-guard.js"

if ! command -v dcg &> /dev/null; then
    echo "Error: dcg is not installed."
    echo ""
    echo "Install dcg first:"
    echo '  curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/master/install.sh" | bash'
    exit 1
fi

mkdir -p "$PLUGIN_DIR"

echo "Downloading plugin..."
curl -fsSL "$PLUGIN_URL" -o "${PLUGIN_DIR}/dcg-guard.js"

echo ""
echo "Installation complete!"
echo ""
echo "Restart OpenCode to activate dcg protection."
echo ""
echo "Test with: rm -rf ~/test-dcg (should be blocked)"
