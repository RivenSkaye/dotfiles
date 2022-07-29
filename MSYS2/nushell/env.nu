# Nushell Environment Config File

# Nu's built-in cd
def-env nu_cd [pth: string = '.'] {
    (cd $pth)
}

# Nu's built-in ls
def-env nu_ls [pth: string = '.'] {
    (ls $pth)
}

module dirstuff {
    def pathconv [dir: string] {
        # Let cygpath handle my shit for me :kekw:
        let homed = (
            if ($dir | str starts-with '~') {
                let expanded = ((^sh -c "cygpath -m $HOME") | into string | str trim -c "\n")
                $dir | str replace '~' $expanded | into string | str replace -a '\n' ''
            } else { $dir }
        )
        ((^sh -c $"cygpath -m ($homed)") | into string | str trim -c "\n" )
    }

    def "nu-complete path" [dir: string] {
        let d = (
            if $dir == ""{
                "./"
            } else {
                $dir
            }
        )
        let realdir = (pathconv $d)
        print $realdir
        ((^ls -a1 $realdir) | lines | each { |d| $d | str trim })
    }

    export def magic_ls [dir: string@"nu-complete path"] {
        let realdir = (pathconv $dir)
        ^ls --color=auto -A $"($realdir)"
    }

    # Unbreak cd, nushell is hardcoded to expand ~ and / on a per-OS basis
    # Only accepts string inputs, not sure if it assumes tilde and slash to be strings.
    # Blame nu for breakage, not me ❤
    export def-env magic_cd [
        dir: string@"nu-complete path" # The directory to `cd` into. If only `cd` were an msys executable...
    ] {
        # Collect the rest args into one string, unescape escaped spaces, convert backslashes to slashes
        let coll = ($dir | str replace -a '\ ' ' ' -s | str replace -a '\' '/' -s)
        # Escape spaces afterwards. This should be an unfucked, forward slash separated version of input
        let d = (
            if $coll == "" {
                "."
            }
            else {
                $coll | str replace -a ' ' '\ ' -s
            }
        )
        let realdir = (pathconv $d)
        cd $realdir
    }
}

use dirstuff [magic_cd, magic_ls]
alias cd = magic_cd
alias ls = magic_ls


############### MSYS2 replication in nushell. This is pain ###############

# msys2 - /etc/profile
let WIN_ROOT = "/c/Windows"
let PathPrepend = [
    '/usr/local/bin', '/usr/bin', '/bin'
]

let-env SystemDrive = '/c/'
let-env SystemRoot = '/c/msys64/'

let PTH = (
    if ((env | where name == 'MSYS2_PATH_TYPE' | get raw.0) == 'strict') {
        []
    } else if (('Path' in (env).name) and ('PATH' not-in (env).name)) {
        $env.Path
    } else if (('PATH' in (env).name) and ('Path' not-in (env).name)) {
        $env.PATH
    } else if (('PATH' in (env).name) and ('Path' in (env).name)) {
        if ($env.PATH | length) > ($env.Path | length) {
            $env.Path | each { |P| $env.PATH | prepend $P }
            $env.PATH
        } else {
            $env.PATH | each { |P| $env.Path | prepend $P }
            $env.Path
        }
    }
)
let-env PATH = ($PTH | prepend PathPrepend)
let-env Path = ($PTH | prepend PathPrepend)
let-env MINGW_MOUNT_POINT = $nothing

# Do what /etc/msystem does
let-env MSYSTEM_PREFIX = $nothing
let-env MSYSTEM_CARCH = $nothing
let-env MSYSTEM_CHOST = $nothing

let-env MINGW_PREFIX = $nothing
let-env MINGW_CARCH = $nothing
let-env MINGW_CHOST = $nothing

let-env MSYSTEM_PREFIX = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') { '/usr' }
    else { $"/($env.MSYSTEM | str downcase)" }
)
let-env MSYSTEM_CARCH = (
    if $env.MSYSTEM =~ 'ARM64' { 'aarch64' }
    else if $env.MSYSTEM =~ '64' { 'x86_64' }
    else if $env.MSYSTEM =~ '32' { 'i686' }
    else { $"(^uname -m)" }
)
let-env MSYSTEM_CHOST = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') { $"(^uname -m)-pc-msys" }
    else { $"($env.MSYSTEM_CARCH)-w64-mingw32" }
)

def-env mingwvars [] {
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') { return }
}

let-env MINGW_CHOST = $env.MSYSTEM_CHOST
let-env MINGW_PREFIX = $env.MSYSTEM_PREFIX
let toolchain = (
    if $env.MSYSTEM =~ 'MINGW' { 'mingw' }
    else if $env.MSYSTEM =~ 'CLANG' { 'clang' }
    else if $env.MSYSTEM =~ 'UCRT' { 'ucrt' }
)
let-env MINGW_PACKAGE_PREFIX = $"mingw-w64-($toolchain)-($env.MSYSTEM_CARCH)"


def create_left_prompt [] {
    let path_segment = ($env.PWD)

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | date format '%m/%d/%Y %r')
    ] | str collect)

    $time_segment
}

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = { create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = { "〉" }
let-env PROMPT_INDICATOR_VI_INSERT = { ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = { "〉" }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }
let-env EDITOR = 'vim'
let-env VISUAL = 'code'

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

let-env BROWSER = 'firefox'
let-env HOMEDRIVE = "C:"
let-env HOME = $"($env.HOMEDRIVE)/msys64/home/(^id -nu)"
let-env HOMEPATH = $env.HOME
let-env LANG = 'en_US.UTF-8'

alias rm = ^rm -f
alias DEL = ^rm
alias cls = clear


cd $env.HOME
# Variables can't be resolved until _after_ this runs. So source omp in config.nu
# oh-my-posh init nu --config ~/.iterm2.omp.json
history -c
# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
    "PATH": {
      from_string: { |s| $s | split row (char esep) }
      to_string: { |v| $v | path expand | str collect (char esep) }
    }
    "Path": {
      from_string: { |s| $s | split row (char esep) }
      to_string: { |v| $v | path expand | str collect (char esep) }
    }
}
