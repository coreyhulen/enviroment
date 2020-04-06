.PHONY: all install clean nuke

all: install

.download:
	@git clone git://github.com/robbyrussell/oh-my-zsh.git
	@git clone https://github.com/powerline/fonts.git --depth=1
	@touch $@

install: .download
	./fonts/install.sh
	@cp -Rf oh-my-zsh ~/.oh-my-zsh
	@cp -f zshrc.zsh-template ~/.zshrc
	@chsh -s /bin/zsh
	@export GOPATH=$HOME/Projects
	@mkdir -p $GOPATH $GOPATH/src $GOPATH/pkg $GOPATH/bin
	@mkdir -p ~/Library/KeyBindings
	cp DefaultKeyBinding.dict ~/Library/KeyBindings

clean:
	@rm -rf fonts
	@rm -rf ~/.oh-my-zsh
	@rm -f ~/.zshrc	

nuke: clean
	@rm -f .download
	@rm -rf oh-my-zsh
