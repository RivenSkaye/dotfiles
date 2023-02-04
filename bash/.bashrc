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
[[ "$-" != *i* ]] && return

source ~/.envvars

if [ -d "$CARGO_HOME" ]; then
    PATH="$PATH:$CARGO_HOME/bin"
fi
if [ -d "$HOME/.ghcup" ]; then
    PATH="$PATH:$HOME/.ghcup/bin"
fi
if [ -f "${HOME}/.bash_aliases" ]; then
    source "${HOME}/.bash_aliases"
fi
if [ -f "${HOME}/.stars.sh" ]; then
    source ~/.stars.sh
fi
cls && neofetch

PATH="$PATH:$CARGO_HOME/bin:$HOME/.ghcup/bin"
