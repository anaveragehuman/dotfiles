#!/bin/bash
# This file is sourced by all *interactive* bash shells on most distributions on startup,
# including some apparently interactive shells such as scp and rcp that can't tolerate any output.

# Test for an interactive shell.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi


# Use bash completion if available
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
[[ -e /etc/bash/bashrc.d/bash_completion.sh ]] && source /etc/bash/bashrc.d/bash_completion.sh


for file in ~/.{aliases,exports,functions}; do
    if [ -r "$file" ] && [ -f "$file" ]; then
        source "$file";
    fi
done

# Enable colors for ls, etc.
for file in {"${HOME}/.dir_colors","/etc/DIR_COLORS"}; do
    if [[ -f "$file" ]]; then
        eval "$(dircolors -b "$file")"
        break
    fi
done


shopt -s autocd                                 # Name of directory executed as if it was argument to `cd`
shopt -s cdable_vars                            # `cd` into values of variables
shopt -s cdspell                                # Check and correct slight spelling errors
shopt -s checkjobs                              # List status of jobs before exiting
shopt -s checkwinsize                           # Check the window size after every command
shopt -s cmdhist                                # Save all lines of multi-line command to same history entry
shopt -s dirspell                               # Check and correct slight spelling errors
shopt -s dotglob                                # Include files starting with `.` in pathname expansion
shopt -s extglob                                # Extended pattern matching features
shopt -s globstar                               # `**` matches all files and directories/subdirectories
shopt -s histappend                             # Append to history file instead of overwriting
shopt -s no_empty_cmd_completion                # Do not search for completions if line is empty


unset HISTFILE
export HISTCONTROL="erasedups:ignoreboth"
export HISTFILESIZE=
export HISTIGNORE="?:??:ls:[bf]g:exit:pwd:clear:mount:umount:history"
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "

# Unbind some keys
stty stop undef
stty start undef
stty -ixon

# {{{ Prompt
for file in {"/usr/lib/git-core/git-sh-prompt","/usr/share/git/git-prompt.sh"}; do
    if [ -e "$file" ]; then
        source "$file"
        break
    fi
done

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"


PROMPT_COMMAND=_prompt
_prompt() {
    local EXIT=$?
    local RED="\\[$(tput setaf 1)\\]"
    local GREEN="\\[$(tput setaf 2)\\]"
    #local YELLOW="\\[$(tput setaf 3)\\]"
    local BLUE="\\[$(tput setaf 4)\\]"
    local MAGENTA="\\[$(tput setaf 5)\\]"
    local CYAN="\\[$(tput setaf 6)\\]"
    local RESET="\\[$(tput sgr0)\\]"
    local BOLD="\\[$(tput bold)\\]"
    PS1=${BOLD}

    # Show exit code if not 0
    if [[ $EXIT != 0 ]]; then
        PS1+="${RED}$EXIT "
    fi

    # Show hostname if root; show hostname and username if ssh'd in; show username if != login name
    if [[ "$(id -u)" -eq 0 ]]; then
        PS1+="${RED}\\h "
    elif [ -v SSH_CLIENT ] || [ -v SSH_TTY ]; then
        PS1+="${BLUE}\\u${RESET}${BOLD}@${BLUE}\\h "
    elif [[ "$(logname 2> /dev/null)" != "$(id -un)" ]]; then
        PS1+="${BLUE}\\u "
    fi

    PS1+="${CYAN}$(__git_ps1 '(%s) ')"

    # Show virtualenv info if we are in one
    if [[ -v VIRTUAL_ENV ]]; then
        PS1+="${MAGENTA}[$(basename "$VIRTUAL_ENV")] "
    fi

    # Show number of jobs if there are any (active or suspended)
    if [[ -n "$(jobs -p)" ]]; then
        PS1+="${BLUE}\\jj "
    fi

    # Current working directory
    PS1+="${GREEN}\\W${RESET} \\$ "
}
# }}}

# vim:foldmethod=marker
