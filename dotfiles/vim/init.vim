" File:     ~/.vim/vimrc

" Theme
let g:rehash256 = 1
colorscheme molokai
set background=dark

if has("vim")
    set t_Co=256
    set nocompatible
    set ttyfast
endif

" {{{ Plugins
" vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fsLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin()
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'kshenoy/vim-signature'

Plug 'ntpeters/vim-better-whitespace'
if has("autocmd")
    let blacklist=['markdown', 'diff', 'gitcommit', 'unite', 'qf', 'help']
    autocmd BufWritePre * if index(blacklist, &ft) < 0 | StripWhitespace
endif

Plug 'mbbill/undotree'
nnoremap U :UndotreeToggle<CR>

Plug 'reedes/vim-pencil'
let g:pencil#textwidth = 80
if has("autocmd")
    augroup pencil
        autocmd!
        autocmd FileType markdown,mkd call pencil#init({'wrap': 'hard'})
        autocmd FileType tex,text     call pencil#init({'wrap': 'soft'})
    augroup END
endif

if has("nvim")
    Plug 'neomake/neomake'
    autocmd BufWritePost * Neomake

    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1
endif
call plug#end()
" }}}

" {{{ Undo, Backups, Swap
" Persistent undo
if has("persistent_undo")
    if has("nvim")
        set undodir=~/.config/nvim/_undo
    else
        set undodir=~/.vim/_undo
    endif
    set undofile
    set backup
endif

" Backups
if has("nvim")
    set backupdir=~/.config/nvim/_backup/,/tmp
else
    set backupdir=~/.vim/_backup/,/tmp
endif

" Swap files
if has("nvim")
    set dir=~/.config/nvim/_swap/
else
    set dir=~/.vim/_swap/
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
set matchpairs=(:),[:],{:},<:>          " highlight matching parens:
set comments=b:#,:%,fb:-,n:>,n:)

if has("mouse")
    set mouse=a
endif
" }}}

" {{{ Autocmd
if has("autocmd")
    " Load indentation rules according to detected filetype.
    filetype plugin indent on

    autocmd FocusLost,WinLeave * :silent! wa
    autocmd FocusGained,BufEnter * :silent! !

    " Convert spaces to tabs when reading file, tabs to spaces before writing, spaces back to tabs after writing file
    autocmd BufReadPost * set noexpandtab | retab! 4
    autocmd BufWritePre * set expandtab | retab! 4
    autocmd BufWritePost * set noexpandtab | retab! 4

    autocmd FileType tex,txt setlocal spell spelllang=en_us

    augroup enter_esc
        autocmd!
        autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
        autocmd BufReadPost quickfix nnoremap <buffer> <Esc> :q<CR>
        autocmd CmdWinEnter * nnoremap <buffer> <CR> <CR>
        autocmd CmdWinEnter * nnoremap <buffer> <Esc> :q<CR>
        autocmd FileType netrw nnoremap <buffer> <Esc> :e #<CR>
    augroup END

    augroup fast_esc
        autocmd InsertEnter * set timeoutlen=500
        autocmd InsertLeave * set timeoutlen=1000
    augroup END
endif
" }}}

" {{{ Statusline
set statusline=
set statusline+=%1*%3v          "virtual column number
set statusline+=\ %<\%F         "full path
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

vnoremap Q gq
nnoremap Q gqap

inoremap {<cr> {<cr>}<c-o>O
inoremap [<cr> [<cr>]<c-o>O
inoremap (<cr> (<cr>)<c-o>O

nnoremap <CR> :

cmap w!! w !sudo tee > /dev/null %

if has("nvim")
    highlight TermCursor ctermfg=green guifg=green
    tnoremap <leader><Esc> <C-\><C-n>
    command! VTerm execute "vsplit" | execute "terminal"
    command! HTerm execute "split" | execute "terminal"
    command! TTerm execute "tabedit" | execute "terminal"
endif
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
hi normal   ctermfg=white   ctermbg=black guifg=white   guibg=black
hi nontext  ctermfg=green   ctermbg=black guifg=white   guibg=black

set pumheight=7
highlight Pmenu      ctermbg=13                 guifg=Black   guibg=#BDDFFF
highlight PmenuSel   ctermbg=7                  guifg=Black   guibg=Orange
highlight PmenuSbar  ctermbg=7                  guifg=#CCCCCC guibg=#CCCCCC
highlight PmenuThumb cterm=reverse  gui=reverse guifg=Black   guibg=#AAAAAA
" }}}

" vim:foldmethod=marker:foldlevel=0
