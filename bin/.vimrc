" Wat zit je in mijn vimrc te kijken?!
" xoxo jhartog

" Use pathogen for Jedi VIM
execute pathogen#infect()

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

noremap <Tab> :NERDTreeToggle<CR> :TagbarToggle<CR>

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
