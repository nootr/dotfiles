# bashrc by Joris Hartog

# Only execute this file if it's an interactive shell
[ -z "$PS1" ] && return

# Set locale settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Please don't Ruby without rbenv
if [ -x "$(command -v rbenv)" ]; then
    eval "$(rbenv init -)"
fi

# Colors for clarity
RESET="\[\033[0;m\]"
GREY="\[\033[1;30m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
LIGHT_BLUE="\[\033[1;34m\]"

# Gotta know where you are.. stats!
function jtop() {
    DISK_USAGE=`df -Ph / | grep -v Filesystem |awk '{print $5}' | grep -Eo '[0-9]*'`
    echo -en "${GREY}┌─${LIGHT_BLUE}Disk usage${GREY}─────────┐             "
    echo -en "${GREEN}`date`${GREY}\n│${GREEN}"
    for i in 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100; do
	if [ "$DISK_USAGE" -gt "$i" ]; then
	    echo -n "#"
	else
	    echo -n " "
	fi
    done
    echo -en "${GREY}│\n└────────────────────┘\n${LIGHT_BLUE}`w`${RESET}\n"
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

# And a nice, clear, table-flippin' prompt
LINE="${GREY}----------------------------------------------------------------${RESET}\n"
RETURN_STATUS="if [ \$? -eq 0 ]; then echo '${GREEN}┏━┓'; else echo '${RED}(╯°□°）╯︵ ┻━┻'; fi"

PROMPT_PREFIX="${LINE}\`${RETURN_STATUS}\` ${BLUE}\`hostname\`:${LIGHT_BLUE}\w${RED}"
PROMPT_SUFFIX="${GREEN} » ${RESET}"

export PS1="$PROMPT_PREFIX\`parse_git_branch\`$PROMPT_SUFFIX"

# Everything done? Welcome the user with statistics! top? nah.. htop? nah.. gtop? no! JTOP!
jtop
