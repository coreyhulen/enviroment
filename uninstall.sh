#!/usr/bin/env zsh

echo ""
echo "Uninstall your Mac enviroment"
echo ""

echo "Uninstalling Homebrew modules..."
#brew uninstall wget
#brew uninstall go
#brew uninstall node
#brew uninstall libpng
echo "Finished uninstalling Homebrew modules\n"


echo "Uninstalling keyboard remapper perferences to make mac work like windows"
rm ~/.config/karabiner/karabiner.json
echo "Finished uninstalling keyboard remapper\n"

echo "Uninstalling vim extensions..."
rm -rf ~/.vim
rm -f ~/.vimrc
rm -rf ./vim/bundle
echo "Finished uninstalling vim extensions\n"

echo "Uninstalling shell extensions..."
rm -rf ./shell/fonts
rm -rf ./shell/oh-my-zsh
rm -rf ~/.oh-my-zsh
rm -f ~/.zshrc	
echo "Finished uninstalling shell extensions\n"

echo ""
echo "MANUAL STEPS NEEDED:"
echo "1. Uninstall Karabiner-Elements"
echo "2. Uninstall Homebrew"
echo "2. Uninstall Docker"
echo ""
echo "ALL FINISHED!"