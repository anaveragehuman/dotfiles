" File:     ~/.vim/vimrc

let g:python3_host_prog = "/usr/bin/python3"
let g:python_host_prog = "/usr/bin/python2"

" {{{ Plugins
" vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fsLo --create-dirs ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin()
Plug 'tomasr/molokai'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/Align'
Plug 'tommcdo/vim-exchange'

Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['tex']

Plug 'lervag/vimtex'
let g:vimtex_fold_enabled = 1
let g:vimtex_fold_sections = ["part", "chapter", "section", "subsection",
            \ "subsubsection", "paragraph", "subparagraph"]

Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_resolve_symlinks = 1

Plug 'mbbill/undotree'
nnoremap U :UndotreeToggle<CR>

if has("nvim") || has("python3")
    Plug 'neomake/neomake'
    autocmd BufWritePost * Neomake
    let g:neomake_open_list = 2
    let g:neomake_list_height = 3

    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1

    if !exists('g:deoplete#omni#input_patterns')
        let g:deoplete#omni#input_patterns = {}
    endif
    let g:deoplete#omni#input_patterns.tex = '\\(?:'
                \ .  '\w*cite\w*(?:\s*\[[^]]*\]){0,2}\s*{[^}]*'
                \ . '|\w*ref(?:\s*\{[^}]*|range\s*\{[^,}]*(?:}{)?)'
                \ . '|hyperref\s*\[[^]]*'
                \ . '|includegraphics\*?(?:\s*\[[^]]*\]){0,2}\s*\{[^}]*'
                \ . '|(?:include(?:only)?|input)\s*\{[^}]*'
                \ . '|\w*(gls|Gls|GLS)(pl)?\w*(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
                \ . '|includepdf(\s*\[[^]]*\])?\s*\{[^}]*'
                \ . '|includestandalone(\s*\[[^]]*\])?\s*\{[^}]*'
                \ . '|usepackage(\s*\[[^]]*\])?\s*\{[^}]*'
                \ . '|documentclass(\s*\[[^]]*\])?\s*\{[^}]*'
                \ .')'
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
set foldlevelstart=0
set foldnestmax=10
set foldmethod=indent
set modelines=1
nnoremap <SPACE> za
" }}}

" {{{ General
let g:tex_flavor = 'latex'

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
set formatoptions=crqnj
set backspace=indent,eol,start
set path+=**

set shiftwidth=4
set shiftround

set linebreak                   " Don't wrap words by default
set wrap
set nolist
set textwidth=80
set wrapmargin=0
set colorcolumn=+1

set history=1000

set fillchars=vert:│            " vertical box-drawing character

set expandtab
set copyindent
set preserveindent
set tabstop=4
set softtabstop=0
set shiftwidth=4
set list
set listchars=tab:»\ ,extends:»

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
set visualbell t_vb=                    " Disable the bell
set nodigraph                           " Enable input of special characters by combining two characters
set noerrorbells                        " Disable error bells
set shortmess=at                        " Abbreviate and truncate messages when necessary
set matchpairs=(:),[:],{:},<:>          " Highlight matching parens
set comments=b:#,:%,fb:-,n:>,n:)
set pumheight=7                         " Completion menu

if has("mouse")
    set mouse=a
endif

set tags=./tags;,tags;
" }}}

" {{{ Search
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
else
    set grepprg=grep\ -nH\ $*
endif

nnoremap <leader>K :silent! grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
" }}}

" {{{ Functions and Commands
function! StripWhitespace()
    let w = winsaveview()
    %s/\s\+$//e
    call winrestview(w)
endfunction

command! StripWhitespace silent! call StripWhitespace()

function! Reindent()
    let w = winsaveview()
    normal gg=G
    call winrestview(w)
endfunction

nnoremap <leader>= :call Reindent()<CR>
" }}}

" {{{ Autocmd
if has("autocmd")
    " Load indentation rules according to detected filetype.
    filetype plugin indent on

    augroup autosave
        autocmd!
        autocmd FocusLost,WinLeave   * silent! wa
        autocmd FocusGained,BufEnter * silent! !
    augroup END

    autocmd FileType gitcommit,markdown,tex,txt setlocal spell spelllang=en_us

    augroup enter_esc
        autocmd!
        autocmd BufReadPost quickfix nnoremap <buffer> <Esc>    :q<CR>
        autocmd CmdWinEnter *        nnoremap <buffer> <Esc>    :q<CR>
        autocmd FileType    netrw    nnoremap <buffer> <Esc>    :e #<CR>
    augroup END

    augroup fast_esc
        autocmd!
        autocmd InsertEnter * set timeoutlen=500
        autocmd InsertLeave * set timeoutlen=1000
    augroup END

    " Convert tabs to spaces when reading file
    augroup convert
        autocmd!
        autocmd BufReadPost  * if index(blacklist, &ft) < 0 | silent! undojoin | silent! retab! &shiftwidth
    augroup END

    let blacklist=['markdown', 'diff', 'gitcommit', 'unite', 'qf', 'help']
    autocmd BufWritePre * if index(blacklist, &ft) < 0 | retab! | StripWhitespace

    " Show trailing whitespace
    augroup whitespace
        autocmd!
        autocmd VimEnter,WinEnter * match whitespace /\s\+$/
    augroup END
endif
" }}}

" {{{ Statusline
set statusline=
set statusline+=%1*%3v                     "virtual column number
set statusline+=\ %<\%F\                   "full path
set statusline+=%m                         "modified flag
set statusline+=%r                         "read only flag
set statusline+=%=%l                       "current line
set statusline+=/%L                        "total lines
" }}}

" {{{ Key Remaps
inoremap jf <esc>
inoremap fj <esc>
inoremap JF <esc>
inoremap FJ <esc>

nnoremap , :
vnoremap , :
nnoremap : ,
vnoremap : ,

nnoremap j gj
nnoremap k gk

nnoremap <Down> ddp
nnoremap <Up> ddkP

inoremap <C-e> <Esc>A
inoremap <C-a> <Esc>I

vnoremap Q gw
nnoremap Q gqap

inoremap {<cr> {<cr>}<c-o>O
inoremap [<cr> [<cr>]<c-o>O
inoremap (<cr> (<cr>)<c-o>O

nnoremap <leader>W :w !sudo tee > /dev/null %<CR><CR>

" Very magic mode, global replace, ask for confirmation
nnoremap <leader>/ :%s/\v/gc<Left><Left><Left>

"Sort selection on a line
vnoremap <F2> d:execute 'normal i' . join(sort(split(getreg('"'))), ' ')<CR>
" }}}

" {{{ Spelling
" Toggle spelling with F10 key:
nnoremap <F10> :set spell!<CR><Bar>:echo "Spell Check: " . strpart("OffOn", 3 * &spell, 3)<CR>
set spellfile=~/.vim/spellfile.add

" Highlight spelling correction:
highlight SpellBad  term=reverse     ctermbg=12 gui=undercurl guisp=Red
highlight SpellCap  term=reverse     ctermbg=9  gui=undercurl guisp=Orange
highlight SpellRare term=reverse     ctermbg=13 gui=undercurl guisp=Magenta
highlight SpellLocale term=underline ctermbg=11 gui=undercurl guisp=Yellow
set sps=best,10
" }}}

" {{{ Colors
highlight normal                ctermbg=black   ctermfg=white
highlight nontext               ctermbg=black   ctermfg=gray

highlight whitespace            ctermbg=red     ctermfg=red

highlight NeomakeErrorSign      ctermbg=red
highlight NeomakeWarningSign    ctermbg=magenta
highlight NeomakeMessageSign    ctermbg=yellow
highlight NeomakeInfoSign       ctermbg=blue

highlight NeomakeError          ctermbg=red
highlight NeomakeWarning        ctermbg=magenta
highlight NeomakeMessage        ctermbg=yellow
highlight NeomakeInfo           ctermbg=blue

highlight Pmenu                 ctermbg=white   ctermfg=black
highlight PmenuSel              ctermbg=green   ctermfg=black
" }}}

" vim:foldmethod=marker
