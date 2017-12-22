.PHONY: all install clean nuke

all: install

.download:
	@git clone git://github.com/robbyrussell/oh-my-zsh.git
	@touch $@

install: .download
	@cp -Rf oh-my-zsh ~/.oh-my-zsh
	@cp -f zshrc.zsh-template ~/.zshrc
	@chsh -s /bin/zsh

clean:
	@rm -rf ~/.oh-my-zsh
	@rm -f ~/.zshrc
	@chsh -s /bin/bash

nuke: clean
	@rm -f .download
	@rm -rf oh-my-zsh
