# Nushell Environment Config File

# Nu's built-in cd
def-env nu_cd [pth: string = '.'] {
    cd $pth
}

# Nu's built-in ls
def nu_ls [
    pth: string = '.'
    -S
] {
    let ret = (
        if $S {
            ls -a $pth
        }
        else {
            ls -as $pth
        }
    )
    $ret
}

def lsh [] {
    ls --help
}

module dirstuff {
    export def pathconv [dir?: string@"nu-complete path riven"] {
        let dir = (
            if $dir == $nothing or $dir == "" {
                (^pwd | str replace "\n" '')
            } else if $dir =~ ':/' or $dir =~ ':\\' {
                $dir
            } else if ($dir == '/') {
                "/c/msys64/"
            } else if (($dir | str starts-with '/') and ((^sh -c $"cygpath -m ($dir | str replace -a ' ' '\ ' -s | str replace -a '\(' '\\(' | str replace -a '\)' '\\)')") | path exists)) {
                $dir
            } else if (($dir | str starts-with '/') and ($dir | str ends-with '/') and (($dir | str length) == 3)) {
                "/c/"
            } else if (($dir | str starts-with '/') and (($dir | str length) > 2)) {
                $"/c/msys64($dir)"
            } else {
                $dir
            }
        )
        # Let cygpath handle my shit for me :kekw:
        let homed = (
            if ($dir | str starts-with '~') {
                let expanded = ((^sh -c "cygpath -m $HOME") | lines --skip-empty | first)
                $dir | str replace '~' $expanded | into string | str replace -a '\n' ''
            } else {
                $dir
            }
        )
        let ret = (
            if (($homed | str length) == 2 and ($homed | str starts-with '/')) {
                $"C:/msys64($homed)"
            }
            else {
                (^sh -c $"cygpath -m ($homed | str replace -a ' ' '\ ' -s | str replace -a '\(' '\\(' | str replace -a '\)' '\\)')") | lines --skip-empty | first
            }
        )
        $ret
    }

    export def "nu-complete path riven" [dir: string] {
        let dir = ($dir | str replace "(pathconv|ls|cd)? ?" "" | str replace -a '\' '/' -s)
        let d = (
            if ($dir | str starts-with "/") or ($dir | str starts-with "~") {
                $dir
            }
            else {
                $"./($dir)"
            }
        )
        let realdir = (pathconv $d)

        let basename = ($realdir | path basename)
        let parent = ($realdir | path dirname)
        let p = (
            if ($parent | path exists) {
                $parent
            } else {
                ""
            }
        )
        let ret = (
            if (($p | str length) > 0) {
                nu_ls $p
            } else {
                nu_ls $p -S
            }
        )
        print $ret
        $ret | where type == 'dir' and name != '.' and name != '..' and name =~ $basename | each { |d| $d.name | str replace -a '\' '/' -s }
    }

    export def riv_ls [
        dir?: string@"nu-complete path riven"   # Optional dir to call ls on
    ] {
        let d = ((pathconv $dir) | str replace -a '\ ' ' ' -s | str replace -a '\' '/' -s)
        let realdir = (pathconv $d)
        ^ls --color=auto -A $"($realdir)"
    }

    # Unbreak cd, nushell is hardcoded to expand ~ and / on a per-OS basis
    # Only accepts string inputs, not sure if it assumes tilde and slash to be strings.
    # Blame nu for breakage, not me ❤
    export def-env riv_cd [
        dir?: string@"nu-complete path riven" # The directory to `cd` into. If only `cd` were an msys executable...
    ] {
        let opwd = (pathconv)
        let d = ((pathconv $dir) | str replace -a '\ ' ' ' -s | str replace -a '\' '/' -s)
        nu_cd $d
        let-env OLDPWD = $opwd
    }
}

use dirstuff [riv_cd, riv_ls, pathconv]
alias ls = riv_ls
alias cd = riv_cd


############### MSYS2 replication in nushell. This is pain ###############

# msys2 - /etc/profile
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
let-env PATH = ($PTH | prepend ($PathPrepend | each { |pp| pathconv $pp } ))
let-env Path = $env.PATH

let-env MINGW_MOUNT_POINT = $nothing

# . '/etc/msystem' is actually a long switch-case being sourced
# Do what /etc/msystem does
let-env MSYSTEM_PREFIX = $nothing
let-env MSYSTEM_CARCH = $nothing
let-env MSYSTEM_CHOST = $nothing

let-env MINGW_PREFIX = $nothing
let-env MINGW_PACKAGE_PREFIX = $nothing
let-env MINGW_CHOST = $nothing

let-env MSYSTEM_PREFIX = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        '/usr'
    }
    else {
        $"/($env.MSYSTEM | str downcase)"
    }
)
let-env MSYSTEM_CARCH = (
    if ($env.MSYSTEM =~ 'ARM64') {
        'aarch64'
    }
    else if ($env.MSYSTEM =~ '64') {
        'x86_64'
    }
    else if ($env.MSYSTEM =~ '32') {
        'i686'
    }
    else {
        ((^uname -m) | lines --skip-empty | first)
    }
)
let-env MSYSTEM_CHOST = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $"(^uname -m)-pc-msys"
    }
    else {
        $"($env.MSYSTEM_CARCH)-w64-mingw32"
    }
)

let-env MINGW_CHOST = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $nothing
    } else {
        $env.MSYSTEM_CHOST
    }
)
let-env MINGW_PREFIX = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $nothing
    } else {
        $env.MSYSTEM_PREFIX
    }
)
let toolchain = (
    if $env.MSYSTEM =~ 'MINGW' { 'mingw' }
    else if $env.MSYSTEM =~ 'CLANG' { 'clang' }
    else if $env.MSYSTEM =~ 'UCRT' { 'ucrt' }
)
let-env MINGW_PACKAGE_PREFIX = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $nothing
    } else {
        $"mingw-w64-($toolchain)-($env.MSYSTEM_CARCH)"
    }
)

# Back to /etc/profile, this is where we set the mount point
let-env MINGW_MOUNT_POINT = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $nothing
    } else {
        $env.MINGW_PREFIX
    }
)
let-env PATH = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $env.PATH
    } else {
        $PTH | prepend ($PathPrepend | each { |pp| pathconv $"($env.MINGW_PREFIX)($pp)" } )
    }
)
let-env Path = $env.PATH
let-env PKG_CONFIG_PATH = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        let ulib = pathconv '/usr/lib/pkgconfig'
        let share = pathconv '/usr/share/pkgconfig'
        let lib = pathconv '/lib/pkgconfig'
        $"($ulib):($share):($lib)"
    } else {
        let ulib = pathconv $"($env.MINGW_MOUNT_POINT)/usr/lib/pkgconfig"
        let share = pathconv $"($env.MINGW_MOUNT_POINT)/usr/share/pkgconfig"
        $"($ulib):($share)"
    }
)
let-env ACLOCAL_PATH = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        $nothing
    } else {
        $"($env.MINGW_MOUNT_POINT)/share/aclocal:/usr/share/aclocal"
    }
)
let-env MANPATH = (
    if ($env.MSYSTEM !~ 'UCRT' and $env.MSYSTEM !~ 'CLANG' and $env.MSYSTEM !~ 'MINGW') {
        "/usr/local/man:/usr/share/man:/usr/man:/share/man"
    } else {
        $"($env.MINGW_MOUNT_POINT)/local/man:($env.MINGW_MOUNT_POINT)/share/man:/usr/local/man:/usr/share/man:/usr/man:/share/man"
    }
)
let-env CONFIG_SITE = "/etc/config.site"

let-env MAYBE_FIRST_START = false
let-env SYSCONFDIR = "/etc"

let-env tmp = $env.TMP
let-env temp = $env.TEMP
let-env TMP = '/tmp'
let-env TEMP = '/tmp'

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
