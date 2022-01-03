
#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/install.sh)"

# Default settings
ENVIRO=${ENVIRO:-~/.enviroment}
REPO=${REPO:-coreyhulen/enviroment}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

command_exists() {
	command -v "$@" >/dev/null 2>&1
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
		BLUE=$(printf '\033[34m')
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
    else
	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$ENVIRO" || {
		error "git clone of enviroment repo failed"
		exit 1
	}
    fi
}

setup_homebrew() {
    if ! command_exists brew; then
		warn "Homebrew is not installed. Attempting to install"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    else
        info "Detected Homebrew as installed"
	fi 

    info "Installing Homebrew modules..."
    brew update
    brew upgrade
    brew install wget
    brew install go
    brew install node
    brew install libpng
    brew install tmux
    brew install openssl@1.1
    brew install protobuf
    brew install --cask visual-studio-code
    brew install --cask zoom
    brew install --cask firefox
    brew install --cask lastpass
    brew install --cask steam
    brew install --cask docker
    brew install --cask figma
    brew install --cask rectangle
    brew install --cask alacritty
    brew install --cask gimp
    brew install --cask flutter
    brew install --cask karabiner-elements
    brew install --cask mattermost

    info "Finished installing Homebrew modules"
}

setup_karabiner() {
    if [ ! -d /Applications/Karabiner-Elements.app ]; then
        error "Failed to find Karabiner for Mac. Please install from https://karabiner-elements.pqrs.org/"        
        exit 1
    else
        info "Detected Karabiner as installed"
    fi

    info "Installing Karabiner extensions"
    mkdir -p ~/.config/karabiner/
    cp -f $ENVIRO/keyboard/karabiner.json ~/.config/karabiner/
}

setup_preferences() {
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

    info "Safari enable Safari Developer Settings"
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

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
    git config --global credential.helper osxkeychain
    git config --global user.email "corey@hulen.com"
    git config --global user.name "coreyhulen"
}

setup_alacritty() {
    if [ ! -d /Applications/Alacritty.app ]; then
        error "Failed to find Alacritty for Mac. Please install from https://github.com/alacritty/alacritty/releases"        
        exit 1
    else
        info "Detected Alacritty as installed"
    fi

    info "Installing alacritty extensions"
    mkdir -p ~/.config/alacritty
    cp -f $ENVIRO/shell/alacritty.yml ~/.config/alacritty/alacritty.yml
}

setup_vim() {
    info "Installing vim extensions"
    if [ ! -d $ENVIRO/vim/bundle ]; then
        git clone https://github.com/ctrlpvim/ctrlp.vim.git $ENVIRO/vim/bundle/ctrlp.vim
    fi

    mkdir -p ~/.vim
    cp -Rf $ENVIRO/vim/autoload ~/.vim/
    cp -Rf $ENVIRO/vim/colors ~/.vim/
    cp -Rf $ENVIRO/vim/bundle ~/.vim/
    cp -f $ENVIRO/vim/vimrc.vim-template ~/.vimrc    
}

setup_oh_my_zsh() {
    info "Installing oh-my-zsh extensions"
    if [ ! -d ~/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    cp -f $ENVIRO/shell/zshrc.zsh-template ~/.zshrc    

    info "Installing font extensions"
    if [ ! -d $ENVIRO/shell/fonts ]; then
        git clone https://github.com/powerline/fonts.git --depth=1 $ENVIRO/shell/fonts
    fi

    $ENVIRO/shell/fonts/install.sh
}

setup_tmux() {
    info "Installing tmux extensions"
    cp -f $ENVIRO/shell/tmux.conf-template ~/.tmux.conf
}

setup_dev_paths() {
    info "Installing various paths and files extensions"
    export GOPATH=$HOME/Projects
    mkdir -p $GOPATH $GOPATH/src/github.com/coreyhulen $GOPATH/src/github.com/mattermost $GOPATH/pkg $GOPATH/bin
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
		esac
		shift
	done

	setup_color

    info "Installing your Mac environment"

    setup_getgitrepo
    setup_homebrew
    setup_alacritty
    setup_vim
    setup_oh_my_zsh
    setup_tmux
    setup_dev_paths
    setup_manual_steps

    echo ""
    echo "${GREEN}Installation complete!${RESET}"
}

main "$@"
