.PHONY: all install clean nuke

all: install

.download:
	@git clone https://github.com/ctrlpvim/ctrlp.vim.git ./bundle/ctrlp.vim
	@touch $@

install: .download
	@mkdir -p ~/.vim
	@cp -Rf autoload ~/.vim/
	@cp -Rf colors ~/.vim/
	@cp -Rf bundle ~/.vim/
	@cp -f vimrc.vim-template ~/.vimrc

clean:
	@rm -rf ~/.vim
	@rm -f ~/.vimrc

nuke: clean
	@rm -f .download
	@rm -rf bundle
