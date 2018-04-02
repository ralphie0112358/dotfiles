#!/usr/bin/env bash
cd ~
git clone https://github.com/ralphie0112358/dotfiles.git

mv .bashrc .bashrc.orig 2>/dev/null
ln -s dotfiles/bashrc .bashrc

mv .inputrc .inputrc.orig 2>/dev/null
ln -s dotfiles/inputrc .inputrc

mv .vimrc .vimrc.orig 2>/dev/null
ln -s dotfiles/vimrc.py .vimrc

mv .vim .vim.orig 2>/dev/null
ln -s dotfiles/vim .vim

mkdir -p Backups

