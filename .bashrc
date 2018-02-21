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
RESET="\[\e[0;m\]"
GREY="\[\e[1;30m\]"
RED="\[\e[0;31m\]"
GREEN="\[\e[0;32m\]"
YELLOW="\[\e[0;33m\]"
BLUE="\[\e[0;34m\]"
LIGHT_BLUE="\[\e[1;34m\]"

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
LINE="${GREY}------------------------------------------------------------${RESET}\n"
RETURN_STATUS="if [ \$? -eq 0 ]; then echo '${GREEN}┏━┓'; else echo '${RED}(╯°□°）╯︵ ┻━┻'; fi"

PROMPT_PREFIX="${LINE}\`${RETURN_STATUS}\` ${BLUE}\`hostname\`:${LIGHT_BLUE}\w${RED}"
PROMPT_SUFFIX="${GREEN} » ${RESET}"

export PS1="$PROMPT_PREFIX\`parse_git_branch\`$PROMPT_SUFFIX"
