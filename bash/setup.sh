#!/usr/bin/env bash

cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null

rm -f $HOME/.{bash_aliases,bash_profile,bashrc,envvars} # TODO add stars.sh back in
ln -s "$(pwd)/.bash_aliases" "$HOME/.bash_aliases"
ln -s "$(pwd)/.bash_profile" "$HOME/.bash_profile"
ln -s "$(pwd)/.bashrc" "$HOME/.bashrc"
ln -s "$(pwd)/.envvars" "$HOME/.envvars"

# TODO get the Linux version of stars.sh in this repo
ln -s "$(pwd)/.stars.sh" "$HOME/.stars.sh"

cd ../git
ln -s "$(pwd)/.gitconfig-linux" "$HOME/.gitconfig"
ln -s "$(pwd)/.defaultgitcfg" "$HOME/.defaultgitcfg"

cd ..
if [[ -d "$HOME/.config" ]]; then
    mv $HOME/.config $HOME/.config_backup
fi
ln -s "$(pwd)/.config" "$HOME/.config"
if [[ -d "$HOME/.config_backup" ]]; then
	mv $HOME/.config_backup/* "$(pwd)/.config"
fi

if [[ -f "$HOME/.config/lapce/Lapce-Stable/config/settings-linux.toml" ]]; then
    old_dir=$(pwd)
    cd "$HOME/.config/lapce/Lapce-Stable/config"
    ln -s settings-linux.toml settings.toml
    cd $old_dir
fi

# this assumes I have the GPG keys set up already. If I don't, shame on me!
git add "$(git rev-parse --absolute-git-dir)"
git commit -m 'Found new .config entries in $HOME while running setup!'
git push
