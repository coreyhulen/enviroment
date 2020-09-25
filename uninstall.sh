
#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreyhulen/enviroment/master/uninstall.sh)"

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

remove_homebrew() {
    info "Uninstalling Homebrew modules"
    brew uninstall wget
    brew uninstall go
    brew uninstall node
    brew uninstall libpng
    brew uninstall tmux
    info "Finished uninstalling Homebrew modules"
}

remove_vim() {
    info "Uninstalling vim extensions"
    rm -rf ~/.vim
    rm -f ~/.vimrc
    rm -rf ./vim/bundle
    info "Finished uninstalling vim extensions"
}

remove_oh_my_zsh() {
    info "Uninstalling shell extensions"
    rm -rf ./shell/fonts
    rm -rf ./shell/oh-my-zsh
    rm -rf ~/.oh-my-zsh
    rm -f ~/.zshrc	
    info "Finished uninstalling shell extensions"
}

remove_tmux() {
    info "Uninstalling tmux extensions"
    rm -f ~/.tmux.conf
}

remove_enviroment() {
    info "Uninstalling enviroment"
    if [ -d $ENVIRO ]; then
        rm -rf "${ENVIRO}"
    fi
}

remove_manual_steps() {
    echo ""
    warn "MANUAL STEPS NEEDED:"
    warn "1. Uninstall Homebrew"
    warn "2. Uninstall Docker"
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

    info "Uninstalling your Mac enviroment"

    remove_homebrew
    remove_vim
    remove_oh_my_zsh
    remove_tmux
    remove_enviroment
    remove_manual_steps

    echo ""
    echo "${GREEN}Uninstall complete!${RESET}"
}

main "$@"








