" File:     ~/.vim/vimrc

let g:python3_host_prog = "/usr/bin/python3"
let g:python_host_prog = "/usr/bin/python2"

" {{{ Plugins
" vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fsLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin()
Plug 'sheerun/vim-polyglot'
Plug 'tomasr/molokai'
Plug 'tpope/vim-surround'

Plug 'vim-latex/vim-latex'
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
set grepprg=grep\ -nH\ $*

Plug 'mbbill/undotree'
nnoremap U :UndotreeToggle<CR>

if has("nvim")
    Plug 'neomake/neomake'
    autocmd BufWritePost * Neomake
    let g:neomake_open_list = 2
    let g:neomake_list_height = 3

    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1
endif
call plug#end()
" }}}

"{{{ Theme
let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai
set background=dark

if has("vim")
    set t_Co=256
    set nocompatible
    set ttyfast
endif
" }}}

" {{{ Undo, Backups, Swap
" Persistent undo
if has("persistent_undo")
    set undodir=~/.vim/_undo
    set undofile
    set backup
    set backupdir=~/.vim/_backup/,/tmp          " Backups
    set dir=~/.vim/_swap/                       " Swap files
endif

if has("clipboard")
    set clipboard^=unnamedplus
endif
" }}}

" {{{ Netrw
let g:netrw_liststyle = 3       " Set tree style as default
let g:netrw_winsize = 25        " Set width to 25% of page
" }}}

" {{{ Folds
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
set modelines=1
nnoremap <SPACE> za
" }}}

" {{{ General
set number
set relativenumber
set scrolloff=1
set sidescrolloff=5
set display+=lastline
set autoread
set updatetime=250
set showmode
set cursorline                  " Highlight the current line
set autoindent
set formatoptions=qrn1
set backspace=indent,eol,start
set path+=**

set shiftwidth=4
set shiftround

set linebreak                   " Don't wrap words by default
set wrap
set nolist
set textwidth=0
set wrapmargin=0

set history=1000

set tabstop=4 softtabstop=4 shiftwidth=4
set list listchars=tab:»\ ,extends:»

set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.log,.aux,.bbl,.blg,.idx,.ilg,.ind,.out,.pdf

if has('syntax')
    syntax enable
    set omnifunc=syntax
endif

set title
set showcmd                         " Show (partial) command in status line.
set showmatch                       " Show matching brackets.

set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>

set gdefault                            " Substitute globally on lines
set autowrite                           " Automatically save before commands like :next and :make
set hidden                              " Hide buffers when they are abandoned
set lazyredraw                          " Redraw only when needed
set wildmenu
set wildignore=*.swp,*.bak,*.pyc,*.class
set pastetoggle=<f11>
set whichwrap+=<,>,[,]
set splitbelow splitright
set esckeys                             " Allow using arrow keys to navigate
set visualbell t_vb=                    " Disable the bell
set nodigraph                           " Enable input of special characters by combining two characters
set noerrorbells                        " Disable error bells
set shortmess=at                        " Abbreviate and truncate messages when necessary
set matchpairs=(:),[:],{:},<:>          " Highlight matching parens
set comments=b:#,:%,fb:-,n:>,n:)

if has("mouse")
    set mouse=a
endif
" }}}

" {{{ Functions
function! StripWhitespace()
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction

command! StripWhitespace silent! call StripWhitespace()
" }}}

" {{{ Autocmd
if has("autocmd")
    " Load indentation rules according to detected filetype.
    filetype plugin indent on

    autocmd FocusLost,WinLeave   * silent! wa
    autocmd FocusGained,BufEnter * silent! !

    " Convert spaces to tabs when reading file, tabs to spaces before writing, spaces back to tabs after writing file
    let blacklist=['yaml']
    autocmd BufReadPost  * if index(blacklist, &ft) < 0 | silent! undojoin | set noexpandtab | silent! retab! 4
    autocmd BufWritePre  * if index(blacklist, &ft) < 0 | silent! undojoin | set expandtab   | silent! retab! 4
    autocmd BufWritePost * if index(blacklist, &ft) < 0 | silent! undojoin | set noexpandtab | silent! retab! 4

    autocmd FileType tex,txt setlocal spell spelllang=en_us

    augroup enter_esc
        autocmd!
        autocmd BufReadPost quickfix nnoremap <buffer> <Esc>    :q<CR>
        autocmd CmdWinEnter *        nnoremap <buffer> <Esc>    :q<CR>
        autocmd FileType    netrw    nnoremap <buffer> <Esc>    :e #<CR>
    augroup END

    augroup fast_esc
        autocmd InsertEnter * set timeoutlen=500
        autocmd InsertLeave * set timeoutlen=1000
    augroup END

    let blacklist=['markdown', 'diff', 'gitcommit', 'unite', 'qf', 'help']
    autocmd BufWritePre * if index(blacklist, &ft) < 0 | StripWhitespace
endif
" }}}

" {{{ Statusline
set statusline=
set statusline+=%1*%3v          "virtual column number
set statusline+=\ %<\%F\        "full path
set statusline+=%m              "modified flag
set statusline+=%r              "read only flag
set statusline+=%=%l            "current line
set statusline+=/%L             "total lines
" }}}

" {{{ Key Remaps
inoremap jk <esc>
inoremap kj <esc>
inoremap JK <esc>
inoremap KJ <esc>

nnoremap j gj
nnoremap k gk

vnoremap Q gq
nnoremap Q gqap

inoremap {<cr> {<cr>}<c-o>O
inoremap [<cr> [<cr>]<c-o>O
inoremap (<cr> (<cr>)<c-o>O

nnoremap <leader>W :w !sudo tee > /dev/null %<CR><CR>

" Very magic mode, global replace, ask for confirmation
nnoremap <leader>/ :%s/\v/gc<Left><Left><Left>
" }}}

" {{{ Spelling
" Toggle spelling with F10 key:
map <F10> :set spell!<CR><Bar>:echo "Spell Check: " . strpart("OffOn", 3 * &spell, 3)<CR>
set spellfile=~/.vim/spellfile.add

" Highlight spelling correction:
highlight SpellBad  term=reverse     ctermbg=12 gui=undercurl guisp=Red
highlight SpellCap  term=reverse     ctermbg=9  gui=undercurl guisp=Orange
highlight SpellRare term=reverse     ctermbg=13 gui=undercurl guisp=Magenta
highlight SpellLocale term=underline ctermbg=11 gui=undercurl guisp=Yellow
set sps=best,10
" }}}

" {{{ Colors
highlight normal                ctermfg=white   ctermbg=black
highlight nontext               ctermfg=gray    ctermbg=black

highlight whitespace            ctermfg=red     ctermbg=red
match whitespace /\s\+$/                " Show trailing whitespace

highlight NeomakeErrorSign      ctermbg=red
highlight NeomakeWarningSign    ctermbg=magenta
highlight NeomakeMessageSign    ctermbg=yellow
highlight NeomakeInfoSign       ctermbg=blue

highlight NeomakeError          ctermbg=red
highlight NeomakeWarning        ctermbg=magenta
highlight NeomakeMessage        ctermbg=yellow
highlight NeomakeInfo           ctermbg=blue

set pumheight=7
highlight Pmenu      ctermbg=13                 guifg=Black   guibg=#BDDFFF
highlight PmenuSel   ctermbg=7                  guifg=Black   guibg=Orange
highlight PmenuSbar  ctermbg=7                  guifg=#CCCCCC guibg=#CCCCCC
highlight PmenuThumb cterm=reverse  gui=reverse guifg=Black   guibg=#AAAAAA
" }}}

" vim:foldmethod=marker:foldlevel=0
