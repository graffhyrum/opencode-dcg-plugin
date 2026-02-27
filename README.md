# OpenCode DCG Plugin

A plugin that integrates [Destructive Command Guard (dcg)](https://github.com/Dicklesworthstone/destructive_command_guard) with [OpenCode](https://opencode.ai), protecting your codebase from destructive commands.

## What It Does

This plugin intercepts bash commands before execution and validates them through dcg. Destructive commands are blocked with clear explanations and safer alternatives.

**Blocked commands include:**
- `rm -rf` on root/home paths (allows `/tmp`)
- `git reset --hard` 
- `git push --force` (suggests `--force-with-lease`)
- `git checkout --` (without `--staged`)
- `git clean -f`
- `git branch -D`
- `dd` to block devices
- And many more via dcg's modular pack system

## Prerequisites

1. **OpenCode** installed and working
2. **dcg** installed:
   ```bash
   curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/master/install.sh" | bash
   ```

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Clone this repo
git clone https://github.com/jms830/opencode-dcg-plugin.git ~/.config/opencode/opencode-dcg-plugin

# Symlink the plugin
ln -sf ~/.config/opencode/opencode-dcg-plugin/plugin/dcg-guard.js ~/.config/opencode/plugins/dcg-guard.js

# Restart OpenCode
```

### Option 2: Manual Install

```bash
# Create plugin directory if it doesn't exist
mkdir -p ~/.config/opencode/plugin

# Download the plugin directly
curl -fsSL https://raw.githubusercontent.com/jms830/opencode-dcg-plugin/main/plugin/dcg-guard.js \
  -o ~/.config/opencode/plugins/dcg-guard.js

# Restart OpenCode
```

## Verification

After restarting OpenCode, test that dcg is protecting you:

```bash
# This should be BLOCKED
rm -rf ~/test-dcg-protection

# This should be BLOCKED
git reset --hard HEAD~5

# This should be ALLOWED (safe command)
echo "dcg is working!"
```

You should see detailed block messages with explanations and safer alternatives.

## How It Works

OpenCode's plugin system supports `tool.execute.before` hooks. This plugin:

1. Intercepts all `bash` tool calls
2. Spawns dcg with the command as JSON on stdin
3. Reads dcg's exit code (0 = allow, non-zero = block)
4. Throws an error with dcg's explanation if blocked

```javascript
// Simplified flow
tool.execute.before: async (input, output) => {
  if (input.tool !== 'bash') return;
  
  const result = await callDcg({ tool: 'bash', args: { command: output.args.command }});
  
  if (result.blocked) {
    throw new Error(`dcg blocked: ${result.explanation}`);
  }
}
```

## Configuration

dcg configuration is managed through dcg itself, not this plugin. See [dcg documentation](https://github.com/Dicklesworthstone/destructive_command_guard#configuration) for:

- Enabling/disabling packs
- Custom rules
- Allowlists/blocklists

## Troubleshooting

### Plugin not loading

1. Check the plugin file exists:
   ```bash
   ls -la ~/.config/opencode/plugins/dcg-guard.js
   ```

2. Restart OpenCode completely (not just the session)

3. Check for syntax errors:
   ```bash
   node --check ~/.config/opencode/plugins/dcg-guard.js
   ```

### dcg not found

Ensure dcg is in your PATH:
```bash
which dcg
dcg --version
```

If not found, reinstall dcg:
```bash
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/master/install.sh" | bash
```

### Commands not being blocked

1. Verify dcg works standalone:
   ```bash
   echo '{"tool":"bash","args":{"command":"rm -rf /"}}' | dcg
   # Should output block message
   ```

2. Check if the command is in dcg's blocklist:
   ```bash
   dcg explain "your command here"
   ```

## Uninstall

```bash
rm ~/.config/opencode/plugins/dcg-guard.js
rm -rf ~/.config/opencode/opencode-dcg-plugin  # if cloned
```

## Related Projects

- [dcg (Destructive Command Guard)](https://github.com/Dicklesworthstone/destructive_command_guard) - The underlying protection engine
- [OpenCode](https://opencode.ai) - Open-source AI coding assistant
- [Superpowers](https://github.com/obra/superpowers) - Skills framework for coding agents

## License

MIT License - See [LICENSE](LICENSE)

## Contributing

Issues and PRs welcome! Please test changes with the verification commands above before submitting.
