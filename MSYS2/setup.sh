#!/bin/env bash

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/bash" &> /dev/null

rm -f $HOME/.{bash_aliases,bash_profile,bashrc,envvars,stars.sh}
ln -s $PWD/.bash_aliases $HOME/.bash_aliases
ln -s $PWD/.bash_profile $HOME/.bash_profile
ln -s $PWD/.bashrc $HOME/.bashrc
ln -s $PWD/.envvars $HOME/.envvars
ln -s $PWD/.stars.sh $HOME/.stars.sh

cd ..
ln -s $PWD/.vimrc $HOME/.vimrc

clink_dir=$(cygpath -ua $APPDATA/../Local/clink)
rm -f $clink_dir/{flexprompt_config.lua,clink_settings}
ln -s $PWD/clink/clink_settings $clink_dir/clink_settings
ln -s $PWD/clink/flexprompt_config.lua $clink_dir/flexprompt_config.lua

cd ./git
ln -s $PWD/.gitconfig-windows $HOME/.gitconfig
ln -s $PWD/.defaultgitcfg $HOME/.defaultgitcfg

cd ..
if [[ -d "$HOME/.config" ]]; then
    mv $HOME/.config $HOME/.config_backup
fi
ln -s $PWD/.config $HOME/.config
if [[ -d "$HOME/.config_backup" ]]; then
    mv $HOME/.config_backup/* $HOME/.config
fi

if [[ -f "$HOME/.config/lapce/Lapce-Stable/config/settings-windows.toml" ]]; then
    old_dir=$(pwd)
    cd "$HOME/.config/lapce/Lapce-Stable/config"
    ln -s settings-windows.toml settings.toml
    cd $old_dir
fi

# this assumes I have the GPG keys set up already. If I don't, shame on me!
git add "$(git rev-parse --absolute-git-dir)"
git commit -m 'Found new .config entries in $HOME while running setup!'
git push
