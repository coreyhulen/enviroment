
#!/usr/bin/env zsh

echo "\nInstalling your Mac enviroment\n"

if [ ! -d /Applications/Karabiner-Elements.app ]; then
    echo "FAIL - Missing directory for /Applications/Karabiner-Elements.app"
    echo "       You need to install the Mac keyboard remapper from"
    echo "       https://karabiner-elements.pqrs.org/https://karabiner-elements.pqrs.org/" >&2
    echo ""
    exit 1
else
    echo "Detected Karabiner-Elements as installed\n"
fi

if [ ! -d /usr/local/Homebrew ]; then
    echo "Installing Homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo ""
else
    echo "Detected Homebrew as installed\n"
fi

echo "Installing Homebrew modules..."
brew update
brew upgrade
brew install wget
brew install go
brew install node
brew install libpng
echo "Finished installing Homebrew modules\n"

if [ ! -d /Applications/Docker.app ]; then
    echo "FAIL - Missing directory for /Applications/Docker.app"
    echo "       You need to install Docker for Mac from"
    echo "       https://hub.docker.com/editions/community/docker-ce-desktop-mac/" >&2
    echo ""
    exit 1
else
    echo "Detected Docker as installed\n"
fi

echo "Installing keyboard remapper perferences to make mac work like windows..."
mkdir -p ~/.config/karabiner/
cp -f keyboard/karabiner.json ~/.config/karabiner/
echo "Finished installing keyboard remapper\n"

echo "Installing vim extensions..."
if [ ! -d ./vim/bundle ]; then
    git clone https://github.com/ctrlpvim/ctrlp.vim.git ./vim/bundle/ctrlp.vim
fi

mkdir -p ~/.vim
cp -Rf vim/autoload ~/.vim/
cp -Rf vim/colors ~/.vim/
cp -Rf vim/bundle ~/.vim/
cp -f vim/vimrc.vim-template ~/.vimrc
echo "Finished installing vim extensions\n"

echo "Installing shell extensions..."
if [ ! -d ./shell/oh-my-zsh ]; then
    git clone git://github.com/robbyrussell/oh-my-zsh.git ./shell/oh-my-zsh
	git clone https://github.com/powerline/fonts.git --depth=1 ./shell/fonts
fi
./shell/fonts/install.sh
cp -Rf ./shell/oh-my-zsh ~/.oh-my-zsh
cp -f ./shell/zshrc.zsh-template ~/.zshrc
echo "Finished installing shell extensions\n"

echo "Installing various paths and files extensions..."
export GOPATH=$HOME/Projects
mkdir -p $GOPATH $GOPATH/src $GOPATH/pkg $GOPATH/bin
echo "Finished installing various paths and files extensions\n"

echo ""
echo "MANUAL STEPS NEEDED:"
echo "1. For Mission Control on Mac"
echo "   Goto System Preferences > Mission Control"
echo "   map 'Mission Control:' to 'Mouse Button 4'"
echo "   map 'Show Desktop:' to 'Mouse Button 5'"
echo ""
echo "ALL FINISHED!"