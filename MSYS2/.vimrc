set nocompatible
set encoding=utf8
set guifont=FiraCode\ Nerd\ Font\ 10

set runtimepath=~/.vim/,$VIMRUNTIME
py3 import sys; sys.path = [p.replace('D:/a', 'C:').replace(r'D:\a', 'C:') for p in sys.path]

" Install vim-plug if it's missing
if empty(glob(expand('~/.vim/autoload/plug.vim')))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" install any missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif

let g:ale_linters_explicit=1
let g:ale_echo_msg_format="[%linter%>> %s [%severity%]"
let g:ale_floating_window_border = repeat([''], 8)
let g:ale_lint_on_text_changed = 'insert'
let g:ale_lint_on_enter = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_linters = {
            \'awk': 'gawk',
            \'rust': 'analyzer'
        \}

call plug#begin()
    Plug 'preservim/nerdtree'
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'dense-analysis/ale'
    Plug 'bling/vim-bufferline'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'Shougo/vimproc.vim', {'do' : 'make -j 4'}
    Plug 'airblade/vim-gitgutter'
    Plug 'Yggdroot/indentLine'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    Plug 'Raimondi/delimitMate'
    Plug 'ryanoasis/vim-devicons'
call plug#end()

let g:airline_powerline_fonts=1
let g:airline_theme='serene'
let g:airline#extensions#ale#enabled=1
let g:webdevicons_enable_nerdtree=1
let g:webdevicons_conceal_nerdtree_brackets=1
let g:webdevicons_enable_airline_tabline=1
let g:webdevicons_enable_airline_statusline=1
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

syntax enable
set number
set linebreak
set showbreak=>>>\ |
set showmatch
set errorbells
set visualbell
set hlsearch
set incsearch
set autoindent
set cindent
set expandtab
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4
set ruler
set undolevels=1500
set autochdir
set backspace=indent,eol,start
set mouse=a
set clipboard=unnamed

autocmd VimEnter * NERDTree | if argc() == 1 && isdirectory(argv()[0]) | wincmd p | enew | execute 'cd '.argv()[0] | elseif argc() > 0 | wincmd p | endif
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
autocmd BufEnter * if bufname('#') =~ 'NERDTree_\d\+' && winnr('$') > 1 | let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
autocmd BufWinEnter * if getcmdwintype() == '' | silent NERDTreeMirror | endif
