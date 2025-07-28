
#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/install.sh)"

# Default settings
ENVIRO=${ENVIRO:-~/.enviroment}
REPO=${REPO:-coreyhulen/enviroment}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

# Installation tracking
INSTALLED_ITEMS=""
FAILED_ITEMS=""

# Package lists
BREW_PACKAGES="wget go node libpng tmux protobuf neovim ripgrep fd starship zsh-autosuggestions zsh-syntax-highlighting eza zoxide"
BREW_CASKS="iterm2 nikitabobko/tap/aerospace claude-code font-jetbrains-mono-nerd-font karabiner-elements"

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

track_installation() {
    local item="$1"
    local status="$2"
    
    if [ "$status" = "success" ]; then
        INSTALLED_ITEMS="${INSTALLED_ITEMS}\n  ✓ $item"
    else
        FAILED_ITEMS="${FAILED_ITEMS}\n  ✗ $item"
    fi
}

check_system_requirements() {
    info "Checking system requirements..."
    
    # Check if running on macOS
    if [ "$(uname)" != "Darwin" ]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check macOS version
    OS_VERSION=$(sw_vers -productVersion)
    info "Detected macOS version: $OS_VERSION"
    
    # Check for required commands
    if ! command_exists curl; then
        error "curl is required but not installed"
        exit 1
    fi
    
    # Check disk space (require at least 5GB free)
    FREE_SPACE=$(df -g / | awk 'NR==2 {print $4}')
    if [ "$FREE_SPACE" -lt 5 ]; then
        warn "Low disk space: ${FREE_SPACE}GB free (recommend at least 5GB)"
    fi
    
    info "System requirements check passed"
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

setup_getgitrepo() {
    command_exists git || {
		error "Git is not installed"
		exit 1
	}

    if [ -d $ENVIRO ]; then
        warn "$ENVIRO directory already exists. Skipping download."
        track_installation "Environment repository" "success"
    else
	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$ENVIRO" || {
		error "git clone of enviroment repo failed"
		track_installation "Environment repository" "failed"
		exit 1
	}
	track_installation "Environment repository" "success"
    fi
}

setup_homebrew() {
    if ! command_exists brew; then
		warn "Homebrew is not installed. Attempting to install"
        
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            error "Failed to install Homebrew"
            exit 1
        }
        
        # Detect processor architecture and add Homebrew to PATH
        if [ "$(uname -m)" = "arm64" ]; then
            # Apple Silicon Mac
            BREW_PREFIX="/opt/homebrew"
        else
            # Intel Mac
            BREW_PREFIX="/usr/local"
        fi
        
        # Add Homebrew to current session PATH
        eval "$($BREW_PREFIX/bin/brew shellenv)"
        
        # Verify Homebrew installation
        if ! command_exists brew; then
            error "Homebrew installation failed - brew command not found"
            exit 1
        fi
        
        info "Homebrew installed successfully"
    else
        info "Detected Homebrew as installed"
	fi 

    info "Installing Homebrew modules..."
    
    brew update --quiet || warn "Failed to update Homebrew"
    brew upgrade --quiet || warn "Failed to upgrade Homebrew packages"
    
    # Add required tap for aerospace
    brew tap nikitabobko/tap || warn "Failed to add nikitabobko/tap"
    
    # Install command line tools
    for package in $BREW_PACKAGES; do
        if brew install --quiet $package; then
            track_installation "$package" "success"
        else
            warn "Failed to install $package"
            track_installation "$package" "failed"
        fi
    done
    
    # Install GUI applications
    for cask in $BREW_CASKS; do
        if brew install --cask --quiet $cask; then
            track_installation "$cask (cask)" "success"
        else
            warn "Failed to install $cask"
            track_installation "$cask (cask)" "failed"
        fi
    done

    info "Finished installing Homebrew modules"
}

setup_karabiner() {
    info "Installing Karabiner configuration"
    
    # Check if Karabiner-Elements is installed
    if [ ! -d /Applications/Karabiner-Elements.app ]; then
        warn "Karabiner-Elements is not installed. Configuration will be copied but may not be used until Karabiner-Elements is installed."
    fi

    info "Installing Karabiner extensions"
    mkdir -p ~/.config/karabiner/
    cp -f $ENVIRO/keyboard/karabiner.json ~/.config/karabiner/ && \
        track_installation "Karabiner configuration" "success" || \
        track_installation "Karabiner configuration" "failed"
}

setup_preferences() {
    info "Configuring macOS preferences..."
    
    info "Expand save and print panel by default"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    info "Save to disk (not to iCloud) by default"
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    info "Avoid creating .DS_Store files on network volumes"
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    info "Disable smart quotes and dashes as they cause problems when typing code"
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    info "Disable press-and-hold for keys in favor of key repeat"
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    info "Adjust Finder settings"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlmv"
    defaults write com.apple.finder NewWindowTarget -string "PfLo" && \
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

    info "Adjust Dock settings"
    defaults write com.apple.dock show-process-indicators -bool true
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock mru-spaces -bool false

    info "Show status bar and path bar"
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true

    info "Disable the warning when changing a file extension"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    info "Show the ~/Library folder"
    chflags nohidden ~/Library

    info "Set where screenshots go"
    defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"

    info "Safari enable Safari Developer Settings (Safari must be closed)"
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true 2>/dev/null || warn "Could not set Safari debug menu"
    defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null || warn "Could not set Safari develop menu"
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true 2>/dev/null || warn "Could not set Safari WebKit developer extras"
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true 2>/dev/null || warn "Could not set Safari WebKit2 developer extras"
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true 2>/dev/null || warn "Could not set global WebKit developer extras"

    info "Chrome disable the all too sensitive backswipe on Trackpads and Magic Mice"
    defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

    info "Chrome use the system print dialog and expand dialog by default"
    defaults write com.google.Chrome DisablePrintPreview -bool true
    defaults write com.google.Chrome.canary DisablePrintPreview -bool true
    defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
    defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

    info "Menu item settings"
    defaults write com.apple.menuextra.battery ShowPercent -string "YES"
    defaults write com.apple.menuextra.battery ShowTime -string "NO"

    info "Git settings"
    git config --global url."git@github.com:".insteadOf https://github.com/
    git config --global --replace-all credential.helper osxkeychain
    git config --global user.email "corey@hulen.com"
    git config --global user.name "coreyhulen"
    
    track_installation "macOS preferences" "success"
}

setup_vim() {
    info "Installing LazyVim for Neovim"
    
    # Check if neovim is installed
    if ! command_exists nvim; then
        error "Neovim is not installed. Please ensure Homebrew packages were installed successfully."
        track_installation "LazyVim" "failed"
        return 1
    fi
    
    # Backup existing Neovim configuration
    if [ -d ~/.config/nvim ]; then
        info "Backing up existing Neovim configuration"
        mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    if [ -d ~/.local/share/nvim ]; then
        mv ~/.local/share/nvim ~/.local/share/nvim.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    if [ -d ~/.local/state/nvim ]; then
        mv ~/.local/state/nvim ~/.local/state/nvim.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    if [ -d ~/.cache/nvim ]; then
        mv ~/.cache/nvim ~/.cache/nvim.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Clone LazyVim starter configuration
    git clone https://github.com/LazyVim/starter ~/.config/nvim && \
        rm -rf ~/.config/nvim/.git && \
        track_installation "LazyVim" "success" || \
        track_installation "LazyVim" "failed"
    
    info "LazyVim installation complete. Run 'nvim' to start Neovim and complete setup."
}

setup_shell() {
    info "Installing shell configuration"
    
    # Install zsh configuration
    if [ -f ~/.zshrc ]; then
        info "Backing up existing .zshrc"
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    cp -f $ENVIRO/shell/zshrc.zsh-template ~/.zshrc && \
        track_installation "zsh configuration" "success" || \
        track_installation "zsh configuration" "failed"
}

setup_tmux() {
    info "Installing tmux extensions"
    
    cp -f $ENVIRO/shell/tmux.conf-template ~/.tmux.conf && \
        track_installation "tmux configuration" "success" || \
        track_installation "tmux configuration" "failed"
    
    # Install tmux plugin manager (TPM)
    if [ ! -d ~/.tmux/plugins/tpm ]; then
        info "Installing tmux plugin manager"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
            track_installation "tmux plugin manager" "success" || \
            track_installation "tmux plugin manager" "failed"
    else
        info "Tmux plugin manager already installed"
        track_installation "tmux plugin manager (existing)" "success"
    fi
    
    info "To install tmux plugins, start tmux and press 'prefix + I' (Ctrl-a + I)"
}

setup_aerospace() {
    info "Installing Aerospace configuration"
    
    # Check if Aerospace is installed
    if [ ! -d "/Applications/AeroSpace.app" ] && ! command_exists aerospace; then
        warn "AeroSpace is not installed. Configuration will be copied but may not be used until AeroSpace is installed."
    fi
    
    # Copy configuration file
    cp -f $ENVIRO/shell/aerospace.toml ~/.aerospace.toml && \
        track_installation "Aerospace configuration" "success" || \
        track_installation "Aerospace configuration" "failed"
    
    info "Aerospace configuration installed to ~/.aerospace.toml"
}

setup_iterm2() {
    info "Installing iTerm2 configuration"
    
    # Check if iTerm2 is installed
    if [ ! -d "/Applications/iTerm.app" ]; then
        warn "iTerm2 is not installed. Configuration will be copied but may not be used until iTerm2 is installed."
    fi
    
    # Backup existing iTerm2 preferences if they exist
    if [ -f ~/Library/Preferences/com.googlecode.iterm2.plist ]; then
        info "Backing up existing iTerm2 preferences"
        cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Copy iTerm2 preferences
    if [ -f $ENVIRO/shell/iterm2-settings.plist ]; then
        cp -f $ENVIRO/shell/iterm2-settings.plist ~/Library/Preferences/com.googlecode.iterm2.plist && \
            track_installation "iTerm2 configuration" "success" || \
            track_installation "iTerm2 configuration" "failed"
        
        # Clear the preferences cache
        defaults read com.googlecode.iterm2 >/dev/null 2>&1
        info "iTerm2 configuration installed. You may need to restart iTerm2 for changes to take effect."
    else
        warn "iTerm2 settings file not found in repository"
        track_installation "iTerm2 configuration" "failed"
    fi
}

setup_dev_paths() {
    info "Installing various paths and files extensions"
    
    export GOPATH=$HOME/Projects
    mkdir -p $GOPATH $GOPATH/src/github.com/coreyhulen $GOPATH/src/github.com/mattermost $GOPATH/pkg $GOPATH/bin && \
        track_installation "development directories" "success" || \
        track_installation "development directories" "failed"
}

setup_manual_steps() {
    echo ""
    warn "MANUAL STEPS NEEDED:"
    warn "1. For Mission Control on Mac"
    warn "   Goto System Preferences > Mission Control"
    warn "   map 'Mission Control:' to 'Mouse Button 4'"
    warn "   map 'Show Desktop:' to 'Mouse Button 5'"
    echo ""
    warn "2. Setup caps lock as control key"
    warn "   Goto System Preferences > Keyboard > Modifier Keys"
    warn "   Change Caps Lock > Control"
    echo ""
}

main() {

	setup_color
    
    info "Installing your Mac environment"
    echo ""
    
    # Check system requirements first
    check_system_requirements
    echo ""
    
    # Progress tracking
    TOTAL_STEPS=10
    CURRENT_STEP=0
    
    # Run installation steps
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up environment repository..."
    setup_getgitrepo
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up Homebrew..."
    setup_homebrew
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up Neovim with LazyVim..."
    setup_vim
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up shell configuration..."
    setup_shell
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up tmux..."
    setup_tmux
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up iTerm2..."
    setup_iterm2
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up Aerospace..."
    setup_aerospace
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up development paths..."
    setup_dev_paths
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up macOS preferences..."
    setup_preferences
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "${BOLD}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} Setting up Karabiner..."
    setup_karabiner
    
    # Show installation summary
    echo ""
    echo "${BOLD}Installation Summary:${RESET}"
    
    if [ -n "$INSTALLED_ITEMS" ]; then
        echo "${GREEN}Successfully installed:${RESET}"
        echo "$INSTALLED_ITEMS"
    fi
    
    if [ -n "$FAILED_ITEMS" ]; then
        echo ""
        echo "${RED}Failed to install:${RESET}"
        echo "$FAILED_ITEMS"
    fi
    
    # Show manual steps if needed
    setup_manual_steps

    echo ""
    echo "${GREEN}Installation complete!${RESET}"
}

main "$@"
