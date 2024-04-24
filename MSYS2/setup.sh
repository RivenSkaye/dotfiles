#!/bin/env bash

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/bash" &> /dev/null

rm -f $HOME/.{bash_aliases,bash_profile,bashrc,envvars,stars.sh}
ln -s ./.bash_aliases $HOME/.bash_aliases
ln -s ./.bash_profile $HOME/.bash_profile
ln -s ./.bashrc $HOME/.bashrc
ln -s ./.envvars $HOME/.envvars
ln -s ./.stars.sh $HOME/.stars.sh

cd ..
ln -s .vimrc $HOME/.vimrc

cd ../git
ln -s ./gitconfig-windows $HOME/.gitconfig
ln -s ./defaultgitcfg $HOME/.defaultgitcfg

cd ..
if [[ -d "$HOME/.config" ]]; then
    mv $HOME/.config $HOME/.config_backup
fi
ln -s ./.config $HOME/.config
if [[ -d "$HOME/.config_backup" ]]; then
    mv $HOME/.config_backup/* $HOME/.config
fi

if [[ -d "$HOME/.config/lapce/Lapce-Stable/config" ]]; then
    old_dir=$(pwd)
    cd "$HOME/.config/lapce/Lapce-Stable/config"
    ln -s settings-windows.toml settings.toml
fi
