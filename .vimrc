" Wat zit je in mijn vimrc te kijken?!
" xoxo jhartog

syntax on
filetype plugin indent on

set number
set linebreak
set showbreak=+++
set textwidth=80
set showmatch
set visualbell

set hlsearch
set smartcase
set ignorecase
set incsearch

set autoindent
set shiftwidth=2
set smartindent
set smarttab
set tabstop=2
set softtabstop=0
set expandtab

set undolevels=1000
set backspace=indent,eol,start

" Highlight trailing spaces
highlight ExtraWhitespace ctermbg=blue guibg=blue
match ExtraWhitespace /\s\+$/

set ruler