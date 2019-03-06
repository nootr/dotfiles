# bashrc by Joris Hartog

# Only execute this file if it's an interactive shell
[ -z "$PS1" ] && return

# Set locale settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Set preferred editor
export EDITOR=vim

# Enable bash vi-mode and bind 'jj' instead of ESC
set -o vi
bind '"jj":vi-movement-mode'
bind -r "\e"

# Please don't Ruby without rbenv
if [ -x "$(command -v rbenv)" ]; then
    eval "$(rbenv init -)"
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

# Please don't Python without virtualenv and direnv
show_virtual_env() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
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

# Work-related stuff
function check_backup() {
  curl --cert ~/.mcollective.d/credentials/certs/B361C7A1.pem \
    --key ~/.mcollective.d/credentials/private_keys/B361C7A1.pem \
    https://styx.prod.hostnetbv.nl/check/$1
}

function check_parentnode() {
  pqh factsFor -c $1 parentnode
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

# Gotta know where you are.. stats!
function jtop() {
    RESET="\033[0;m"
    GRAY="\033[1;30m"
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    LIGHT_BLUE="\033[1;34m"

    DISK_USAGE=`df -Ph / | grep -v Filesystem |awk '{print $5}' | grep -Eo '[0-9]*'`
    IPS=`ifconfig | awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ { printf("%s ", $2) }'`
    IPS_LEN=${#IPS}
    SHIFT=$((40 - $IPS_LEN))

    echo -en "${GRAY}┌─${LIGHT_BLUE}Disk usage${GRAY}─────────┐          "
    echo -en "${GREEN}`date`${GRAY}\n│"
    if [ "$DISK_USAGE" -gt "70" ]; then
	echo -en "${RED}"
    else
	echo -en "${GREEN}"
    fi
    for i in 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100; do
	if [ "$DISK_USAGE" -gt "$i" ]; then
	    echo -n "#"
	else
	    echo -n " "
	fi
    done
    echo -en "${GRAY}│"
    for i in $(seq 1 $SHIFT); do
	echo -n " "
    done
    echo -en "${IPS}${GRAY}\n└────────────────────┘${RESET}                   "
    curl --head --max-time 2 curlba.sh &> /dev/null \
      && echo -en " ${GRAY}curlba.sh: ${GREEN}[ONLINE]${RESET}\n" \
      || echo -en "${GRAY}curlba.sh: ${RED}[OFFLINE]${RESET}\n"
    echo -n "                                   "
    curl --head --max-time 2 wingkeememes.nl &> /dev/null \
      && echo -en " ${GRAY}wingkeememes.nl: ${GREEN}[ONLINE]${RESET}\n" \
      || echo -en " ${GRAY}wingkeememes.nl: ${RED}[OFFLINE]${RESET}\n"
}

# More git, more better
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

function parse_git_dirty {
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

function generate_prompt {
  EXITSTATUS="$?"

  GRAY="\[\033[1;30m\]"
  RED="\[\033[0;31m\]"
  GREEN="\[\033[0;32m\]"
  YELLOW="\[\033[0;33m\]"
  BLUE="\[\033[0;34m\]"
  LIGHT_BLUE="\[\033[1;34m\]"
  BOLD="\[\033[1m\]"
  OFF="\[\033[m\]"

  HOST="\h"
  USER="\u"
  DIR="\w"
  DATE="\d"
  TIME="\t"

  LINE="${GRAY}-------------------------------------------------------------\n${OFF}"
  PROMPT="${LIGHT_BLUE}${TIME} ${DATE} [${USER}@${HOST}] ${RED}$(parse_git_branch)${OFF}"

  if [ "${EXITSTATUS}" -eq 0 ]
  then
    PS1="$(show_virtual_env)${LINE}${PROMPT}\n${DIR} ${GREEN}»${OFF} "
  else
    PS1="$(show_virtual_env)${LINE}${PROMPT}\n${DIR} ${RED}»${OFF} "
  fi

  PS2="${BOLD}>${OFF} "
}

PROMPT_COMMAND=generate_prompt
eval "$(direnv hook bash)"

export PATH="$PATH:~/bin"

# Everything done? Welcome the user with statistics! top? nah.. htop? nah.. gtop? no! JTOP!
jtop

if command -v todo > /dev/null; then
  todo list
fi
