# Development Environment

A streamlined script to set up and manage my macOS development environment.

## Features

This script automatically installs and configures:

### Package Manager
- **Homebrew** - The missing package manager for macOS

### Development Tools
- **Neovim** with **LazyVim** - Modern text editor with powerful IDE features
- **tmux** - Terminal multiplexer
- **Git** - Version control system
- **Go** - Programming language
- **Node.js** - JavaScript runtime
- **Protobuf** - Protocol buffers
- **ripgrep** & **fd** - Fast search tools

### Applications
- **iTerm2** - Terminal emulator
- **Karabiner-Elements** - Keyboard customizer
- **Aerospace** - Window manager

### Shell Configuration
- Plain **Zsh** configuration with vim key bindings
- Custom aliases and environment variables
- Development shortcuts for Go projects

### macOS Preferences
- Finder enhancements
- Dock improvements
- Screenshot location customization
- Developer-friendly defaults

## Installation

Run this command in your terminal:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/install.sh)"
```

### Installation Options

- `--unattended` - Run without prompts
- `--skip-chsh` - Skip changing default shell
- `--keep-zshrc` - Keep existing .zshrc
- `--help` - Show help message

## Uninstallation

To remove all configurations and packages:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/uninstall.sh)"
```

### Uninstallation Options

- `--unattended` - Run without prompts
- `--remove-homebrew` - Completely uninstall Homebrew without prompting
- `--help` - Show help message

## Customization

- Environment files are stored in `~/.enviroment`
- Add personal zsh customizations to `~/.zshrc.local`
- Karabiner configuration can be modified at `~/.config/karabiner/`
- Neovim/LazyVim configuration is at `~/.config/nvim/`

## Manual Steps

After installation, you may want to:

1. Configure Mission Control mouse buttons in System Preferences
2. Set Caps Lock as Control key in Keyboard preferences
3. Launch Neovim (`nvim`) to complete LazyVim setup

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection
- At least 5GB free disk space
- Git (for initial clone)

## What Gets Backed Up

The scripts automatically create timestamped backups of:
- `.zshrc` (during install and uninstall)
- Neovim configuration (during install)

## License

This is a personal configuration repository. Feel free to fork and customize for your own use.