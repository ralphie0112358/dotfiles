# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000000
HISTFILESIZE=10000000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Function to assemble the Git parsingart of our prompt.
git_prompt ()
{
    GIT_DIR=`git rev-parse --git-dir 2>/dev/null`
    if [ -z "$GIT_DIR" ]; then
        return 0
    fi
    GIT_HEAD=`cat $GIT_DIR/HEAD`
    GIT_BRANCH=${GIT_HEAD##*/}
    if [ ${#GIT_BRANCH} -eq 40 ]; then
        GIT_BRANCH="(no branch)"
    fi
    STATUS=`git status --porcelain`
    if [ -z "$STATUS" ]; then
        git_color="${c_git_clean}"
    else
        echo -e "$STATUS" | grep -q '^ [A-Z\?]'
        if [ $? -eq 0 ]; then
            git_color="${c_git_unstaged}"
        else
            git_color="${c_git_staged}"
        fi
    fi
    echo "[$git_color$GIT_BRANCH$c_reset]"
}

venv_prompt() 
{
    # Get virtual Env
    if test -z "$VIRTUAL_ENV" ; then
        echo ''
    else
        # Strip out the path and just leave the env name
        echo "(${VIRTUAL_ENV##*/})"
    fi
}


if [ "$color_prompt" = yes ]; then
    PROMPT_COMMAND="$PROMPT_COMMAND PS1=\"\$(venv_prompt)\[\e]0;${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(git_prompt)\$\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(git_prompt)\$ \" ;"
else
    PROMPT_COMMAND="$PROMPT_COMMAND PS1=\"\$(venv_prompt)\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h:\w\$(git_prompt)\$\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$(git_prompt)\$ \" ; "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# To enter to a running docker container, given its name or id
function d_enter {
    docker exec -it $1 bash
}

# Show the ip address of a docker container
alias d_ip='docker inspect --format='\''{{.NetworkSettings.IPAddress}}'\'''
alias d_ip2='docker inspect --format='\''{{.NetworkSettings.Networks.vagrant_default.IPAddress}}'\'''

# Delete all unused docker images
alias d_rmin='docker rmi `docker images --filter="dangling=true" -q`'

# Delete all unused docker containers
alias d_rmn='docker rm `docker ps -a --filter="status=exited" -q`'

alias rmi-none=d_rmin
alias rm-exited=d_rmn

gitkeys() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa_github
}

# what is taking up all my diskspace?
ducks() {
    ls -A | grep -v -e '^\.\.$' |xargs -i du -ks {} |sort -rn |head -56 | awk '{print $2}' | xargs -i du -hs {}
}

# Docker related functions
cfs() { # Containers from string: cfs <string-identifying-container-in-`docker-ps` output> [max_match_count]
    _max_matches=${2:-1}
    _matches=$(docker ps | awk "/$1/{print \$1}" | xargs docker inspect --format '{{ .Name }}' | sed -e 's/^\///')
    # Ensure only $2 max matches
    _match_count=$(wc -w <<< $_matches)
    if [[ $_match_count -lt 1 ]]; then
        # Error, didn't match just one
        echo "ERROR: Failure to match container in docker ps output" 1>&2
        return 1
    elif [[ $_match_count -gt $_max_matches ]]; then
        # Error, didn't match just one
        echo "ERROR: Matched $_match_count containers in docker ps output" 1>&2
        return 1
    else
        echo "$_matches"
        return 0
    fi
}

cip() { # Docker IP(s) from string
    _containers=$(cfs $1 1000)
    if [[ $? -ne 0 ]]; then
        # cfs failure output should suffice
        return 1
    fi
    for _container in $_containers; do
        echo $_container $(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $_container)
    done
}

function d_manhole {
    _container=$(cfs $1)
    if [[ $? -ne 0 ]]; then
        # cfs failure output should suffice
        return 1
    fi
    _check=$(docker exec -ti $_container bash -c 'dpkg -l | grep sshpass')
    if [[ $? -ne 0 ]]; then
        docker exec -ti $_container bash -c 'apt-get update && apt-get install -y sshpass'
    fi
    docker exec -ti $_container bash -c 'sshpass -p adminpw ssh -oStrictHostKeyChecking=no admin@localhost -p 61383'
}

pcurl () { curl $@ | python -m json.tool; }

__END__

alias invoke='env/bin/invoke'
