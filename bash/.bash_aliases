alias ls='ls --color=auto -A'
alias lsc='ls --color=always'
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
alias code='codium'
# Might start using helix more tbh
if command -v helix &> /dev/null
then
    alias hx='helix'
fi
