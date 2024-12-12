alias ls='ls --color=auto -Ap'
alias DEL='rm'
alias cls='clear'
if command -v bat &> /dev/null
then
	alias cat='bat'
fi
if command -v plocate &> /dev/null
then
	alias locate='plocate'
elif command -v mlocate &> /dev/null
then
	alias locate='mlocate'
fi
alias sl='sl -aFcl && ls'
alias code='code'

if command -v mpv.com &> /dev/null
then
	alias mpv='mpv.com'
fi
if command -v fastfetch &> /dev/null
then
    alias neofetch="fastfetch"
fi
if command -v helix &> /dev/null
then
    alias hx='helix'
fi
alias paru="pacman -Syuu --noconfirm && rustup update && PCRE2_SYS_STATIC=1 cargo install-update -a"
alias flameshot='"/c/Program Files/Flameshot/bin/flameshot"'
