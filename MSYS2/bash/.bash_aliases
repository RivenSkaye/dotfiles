alias ls='ls --color=auto -A'
alias rm='rm -f'
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
