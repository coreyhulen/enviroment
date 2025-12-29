# Development Environment

A streamlined script to set up and manage my macOS development environment.

## Features

This script automatically installs and configures:

### Package Manager
- **Homebrew** - The missing package manager for macOS

### Development Tools
- **Neovim** with **LazyVim** - Modern text editor with powerful IDE features
- **tmux** with plugin manager (TPM) - Terminal multiplexer with session persistence
- **Git** - Version control system with optimized config
- **Go** - Programming language
- **Node.js** - JavaScript runtime
- **Protobuf** - Protocol buffers
- **ripgrep** & **fd** - Fast search tools
- **wget** - Network downloader
- **libpng** - PNG library

### Shell Enhancements
- **Starship** - Cross-shell prompt
- **zsh-autosuggestions** - Fish-like autosuggestions for Zsh
- **zsh-syntax-highlighting** - Fish shell-like syntax highlighting
- **eza** - Modern replacement for 'ls'
- **zoxide** - Smarter cd command that learns your habits

### Applications
- **iTerm2** - Terminal emulator
- **Karabiner-Elements** - Keyboard customizer
- **Aerospace** - Window manager
- **Claude Code** - AI coding assistant
- **JetBrains Mono Nerd Font** - Developer font with icons

### Shell Configuration
- **Zsh** configuration with vim key bindings
- Custom aliases for development productivity
- Smart directory navigation with zoxide
- File listing with icons via eza
- Git shortcuts and development paths

### macOS Preferences
- Finder enhancements (show extensions, path bar, status bar)
- Dock auto-hide and process indicators
- Screenshot location set to ~/Desktop/Screenshots
- Developer-friendly Safari settings
- Disabled smart quotes for coding
- Key repeat enabled (no press-and-hold)
- F1-F12 keys set as standard function keys (no need to hold Fn)

## Installation

Run this command in your terminal:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/install.sh)"
```

The installer will:
1. Clone the environment repository to `~/.enviroment`
2. Install Homebrew (if not present)
3. Install all packages and applications
4. Configure Neovim with LazyVim
5. Set up shell with enhanced features
6. Configure tmux with plugins
7. Apply macOS preferences
8. Set up development directories

## Uninstallation

To remove all configurations and packages:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/uninstall.sh)"
```

### Uninstallation Options

- `--remove-homebrew` - Completely uninstall Homebrew (by default, only packages are removed)

## Key Features

### Tmux Configuration
- Leader key changed to `Ctrl-a`
- Intuitive splits: `|` (horizontal) and `-` (vertical)
- Vim-style pane navigation and resizing
- Session persistence with resurrect and continuum
- True color support
- Seamless navigation with Neovim

### Shell Aliases
- `ls`, `ll`, `la`, `lt` - Enhanced file listing with icons
- `cd` - Smart navigation that learns your habits
- `gs`, `ga`, `gc`, `gp`, `gl`, `gd` - Git shortcuts
- `vi`, `vim` - Opens Neovim
- `cdmm`, `cdch` - Quick navigation to development directories

### AeroSpace Window Manager
- **Workspace Switching**: F1-F9 keys
- **Move Window to Workspace**: Ctrl+F1-F9 (except Ctrl+F5)
- **Window Navigation**: Alt+H/J/K/L (left/down/up/right)
- **Window Movement**: Alt+Shift+H/J/K/L
- **Window Resizing**: Alt+Minus/Equal (-50/+50 pixels)
- **Layout Control**: Alt+Shift+Semicolon for service mode
- **Workspace Auto-Assignment**:
  - Workspace 1: Outlook, Mattermost
  - Workspace 2: Chrome
  - Workspace 3: OneNote, Obsidian
  - Workspace 4: VS Code, iTerm2
  - Workspace 6: Zoom, Teams

## Customization

- Environment files are stored in `~/.enviroment`
- Add personal zsh customizations to `~/.zshrc.local`
- Karabiner configuration at `~/.config/karabiner/`
- Neovim/LazyVim configuration at `~/.config/nvim/`
- Tmux configuration at `~/.tmux.conf`

## Manual Steps

After installation, you need to:

1. **Configure Mission Control**
   - System Preferences > Mission Control
   - Map 'Mission Control' to 'Mouse Button 4'
   - Map 'Show Desktop' to 'Mouse Button 5'

2. **Set Caps Lock as Control**
   - System Preferences > Keyboard > Modifier Keys
   - Change Caps Lock to Control

3. **Complete Neovim Setup**
   - Run `nvim` to start Neovim
   - LazyVim will automatically install plugins

4. **Install Tmux Plugins**
   - Start tmux
   - Press `Ctrl-a + I` to install plugins

## License

This is a personal configuration repository. Feel free to fork and customize for your own use.