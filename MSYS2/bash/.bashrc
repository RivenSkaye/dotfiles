# To the extent possible under law, the author(s) have dedicated all
# copyright and related and neighboring rights to this software to the
# public domain worldwide. This software is distributed without any warranty.
# You should have received a copy of the CC0 Public Domain Dedication along
# with this software.
# If not, see <https://creativecommons.org/publicdomain/zero/1.0/>.

# ~/.bashrc: executed by bash(1) for interactive shells.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the msys2 mailing list.

# User dependent .bashrc file

# If not running interactively, don't do anything

export LOGNAME="$(logname)"

[[ "$-" != *i* ]] && return

if [ -f "${HOME}/.bash_aliases" ]; then
    source "${HOME}/.bash_aliases"
fi

source ~/.envvars
export PATH="$CARGO_HOME/bin:$PATH"

if [[ -d "$HOME/.go/bin" ]]; then
    export PATH="$PATH:$HOME/.go/bin"
fi

if [[ -d "$HOME/.bin/vim90" ]]; then
    export PATH="$HOME/.bin/vim90:$PATH"
fi

if [[ -d "$XDG_CONFIG_HOME/bat" ]]; then
    export BAT_CONFIG_DIR="$XDG_CONFIG_HOME/bat"
fi

if command -v starship &> /dev/null
then
    if [ -f "${HOME}/.stars.sh" ]; then
        source ~/.stars.sh
    fi
fi

# Fucking Dutch system locale
export LANG=en_US.UTF-8
export LC_CTYPE="en_US.UTF-8"

cls && neofetch
PROG=tea source "`cygpath -ma $HOME/.config/tea/autocomplete.sh`"
