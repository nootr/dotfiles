# bashrc by Joris Hartog

# Only execute this file if it's an interactive shell
[ -z "$PS1" ] && return

# Set locale settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set preferred editor
export EDITOR=vim

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

# Please don't Python without virtualenv
show_virtual_env() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}

# Password generator
function pwgen {
  HENKIE=12
  if [[ $1 =~ ^[0-9]+$ ]]; then
    HENKIE=$1
  fi
  base64 /dev/urandom | head -c $HENKIE | tr -d '/'
  echo
}

# Simple alias for something I do way too often
function peek() {
  sudo less /home/$1/.bash_history
}

function _peek_complete() {
  # Tab-autocomplete for the peek() function
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  _suggestions=$(ls /home)
  COMPREPLY=( $(compgen -W "${_suggestions}" -- ${cur}) )

  return 0
}

complete -F _peek_complete peek

# Implement autocomplete as root
_root_complete()
{
  # Generates autocomplete suggestions for paths as
  # a sudo user, so that root directories can be tab-
  # completed.
  #
  # Author: jhartog

  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  _suggestions=$(echo -n "${cur}" | sudo python -c """
import sys, os

pwd = sys.argv[1]

# Parse relative and absolute path
input = sys.stdin.readline()
relative_path = ''
path = pwd
if '/' in input:
  relative_path = input.rsplit('/', 1)[0] + '/'
  path = os.path.abspath(os.path.join(pwd, relative_path))

# Fetch content and output list
if os.path.isdir(path):
  content_raw = os.listdir(path)
  content = [relative_path + x for x in content_raw]
  sys.stdout.write(' '.join(content))
  """ "$(pwd)")
  COMPREPLY=( $(compgen -W "${_suggestions}" -- ${cur}) )

  return 0
}

complete -o filenames -F _root_complete ls cd vim less cat grep sudoedit

# Quickly move to a temporary folder
function cdtmp() {
  cd $(mktemp -d)
}

# Work-related stuff
function doei() {
  if [ -z "$1" ]; then
    echo "Usage: doei <IP>"
  else
    sudo fail2ban-client set recidive banip $1
  fi
}

function check_backup() {
  curl --cert ~/.mcollective.d/credentials/certs/B361C7A1.pem \
    --key ~/.mcollective.d/credentials/private_keys/B361C7A1.pem \
    https://styx.prod.hostnetbv.nl/check/$1
  echo
}

function check_parentnode() {
  pqh factsFor -c $1 parentnode
  echo
}

function _known_hosts_complete() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  _suggestions=$(awk '{ print $1 }' ~/.ssh/known_hosts)
  COMPREPLY=( $(compgen -W "${_suggestions}" -- ${cur}) )

  return 0
}

complete -F _known_hosts_complete check_backup check_parentnode

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
  NC="\[\033[m\]"

  PROMPT="${DARK_GRAY}[\u@\h ${LIGHT_GRAY}\W${DARK_GRAY}]${RED}\$(parse_git_branch)${NC}"

  if [ "${EXITSTATUS}" -eq 0 ]; then
    PS1="${PROMPT}${GREEN}\$ ${NC}"
  else
    PS1="${PROMPT}${RED}\$ ${NC}"
  fi
  PS2="> "
}

PROMPT_COMMAND=generate_prompt

# Add homefolder/bin to PATH
export PATH="$PATH:~/bin"
