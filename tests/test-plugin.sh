#!/bin/bash
set -euo pipefail

echo "=== OpenCode DCG Plugin Tests ==="
echo ""

if ! command -v dcg &> /dev/null; then
    echo "FAIL: dcg not found in PATH"
    exit 1
fi
echo "PASS: dcg found at $(which dcg)"

echo ""
echo "Testing dcg JSON interface..."

SAFE_CMD='{"tool":"bash","args":{"command":"echo hello"}}'
DANGEROUS_CMD='{"tool":"bash","args":{"command":"rm -rf /"}}'

echo "$SAFE_CMD" | dcg > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "PASS: Safe command allowed"
else
    echo "FAIL: Safe command was blocked"
    exit 1
fi

echo "$DANGEROUS_CMD" | dcg > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "PASS: Dangerous command blocked"
else
    echo "FAIL: Dangerous command was allowed!"
    exit 1
fi

echo ""
echo "Testing plugin file..."

PLUGIN_FILE="${HOME}/.config/opencode/plugins/dcg-guard.js"
if [ -f "$PLUGIN_FILE" ]; then
    echo "PASS: Plugin file exists"
    node --check "$PLUGIN_FILE" 2>/dev/null && echo "PASS: Plugin syntax valid" || echo "FAIL: Plugin syntax error"
else
    echo "WARN: Plugin not installed at $PLUGIN_FILE"
fi

echo ""
echo "=== All tests passed ==="
