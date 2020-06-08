" Wat zit je in mijn vimrc te kijken?!
" xoxo jhartog

syntax on
filetype plugin indent on
highlight LineNr          ctermfg=DarkGrey
highlight ColorColumn     ctermbg=235      guibg=#2c2d27
highlight ExtraWhitespace ctermbg=blue     guibg=blue
match ExtraWhitespace /\s\+$/

set list
set listchars=tab:>-
set tabstop=2
set expandtab

set nu
set rnu
set linebreak
set textwidth=80
set colorcolumn=81
set showmatch
set visualbell

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

inoremap jj <esc>

noremap <Up> :echo "Blasphemy! Stop using the arrow keys!"<CR>k
noremap <Down> :echo "Blasphemy! Stop using the arrow keys!"<CR>j
noremap <Left> :echo "Blasphemy! Stop using the arrow keys!"<CR>h
noremap <Right> :echo "Blasphemy! Stop using the arrow keys!"<CR>l

au VimEnter * RainbowParentheses
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
