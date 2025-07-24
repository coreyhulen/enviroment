
#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/uninstall.sh)"

# Default settings
ENVIRO=${ENVIRO:-~/.enviroment}
REPO=${REPO:-coreyhulen/enviroment}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

# Uninstallation tracking
REMOVED_ITEMS=""
FAILED_ITEMS=""
REMOVE_HOMEBREW=false

# Package lists (should match install.sh)
BREW_PACKAGES="wget go node libpng tmux protobuf neovim ripgrep fd starship"
BREW_CASKS="iterm2 nikitabobko/tap/aerospace claude-code font-jetbrains-mono-nerd-font"

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

track_removal() {
    local item="$1"
    local status="$2"
    
    if [ "$status" = "success" ]; then
        REMOVED_ITEMS="${REMOVED_ITEMS}\n  ✓ $item"
    else
        FAILED_ITEMS="${FAILED_ITEMS}\n  ✗ $item"
    fi
}

check_system() {
    info "Checking system..."
    
    # Check if running on macOS
    if [ "$(uname)" != "Darwin" ]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check if environment directory exists
    if [ ! -d "$ENVIRO" ]; then
        warn "Environment directory $ENVIRO not found"
    fi
    
    info "System check passed"
}

info() {
	echo ${BLUE}"$@"${RESET} >&2
}

warn() {
	echo ${YELLOW}"Warning: $@"${RESET} >&2
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

underline() {
	echo "$(printf '\033[4m')$@$(printf '\033[24m')"
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[36m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

remove_homebrew() {
    if ! command_exists brew; then
        warn "Homebrew is not installed, skipping package removal"
        track_removal "Homebrew packages" "failed"
        return
    fi
    
    info "Uninstalling Homebrew packages..."
    
    # Uninstall command line tools
    for package in $BREW_PACKAGES; do
        if brew list --formula | grep -q "^${package}\$" 2>/dev/null; then
            if brew uninstall $package 2>/dev/null; then
                track_removal "$package" "success"
            else
                warn "Failed to uninstall $package"
                track_removal "$package" "failed"
            fi
        else
            track_removal "$package (not installed)" "success"
        fi
    done
    
    # Uninstall GUI applications
    for cask in $BREW_CASKS; do
        if brew list --cask | grep -q "^${cask}\$" 2>/dev/null; then
            if brew uninstall --cask $cask 2>/dev/null; then
                track_removal "$cask (cask)" "success"
            else
                warn "Failed to uninstall $cask"
                track_removal "$cask (cask)" "failed"
            fi
        else
            track_removal "$cask (cask, not installed)" "success"
        fi
    done
    
    # Also check for karabiner-elements, flutter which might have been installed
    for extra_cask in "karabiner-elements" "flutter" "rectangle" "lastpass" "claude-code"; do
        if brew list --cask | grep -q "^${extra_cask}\$" 2>/dev/null; then
            info "Found additional cask: $extra_cask"
            if brew uninstall --cask $extra_cask 2>/dev/null; then
                track_removal "$extra_cask (cask)" "success"
            else
                warn "Failed to uninstall $extra_cask"
                track_removal "$extra_cask (cask)" "failed"
            fi
        fi
    done
    
    info "Finished uninstalling Homebrew packages"
    
    # Handle complete Homebrew removal based on flag or interactive prompt
    if [ "$REMOVE_HOMEBREW" = true ]; then
        uninstall_homebrew_completely
    elif [ -t 0 ]; then
        printf "Do you want to completely uninstall Homebrew? [y/N]: "
        read answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            uninstall_homebrew_completely
        fi
    fi
}

uninstall_homebrew_completely() {
    info "Completely uninstalling Homebrew..."
    
    # Detect processor architecture to find correct Homebrew location
    if [ "$(uname -m)" = "arm64" ]; then
        # Apple Silicon Mac
        BREW_PREFIX="/opt/homebrew"
    else
        # Intel Mac
        BREW_PREFIX="/usr/local"
    fi
    
    # Use official Homebrew uninstall script
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"; then
        track_removal "Homebrew (complete)" "success"
    else
        error "Failed to run Homebrew uninstall script"
        warn "You may need to manually remove Homebrew directories"
        track_removal "Homebrew (complete)" "failed"
    fi
    
    # Clean up any remaining directories
    sudo rm -rf $BREW_PREFIX/Homebrew 2>/dev/null
    sudo rm -rf $BREW_PREFIX/Caskroom 2>/dev/null
    sudo rm -rf $BREW_PREFIX/bin/brew 2>/dev/null
    
    info "Homebrew uninstallation completed"
}

remove_vim() {
    info "Uninstalling Neovim LazyVim configuration"
    
    local removed=false
    
    # Remove Neovim configuration directories
    if [ -d ~/.config/nvim ]; then
        # Backup before removal
        cp -r ~/.config/nvim ~/.config/nvim.uninstall.backup.$(date +%Y%m%d_%H%M%S)
        rm -rf ~/.config/nvim
        removed=true
    fi
    
    if [ -d ~/.local/share/nvim ]; then
        rm -rf ~/.local/share/nvim
        removed=true
    fi
    
    if [ -d ~/.local/state/nvim ]; then
        rm -rf ~/.local/state/nvim
        removed=true
    fi
    
    if [ -d ~/.cache/nvim ]; then
        rm -rf ~/.cache/nvim
        removed=true
    fi
    
    # Also remove old vim configuration if it exists
    if [ -d ~/.vim ] || [ -f ~/.vimrc ]; then
        rm -rf ~/.vim
        rm -f ~/.vimrc
        removed=true
    fi
    
    if [ "$removed" = true ]; then
        track_removal "Neovim/LazyVim configuration" "success"
        info "Backed up nvim config before removal"
    else
        track_removal "Neovim/LazyVim configuration (not found)" "success"
    fi
    
    info "Finished uninstalling Neovim configuration"
}

remove_shell() {
    info "Removing shell configuration"
    
    if [ -f ~/.zshrc ]; then
        # Backup existing .zshrc just in case
        cp ~/.zshrc ~/.zshrc.uninstall.backup.$(date +%Y%m%d_%H%M%S)
        rm -f ~/.zshrc
        track_removal "zsh configuration" "success"
        info "Backed up .zshrc before removal"
    else
        track_removal "zsh configuration (not found)" "success"
    fi
}

remove_tmux() {
    info "Uninstalling tmux extensions"
    
    if [ -f ~/.tmux.conf ]; then
        rm -f ~/.tmux.conf
        track_removal "tmux configuration" "success"
    else
        track_removal "tmux configuration (not found)" "success"
    fi
}

remove_aerospace() {
    info "Uninstalling Aerospace configuration"
    
    if [ -f ~/.aerospace.toml ]; then
        rm -f ~/.aerospace.toml
        track_removal "Aerospace configuration" "success"
    else
        track_removal "Aerospace configuration (not found)" "success"
    fi
}

remove_karabiner() {
    info "Uninstalling karabiner extensions"
    
    if [ -f ~/.config/karabiner/karabiner.json ]; then
        rm -f ~/.config/karabiner/karabiner.json
        track_removal "karabiner configuration" "success"
    else
        track_removal "karabiner configuration (not found)" "success"
    fi
}

remove_enviroment() {
    info "Uninstalling environment repository"
    
    if [ -d "$ENVIRO" ]; then
        rm -rf "${ENVIRO}"
        track_removal "environment repository" "success"
    else
        track_removal "environment repository (not found)" "success"
    fi
}

remove_preferences() {
    info "Reverting macOS preferences to defaults..."
    
    # Note: We're being selective about what to revert
    # Some preferences might be user's actual preferences
    
    # Revert screenshot location to default
    defaults delete com.apple.screencapture location 2>/dev/null
    
    # Remove git configurations that were specific to this setup
    git config --global --unset url."git@github.com:".insteadOf 2>/dev/null
    
    track_removal "macOS preferences (partial revert)" "success"
    info "Some preferences were left as-is to avoid disrupting your workflow"
}

remove_manual_steps() {
    echo ""
    warn "MANUAL STEPS NEEDED:"
    warn "1. Some macOS preferences were not reverted to avoid disruption"
    warn "2. Git user.name and user.email were preserved"
}

main() {
    # Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		RUNZSH=no
		CHSH=no
	fi

	# Parse arguments
	while [ $# -gt 0 ]; do
		case $1 in
			--unattended) RUNZSH=no; CHSH=no ;;
			--skip-chsh) CHSH=no ;;
			--keep-zshrc) KEEP_ZSHRC=yes ;;
			--remove-homebrew) REMOVE_HOMEBREW=true ;;
			--help)
				echo "Usage: $0 [options]"
				echo "Options:"
				echo "  --unattended       Run without prompts"
				echo "  --remove-homebrew  Completely uninstall Homebrew without prompting"
				echo "  --help             Show this help message"
				exit 0
				;;
		esac
		shift
	done

	setup_color
    
    info "Uninstalling your Mac environment"
    echo ""
    
    # Check system first
    check_system
    echo ""
    
    # Confirmation prompt
    if [ -t 0 ]; then
        echo "${YELLOW}This will remove all configurations and packages installed by the environment setup.${RESET}"
        printf "Are you sure you want to continue? [y/N]: "
        read confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Uninstallation cancelled."
            exit 0
        fi
        echo ""
    fi
    
    # Progress tracking
    TOTAL_STEPS=8
    CURRENT_STEP=0
    
    # Run removal steps
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing Homebrew packages..."
    remove_homebrew
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing Neovim/LazyVim configuration..."
    remove_vim
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing shell configuration..."
    remove_shell
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing karabiner configuration..."
    remove_karabiner
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing tmux configuration..."
    remove_tmux
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing Aerospace configuration..."
    remove_aerospace
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Reverting preferences..."
    remove_preferences
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Removing environment directory..."
    remove_enviroment
    
    # Show removal summary
    echo ""
    echo "${BOLD}Removal Summary:${RESET}"
    
    if [ -n "$REMOVED_ITEMS" ]; then
        echo "${GREEN}Successfully removed:${RESET}"
        echo "$REMOVED_ITEMS"
    fi
    
    if [ -n "$FAILED_ITEMS" ]; then
        echo ""
        echo "${RED}Failed to remove:${RESET}"
        echo "$FAILED_ITEMS"
    fi
    
    # Show manual steps if needed
    remove_manual_steps

    echo ""
    echo "${GREEN}Uninstall complete!${RESET}"
    echo "${YELLOW}Note: Your .zshrc was backed up with a timestamp${RESET}"
}

main "$@"








