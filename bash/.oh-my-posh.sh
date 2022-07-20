export POSH_THEME='/home/Riven/.iterm2.omp.json'
export POWERLINE_COMMAND="oh-my-posh"
export CONDA_PROMPT_MODIFIER=false

TIMER_START="/tmp/${USER}.start.$$"

# some environments don't have the filesystem we'd expect
if [[ ! -d "/tmp" ]]; then
  TIMER_START="${HOME}/.${USER}.start.$$"
fi

# start timer on command start
PS0='$(C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe get millis > "$TIMER_START")'
# set secondary prompt
PS2="$(C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe print secondary --config="$POSH_THEME" --shell=bash --shell-version="$BASH_VERSION")"

function _omp_hook() {
    local ret=$?

    omp_stack_count=$((${#DIRSTACK[@]} - 1))
    omp_elapsed=-1
    if [[ -f "$TIMER_START" ]]; then
        omp_now=$(C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe get millis)
        omp_start_time=$(cat "$TIMER_START")
        omp_elapsed=$((omp_now-omp_start_time))
        rm -f "$TIMER_START"
    fi
    PS1="$(C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe print primary --config="$POSH_THEME" --shell=bash --shell-version="$BASH_VERSION" --error="$ret" --execution-time="$omp_elapsed" --stack-count="$omp_stack_count" | tr -d '\0')"

    return $ret
}

if [ "$TERM" != "linux" ] && [ -x "$(command -v C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe)" ] && ! [[ "$PROMPT_COMMAND" =~ "_omp_hook" ]]; then
    PROMPT_COMMAND="_omp_hook; $PROMPT_COMMAND"
fi

function _omp_runonexit() {
  [[ -f $TIMER_START ]] && rm -f "$TIMER_START"
}

trap _omp_runonexit EXIT
