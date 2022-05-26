"""""""""""""""""""""""""""""" My Vim configuration """""""""""""""""""""""""""
"
" Some (custom or default) keybindings:
"
" :cd ... | Change working directory
" :Cd ... | Change working directory and update virtual environment path
" :e ...  | Edit (new) file
"         |
" `       | Open file tree sidebar (NERDTree plugin)
" <tab>   | Open file structure explorer (tagbar plugin)
"         |
" jj      | Enter normal mode
" ;       | Leader
"         |
" ;w j    | Move to window down
" ;w k    | Move to window up
" ;w h    | Move to window left
" ;w l    | Move to window right
"         |
" ;w s    | Split horizontal
" ;w v    | Split vertical
" ;w o    | Open current buffer full-screen
" ;w ;w   | Move to next window
"         |
" ;t      | Open a terminal down
" ;T      | Open a terminal to the right
"         |
" :hide   | Close window without closing buffer
" :bd     | Close window and buffer
" :bn     | Show next buffer
" :bp     | Show previous buffer
" :ls     | List buffers
" :b N    | Show buffer N
"         |
" ;w >    | Increase window to the right by 1 column
" ;w N >  | Increase window to the right by N columns
" ;w <    | Increase window to the left by 1 column
" ;w N <  | Increase window to the left by N columns
" ;w +    | Increase window height by 1 row
" ;w N +  | Increase window height by N rows
" ;w -    | Decrease window height by 1 row
" ;w N -  | Decrease window height by N rows

" Use pathogen for Jedi VIM
execute pathogen#infect()

set splitbelow

syntax on
filetype plugin indent on
highlight LineNr          ctermfg=DarkGrey
highlight ColorColumn     ctermbg=235      guibg=#2c2d27
highlight ExtraWhitespace ctermbg=blue     guibg=blue
match ExtraWhitespace /\s\+$/

autocmd BufRead,BufNewFile *.ilo set filetype=ilo
autocmd BufRead,BufNewFile *.py call Pywrap()
autocmd BufWritePre *.py execute ':Black'
autocmd BufWritePost *.py call flake8#Flake8()

set list
set listchars=tab:>-
set tabstop=2
set expandtab

set nu
set rnu
set showmatch
set visualbell

function! Pywrap()
  " Only wrap lines in Python files. Black enforces 88 chars per line
  set linebreak
  set textwidth=88
  set colorcolumn=89
endfunction

function! Cd(dir)
  " cd into a certain folder and update the PATH accordingly
  execute(":cd " . a:dir)
  let pwd = trim(execute(":pwd"))
  if isdirectory(pwd . "/.venv")
    let $VIRTUAL_ENV = pwd . "/.venv/"
  elseif isdirectory(pwd . "/venv")
    let $VIRTUAL_ENV = pwd . "/venv/"
  endif
endfunction

:command! -complete=file_in_path -nargs=1 Cd :call Cd(<q-args>)

set hlsearch
set smartcase
set ignorecase
set incsearch

set autoindent
set shiftwidth=2
set smartindent

set undolevels=1000
set backspace=indent,eol,start

set clipboard=unnamed

nnoremap d "xd
vnoremap d "xd
nnoremap c "xc
vnoremap c "xc

inoremap jj <esc>

noremap <Up> :echo "Blasphemy! Stop using the arrow keys!"<CR>k
noremap <Down> :echo "Blasphemy! Stop using the arrow keys!"<CR>j
noremap <Left> :echo "Blasphemy! Stop using the arrow keys!"<CR>h
noremap <Right> :echo "Blasphemy! Stop using the arrow keys!"<CR>l

noremap ` :NERDTreeToggle<CR>
noremap <Tab> :TagbarToggle<CR>

let mapleader = ";"

nnoremap <Leader>w <C-w>
tnoremap <Leader>w <C-w>

nnoremap <Leader>t :below terminal<CR>
nnoremap <Leader>T :below vertical terminal<CR>


au VimEnter * RainbowParentheses
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

""" Statusbar

" Status Line Custom
let g:currentmode={
    \ 'n'      : 'Normal',
    \ 'no'     : 'Normal·Operator Pending',
    \ 'v'      : 'Visual',
    \ 'V'      : 'V·Line',
    \ "\<C-V>" : 'V·Block',
    \ 's'      : 'Select',
    \ 'S'      : 'S·Line',
    \ '^S'     : 'S·Block',
    \ 'i'      : 'Insert',
    \ 'R'      : 'Replace',
    \ 'Rv'     : 'V·Replace',
    \ 'c'      : 'Command',
    \ 'cv'     : 'Vim Ex',
    \ 'ce'     : 'Ex',
    \ 'r'      : 'Prompt',
    \ 'rm'     : 'More',
    \ 'r?'     : 'Confirm',
    \ '!'      : 'Shell',
    \ 't'      : 'Terminal'
    \}

set laststatus=2
set noshowmode
set statusline=
set statusline+=%0*\ %n\                                 " Buffer number
set statusline+=%1*\ %<%F%m%r%h%w\                       " File path, modified,
                                                         "  readonly, helpfile,
                                                         "  preview
set statusline+=%3*│                                     " Separator
set statusline+=%2*\ %Y\                                 " FileType
set statusline+=%3*│                                     " Separator
set statusline+=%2*\ %{''.(&fenc!=''?&fenc:&enc).''}     " Encoding
set statusline+=\ (%{&ff})                               " FileFormat (dos/unix)
set statusline+=%=                                       " Right Side
set statusline+=%2*\ col:\ %02v\                         " Colomn number
set statusline+=%3*│                                     " Separator
set statusline+=%1*\ ln:\ %02l/%L\ (%3p%%)\              " Line number / total
                                                         "  lines, percentage of
                                                         "  document
set statusline+=%0*\ %{toupper(g:currentmode[mode()])}\  " The current mode

" Color schemes for each mode
hi User1 ctermfg=007 ctermbg=239 guibg=#4e4e4e guifg=#adadad
hi User2 ctermfg=007 ctermbg=236 guibg=#303030 guifg=#adadad
hi User3 ctermfg=236 ctermbg=236 guibg=#303030 guifg=#303030
hi User4 ctermfg=239 ctermbg=239 guibg=#4e4e4e guifg=#4e4e4e

" vim-signify settings
set updatetime=100
highlight SignColumn ctermbg=NONE cterm=NONE guibg=NONE gui=NONE
highlight SignifySignAdd    ctermfg=green  guifg=#00ff00 cterm=NONE gui=NONE
highlight SignifySignDelete ctermfg=red    guifg=#ff0000 cterm=NONE gui=NONE
highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE
