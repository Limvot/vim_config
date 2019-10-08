#!/bin/sh
mkdir -p ~/.config/i3
mkdir -p ~/.config/sway
ln -s ~/vim_config/i3_config ~/.config/i3/config
ln -s ~/vim_config ~/.vim
ln -s ~/vim_config ~/.config/nvim
ln -s ~/vim_config/vimrc ~/.vimrc
ln -s ~/vim_config/vimrc ~/.config/nvim/init.vim
ln -s ~/vim_config/tmux.conf ~/.tmux.conf
ln -s ~/vim_config/bashrc ~/.bashrc
ln -s ~/vim_config/zshrc ~/.zshrc
ln -s ~/vim_config/sway_config ~/.config/sway/config
