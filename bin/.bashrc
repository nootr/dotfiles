# bashrc by Joris Hartog

export PATH="$HOME/bin:$PATH"

# Only execute this file if it's an interactive shell
[ -z "$PS1" ] && return

# Set preferred editor
export EDITOR=nvim
alias vim=$EDITOR

# Use `thefuck` if installed
command -v thefuck > /dev/null && eval "$(thefuck --alias)"

# Enable bash vi-mode, keep '.' to insert last argument and bind 'jj' for
# vi-mode.
set -o vi
bind '"jj":vi-movement-mode'
bind -m vi-command ".":insert-last-argument
bind -m vi-command "v":""

# Please don't Ruby without rbenv
if [ -x "$(command -v rbenv)" ]; then
    eval "$(rbenv init -)"
fi

# Please don't Mac without homebrew
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Please don't Python without virtualenv
show_virtual_env() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}

# Please don't perl without plenv
if [ -x "$(command -v plenv)" ]; then
  eval "$(plenv init -)"
  export PATH="$HOME/.plenv/bin:$PATH"
fi

# Password generator
function pwgen {
  HENKIE=12
  if [[ $1 =~ ^[0-9]+$ ]]; then
    HENKIE=$1
  fi
  base64 /dev/urandom | head -c $HENKIE | tr -d '/'
  echo
}

# Quickly move to a temporary folder
function cdtmp() {
  cd $(mktemp -d)
}

# Git status functions for prompt
function parse_git_branch() {
    BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ ! "${BRANCH}" == "" ]
    then
	STAT=`parse_git_dirty`
	echo "(${STAT}${BRANCH})"
    else
	echo ""
    fi
}

function parse_git_dirty() {
    status=`git status 2>&1 | tee`
    dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
    ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    if [ "${renamed}" == "0" ]; then
    	bits=">${bits}"
    fi
    if [ "${ahead}" == "0" ]; then
    	bits="*${bits}"
    fi
    if [ "${newfile}" == "0" ]; then
    	bits="+${bits}"
    fi
    if [ "${untracked}" == "0" ]; then
    	bits="?${bits}"
    fi
    if [ "${deleted}" == "0" ]; then
	bits="x${bits}"
    fi
    if [ "${dirty}" == "0" ]; then
    	bits="!${bits}"
    fi
    echo "$bits"
}

function lolbash() {
  if command -v lolcat > /dev/null; then
    lolcat <<< "Welcome to lolbash!"
    function generate_prompt() {
      PS1="$(lolcat -f <<< "$ ")"
    }
    PROMPT_COMMAND=generate_prompt
    exec 1> >(lolcat >&2)
  fi
}

# Generate bash prompt
function generate_prompt() {
  EXITSTATUS="$?"
  DARK_GRAY="\[\033[1;30m\]"
  LIGHT_GRAY="\[\033[0;37m\]"
  RED="\[\033[0;31m\]"
  GREEN="\[\033[0;32m\]"
  BLUE="\[\033[0;34m\]"
  NC="\[\033[m\]"

  if [ "${PYCHARM}" == "1" ]; then
    PROMPT="${LIGHT_GRAY}[\u@\h \W]${RED}\$(parse_git_branch)${NC}"
  else
    PROMPT="${DARK_GRAY}[\u@\h ${LIGHT_GRAY}\W${DARK_GRAY}]${RED}\$(parse_git_branch)${NC}"
  fi

  if [ "${EXITSTATUS}" -eq 0 ]; then
    PS1="${PROMPT}${GREEN}\$ ${NC}"
  else
    PS1="${PROMPT}${RED}\$ ${NC}"
  fi
  PS2="${PROMPT}${BLUE}> ${NC}"
}

PROMPT_COMMAND=generate_prompt

# Source z
source ~/bin/z.sh

# Docker compose alias
alias docker-arch-ps='for i in `docker ps --format "{{.Image}}"` ; do docker image inspect $i --format "$i -> {{.Architecture}} : {{.Os}}" ;done'
alias dc="docker compose"

# Poetry!
source ~/.poetry/env
export PATH="/Users/jhartog/.local/bin:$PATH"

# Python 3.10!
export PATH="/opt/homebrew/opt/python@3.10/bin:$PATH"

# Rust
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Mac M1 issue
# https://github.com/celery/celery/issues/7324
# https://stackoverflow.com/questions/50168647/multiprocessing-causes-python-to-crash-and-gives-an-error-may-have-been-in-progr
OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# Go
export PATH="$HOME/go/bin:$PATH"
