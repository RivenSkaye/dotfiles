let-env POWERLINE_COMMAND = 'oh-my-posh'
let-env POSH_THEME = 'C:\Users\Riven\.iterm2.omp.json'
let-env PROMPT_INDICATOR = ""
# By default displays the right prompt on the first line
# making it annoying when you have a multiline prompt
# making the behavior different compared to other shells
let-env PROMPT_COMMAND_RIGHT = {''}
let-env NU_VERSION = (version | get version)

# PROMPTS
let-env PROMPT_MULTILINE_INDICATOR = (^'C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' print secondary $"--config=($env.POSH_THEME)" --shell=nu $"--shell-version=($env.NU_VERSION)")

let-env PROMPT_COMMAND = {
    let width = (term size -c | get columns | into string)
    ^'C:/Users/Riven/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' print primary $"--config=($env.POSH_THEME)" --shell=nu $"--shell-version=($env.NU_VERSION)" $"--execution-time=($env.CMD_DURATION_MS)" $"--error=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
}
