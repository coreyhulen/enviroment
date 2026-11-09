# Development Environment

A streamlined script to set up and manage my macOS development environment.

## Features

This script automatically installs and configures:

### Package Manager
- **Homebrew** - The missing package manager for macOS
- **Xcode Command Line Tools** - Installed first if missing

### Development Tools
- **Neovim** with **LazyVim** - Modern text editor with powerful IDE features
- **tmux** with plugin manager (TPM) - Terminal multiplexer with session persistence
- **Git** - Version control with keychain credential helper
- **Go** - Programming language
- **Node.js** - JavaScript runtime
- **Protobuf** - Protocol buffers
- **ripgrep** & **fd** - Fast search tools
- **wget** - Network downloader
- **gh** - GitHub CLI
- **ImageMagick** - Image processing
- **AWS CLI** - Amazon Web Services CLI
- **uv** - Python package and tool runner (used by MCP servers)

### Shell Enhancements
- **Starship** - Cross-shell prompt
- **zsh-autosuggestions** - Fish-like autosuggestions for Zsh
- **zsh-syntax-highlighting** - Fish shell-like syntax highlighting
- **eza** - Modern replacement for 'ls'
- **zoxide** - Smarter cd command that learns your habits

### Applications
- **iTerm2** - Terminal emulator (with bundled settings)
- **Karabiner-Elements** - Keyboard customizer
- **AeroSpace** - Tiling window manager
- **Claude Code** - AI coding assistant (official native installer)
- **OpenAI Codex CLI** - AI coding agent (official standalone installer)
- **JetBrains Mono Nerd Font** - Developer font with icons
- **Visual Studio Code**, **Obsidian**, **Docker Desktop**
- **GIMP**, **Inkscape**, **Blender**, **Arduino IDE**, **ExpressVPN**

### Claude Code MCP Servers
Registered at user scope with `claude mcp add`:
- `seq-server` - Sequential thinking
- `codex-native` - OpenAI Codex (`codex mcp-server`)
- `fetch-server` - Web fetching (`uvx mcp-server-fetch`)
- `filesystem-server` - Filesystem access scoped to `$HOME`
- `chrome-devtools` - Chrome DevTools automation
- `memory` - Persistent knowledge-graph memory

### Shell Configuration
- **Zsh** configuration with vim key bindings
- Custom aliases for development productivity
- Smart directory navigation with zoxide
- File listing with icons via eza
- Git and tmux shortcuts, development paths
- `GOPATH` set to `~/Projects`

### macOS Preferences
- Finder enhancements (show extensions, path bar, status bar, list view)
- Expanded save and print panels; save to disk rather than iCloud
- No `.DS_Store` files on network or USB volumes
- Dock auto-hide, process indicators, and fixed Space ordering
- `~/Library` made visible
- Screenshot location set to ~/Desktop/Screenshots
- Battery percentage shown in the menu bar
- Developer-friendly Safari settings
- Chrome swipe-to-navigate disabled and system print dialog enabled
- Disabled smart quotes and dashes for coding
- Fast key repeat (no press-and-hold)
- F1-F12 keys set as standard function keys (no need to hold Fn)

## Installation

Run this command in your terminal:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/install.sh)"
```

Some casks (Karabiner-Elements, Docker Desktop, ExpressVPN) install system components, so Homebrew will ask for your administrator password while installing them. Homebrew clears cached sudo credentials on every run, so expect more than one prompt. If ExpressVPN is already installed outside Homebrew, it is left alone.

The installer will:
1. Install Xcode Command Line Tools (if not present)
2. Clone the environment repository to `~/.enviroment`
3. Install Homebrew (if not present) and all packages and applications
4. Install Claude Code
5. Install Codex CLI
6. Configure Neovim with LazyVim
7. Set up the zsh configuration (backing up any existing `~/.zshrc`)
8. Configure tmux and install TPM
9. Install iTerm2 settings (backing up existing preferences)
10. Install the AeroSpace configuration
11. Register Claude Code MCP servers
12. Create development directories under `~/Projects`
13. Apply macOS preferences and git settings
14. Install the Karabiner configuration

The installer can be re-run safely; existing items are skipped or backed up, and MCP servers are re-registered. A summary of successful and failed steps is printed at the end.

## Uninstallation

To remove all configurations and packages:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/uninstall.sh)"
```

The uninstaller asks for confirmation (Homebrew may also ask for your administrator password when removing casks with system components), backs up `~/.zshrc` and `~/.config/nvim` before removing them, and leaves iTerm2 preferences, git identity, and most macOS preferences in place.

### Uninstallation Options

- `--remove-homebrew` - Completely uninstall Homebrew (by default, only packages are removed; interactive runs will also prompt)

## Key Features

### Tmux Configuration
- Leader key changed to `Ctrl-a`
- Intuitive splits: `|` (horizontal) and `-` (vertical)
- Vim-style pane navigation (`h/j/k/l`) and resizing (`H/J/K/L`)
- Vi copy mode that copies to the macOS clipboard
- Session persistence with resurrect and continuum
- Catppuccin theme and true color support
- Seamless navigation with Neovim (vim-tmux-navigator)
- `Ctrl-a R` reloads the config

### Shell Aliases
- `ls`, `l`, `ll`, `la`, `lt` - Enhanced file listing with icons
- `cd` - Smart navigation that learns your habits (zoxide)
- `gs`, `ga`, `gc`, `gp`, `gl`, `gd` - Git shortcuts
- `tm <name>`, `tls`, `ta <name>`, `tks <name>` - Start, list, attach to, and kill tmux sessions
- `vi`, `vim` - Opens Neovim
- `cdmm`, `cdch` - Quick navigation to development directories

### AeroSpace Window Manager
- **Workspace Switching**: F1-F11
- **Move Window to Workspace**: Ctrl+F1-F11 (except Ctrl+F5)
- **Toggle Floating/Tiling**: F12
- **Window Navigation**: Alt+H/J/K/L (left/down/up/right)
- **Window Movement**: Alt+Shift+H/J/K/L
- **Window Resizing**: Alt+Minus/Equal (-50/+50 pixels)
- **Layouts**: Alt+Slash (tiles), Alt+Comma (accordion)
- **Previous Workspace**: Alt+Tab
- **Move Workspace to Next Monitor**: Alt+Shift+Tab
- **Service Mode**: Alt+Shift+Semicolon (Esc reloads config, R resets layout)
- **Workspace Auto-Assignment**:
  - Workspace 1: Chrome
  - Workspace 2: Parallels Desktop
  - Workspace 3: Mattermost
  - Workspace 4: Obsidian
  - Workspace 6: iTerm2, VS Code
  - Workspace 8: Zoom, Teams, Blender (floating), Adobe Acrobat
  - Workspace 10: Windows App, Claude Desktop, Grok Bot
  - Always floating: Finder, 1Password

## Repository Layout

```
install.sh                    Installer
uninstall.sh                  Uninstaller
keyboard/karabiner.json       Copied to ~/.config/karabiner/
shell/aerospace.toml          Copied to ~/.aerospace.toml
shell/iterm2-settings.plist   Imported into iTerm2 preferences (defaults import)
shell/tmux.conf-template      Copied to ~/.tmux.conf
shell/zshrc.zsh-template      Copied to ~/.zshrc
```

Config files are copied, not symlinked, so changes in the repo take effect only after re-running the installer or copying the file manually.

## Customization

- Environment files are stored in `~/.enviroment`
- Add personal zsh customizations to `~/.zshrc.local`
- Karabiner configuration at `~/.config/karabiner/`
- Neovim/LazyVim configuration at `~/.config/nvim/`
- Tmux configuration at `~/.tmux.conf`
- AeroSpace configuration at `~/.aerospace.toml`

## Manual Steps

After installation, you need to:

1. **Configure Mission Control**
   - System Settings > Desktop & Dock > Shortcuts...
   - Map 'Mission Control' to 'Mouse Button 4'
   - Map 'Show Desktop' to 'Mouse Button 5'

2. **Set Caps Lock as Control**
   - System Settings > Keyboard > Keyboard Shortcuts... > Modifier Keys
   - Change Caps Lock to Control

3. **Complete Neovim Setup**
   - Run `nvim` to start Neovim
   - LazyVim will automatically install plugins

4. **Install Tmux Plugins**
   - Start tmux
   - Press `Ctrl-a + I` to install plugins

## License

This is a personal configuration repository. Feel free to fork and customize for your own use.
