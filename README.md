# tmux-mru - Most Recently Used Window Switcher

🚀 **IDE-like Alt-Tab window switching for tmux with popup preview**

## Features

- **🔄 MRU Window Switching**: Switch windows in Most Recently Used order
- **🖼️ Popup Interface**: Clean popup with fzf integration (<200ms response)
- **👁️ Content Preview**: See window content before switching
- **⌨️ Keyboard Navigation**: Arrow keys, numbers 1-9, Enter/Escape
- **💾 Persistent History**: MRU order preserved across tmux restarts
- **🔧 Configurable**: Customize keybindings, popup size, history limit
- **📱 Cross-Platform**: Works on Linux, macOS with tmux 3.0+

## Demo

```
┌─ Recent Windows ──────────────────────┐  ┌─ Preview ─────────────────┐
│ 1. main:1 - nvim                      │  │ 📁 /Users/dev/project     │
│ 2. main:3 - git                       │  │ ⚡ nvim                    │
│ 3. work:2 - server                    │  │ ────────────────────────  │
│ 4. main:4 - tests                     │  │ class UserService {       │
│ 5. work:1 - logs                      │  │   async getUser(id) {     │
│                                        │  │     return await db...    │
│                                        │  │   }                       │
└────────────────────────────────────────┘  └───────────────────────────┘
```

## Installation

### Using TPM (Recommended)

Add to `~/.tmux.conf`:

```bash
set -g @plugin 'tmux-mru/tmux-mru-plugin'
```

Then press `prefix + I` to install.

### Manual Installation

```bash
git clone https://github.com/tmux-mru/tmux-mru-plugin ~/.tmux/plugins/tmux-mru
echo "run-shell ~/.tmux/plugins/tmux-mru/mru.tmux" >> ~/.tmux.conf
tmux source ~/.tmux.conf
```

## Usage

**Default keybinding**: `prefix + W`

**Navigation**:
- `Arrow keys`: Navigate through window list
- `1-9`: Jump to specific position  
- `Enter`: Switch to selected window
- `Escape`: Cancel without switching
- `Tab`: Cycle through options

## Configuration

Add these options to your `~/.tmux.conf`:

```bash
# Change keybinding (default: W)
set -g @mru-key-binding 'w'

# Popup dimensions (default: 70%x50%)  
set -g @mru-popup-width '80%'
set -g @mru-popup-height '60%'

# History settings
set -g @mru-max-history 20        # Max windows in history
set -g @mru-preview-lines 5       # Lines in preview

# Advanced options
set -g @mru-exclude-current true   # Exclude current window from list
set -g @mru-cross-session true     # Track across all sessions
```

## Requirements

- **tmux**: 3.0+ (popup requires 3.2+, fallback available)
- **fzf**: For fuzzy selection interface
- **bash**: For script execution

### Install Dependencies

**Ubuntu/Debian**:
```bash
sudo apt install tmux fzf
```

**macOS**:
```bash
brew install tmux fzf
```

**CentOS/RHEL**:
```bash
sudo yum install tmux fzf
```

## How It Works

1. **Tracking**: Plugin hooks into tmux window events to track access history
2. **Storage**: MRU data stored in `~/.tmux/plugins/tmux-mru/data/mru-history`  
3. **Display**: Uses fzf popup to show windows ordered by recency
4. **Preview**: Captures window content using `tmux capture-pane`
5. **Switching**: Updates MRU order when windows are selected

## Project Structure

```
tmux-mru-plugin/
├── mru.tmux              # Main plugin entry point
├── scripts/
│   ├── mru-switcher      # Popup interface and selection
│   ├── mru-tracker       # MRU history tracking  
│   └── mru-preview       # Content preview generation
├── data/
│   └── mru-history       # MRU data storage
└── tests/                # Test suite
    ├── unit/
    ├── integration/
    └── performance/
```

## Performance

- **Response Time**: <200ms popup display (tested with 20+ windows)
- **Memory Usage**: <1MB total footprint  
- **CPU Impact**: <1% during operation
- **Storage**: ~1KB per 20 windows in history

## Troubleshooting

### fzf not found
```bash
# Install fzf
brew install fzf  # macOS
sudo apt install fzf  # Ubuntu
```

### Popup not working
- Requires tmux 3.2+
- Plugin automatically falls back to menu on older versions
- Check: `tmux -V`

### MRU history not working
```bash
# Check if tracking is enabled
tmux show-hooks -g | grep mru

# Manually update history
~/.tmux/plugins/tmux-mru/scripts/mru-tracker update

# Check history file
cat ~/.tmux/plugins/tmux-mru/data/mru-history
```

### Permission issues
```bash
# Fix permissions
chmod +x ~/.tmux/plugins/tmux-mru/scripts/*
mkdir -p ~/.tmux/plugins/tmux-mru/data
```

## Development

### Running Tests

```bash
# Unit tests
./tests/unit/test-mru-tracker.bats

# Integration tests  
./tests/integration/test-tmux-integration.bats

# Performance tests
./tests/performance/benchmark-popup.sh
```

### Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Run tests: `make test`
4. Submit pull request

## License

MIT License - see [LICENSE](LICENSE) file.

## Credits

Inspired by IDE Alt-Tab functionality and built for developers who want familiar window switching in tmux.

**Similar Projects**:
- [tmux-fzf](https://github.com/sainnhe/tmux-fzf) - General tmux management
- [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) - Session management

**Key Differences**:
- ✅ True MRU window ordering (not alphabetical)
- ✅ Window-focused (not session-focused)  
- ✅ IDE-like muscle memory preservation
- ✅ Content preview for identification