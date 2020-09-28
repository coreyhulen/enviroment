
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
    info "Finished installing Homebrew modules"
}

setup_docker() {
    if ! command_exists docker; then
        error "Failed to find Docker for Mac. Please install from https://hub.docker.com/editions/community/docker-ce-desktop-mac/"        
        exit 1
    else
        info "Detected Docker as installed"
    fi
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
    mkdir -p $GOPATH $GOPATH/src $GOPATH/pkg $GOPATH/bin
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
    warn "3. Install Divvy Window Mgt for Mac from the MacStore"
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

    info "Installing your Mac enviroment"

    setup_getgitrepo
    setup_homebrew
    setup_docker
    setup_karabiner
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
