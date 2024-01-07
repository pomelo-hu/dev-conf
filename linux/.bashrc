# color name
reset_all='\[\033[0m\]'
bold='\[\033[1m\]'
under_lined='\[\033[4m\]'
black='\[\033[30m\]'
red='\[\033[31m\]'
green='\[\033[32m\]'
yellow='\[\033[33m\]'
blue='\[033[34m\]'
magenta='\[\033[35m\]'
cyan='\[\033[36m\]'
white='\[\033[37m\]'
defalut='\[\033[39m\]'


# OS name
OS=$(uname -s)


# confirm color prompt
case "$TERM" in
    xterm*|konsole*|rxvt*) color_prompt='yes';;
esac
color_prompt='yes'


# git prompt
function _prompt_git()
{
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ ${#branch} -ne 0 ]; then
        local s_work='\033[31m●'
        local s_cache='\033[31m●'
        if ! git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' &> /dev/null && \
          git diff --no-ext-diff --quiet &> /dev/null; then
            s_work='\033[32m●'
        fi
        if git diff --no-ext-diff --cached --quiet &> /dev/null; then
            s_cache='\033[32m●'
        fi
        if [ "${color_prompt}" == 'yes' ]; then
            echo -e "\033[1;37m<\033[34m${branch}${s_work}${s_cache}\033[37m>\033[0m"
        else
            echo -e "<${branch}>"
        fi
    fi
}


# PS1
if [ "${color_prompt}" == 'yes' ]; then
    PROMPT_PREFIX_ROOT="${bold}${red}! ${reset_all}"
    PROMPT_PREFIX_USER="${bold}${cyan}% ${reset_all}"
    PROMPT_INFO="${bold}${white}[${green}\u${yellow}@${magenta}\h${reset_all}:${under_lined}\w${reset_all}${bold}${white}]${reset_all}"
    PROMPT_NEWLINE="${reset_all}\n${reset_all}"
    PROMPT_SUFFIX_ROOT="${bold}${red}\\$ ${reset_all}"
    PROMPT_SUFFIX_USER="${bold}${cyan}\\$ ${reset_all}"
    if [ $UID -eq 0 ]; then
        PS1="${PROMPT_PREFIX_ROOT}${PROMPT_INFO}${PROMPT_NEWLINE}${PROMPT_SUFFIX_ROOT}"
    else
        PS1="${PROMPT_PREFIX_USER}${PROMPT_INFO}\$(_prompt_git)${PROMPT_NEWLINE}${PROMPT_SUFFIX_USER}"
    fi
else
    #PS1='☁ [\u@\h:\w]$(_prompt_git)\n➜ '
    #PS1='☘ [\u@\h:\w]$(_prompt_git)\n♪ '
    if [ $UID -eq 0 ]; then
        PS1='! [\u@\h:\w]\n\$ '
    else
        PS1='% [\u@\h:\w]$(_prompt_git)\n\$ '
    fi
fi


# shopt
shopt -s checkwinsize
shopt -s cmdhist
shopt -s expand_aliases
shopt -s extglob
shopt -s extquote
shopt -s histappend
shopt -s lithist
shopt -s histreedit
shopt -s histverify
shopt -s interactive_comments


# history
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=30000
# export HISTTIMEFORMAT="%F "
export HISTCONTROL='ignorespace:erasedups'
# export HISTIGNORE='ls:ll:ls -alh:pwd:clear:history'
export PROMPT_COMMAND='history -a'
set -o history


# rename rm
function _rm_back()
{
    /bin/mv --backup=t $@ $HOME/.Trash/
}
if [ "${OS}" == 'Linux' ]; then
    alias rm=_rm_back
elif [ "${OS}" == 'Darwin' ]; then
    alias rm='trash -F'   # mac
fi


function _clean_trash()
{
    read -p 'clean .Trash? (y or n) ' confirm
    [ "${confirm}" == 'y' ] || [ "${confirm}" == 'Y' ] && /bin/rm -rf $HOME/.Trash/*
}
alias clean-trash=_clean_trash


# tmux
function _tmux_new()
{
    local tmux_cmd='command tmux' # command cancels all alias.
    if [ $# -gt 0 ]; then
        ${tmux_cmd} $@
    else
        ${tmux_cmd} attach
        if [ $? -ne 0 ]; then
            ${tmux_cmd} new-session
        fi
    fi
}
alias tmux=_tmux_new


# alias
alias sh='/bin/bash'
if [ "${OS}" == 'Linux' ]; then
    alias ls='ls -F --color=auto'  # linux
elif [ "${OS}" == 'Darwin' ]; then
    alias ls='ls -FG'  # mac
fi
alias ll='ls -Alh'
alias la='ls -A'
alias l='ls -Clh'
alias mv='/bin/mv -i'
alias cp='/bin/cp -i'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias vi='vim'
test -f $HOME/.alias && . $HOME/.alias


# static link library
[ -z "${BASE_LIBRARY_PATH}" ] && export BASE_LIBRARY_PATH="$LIBRARY_PATH"
export LIBRARY_PATH="${BASE_LIBRARY_PATH}"

# dynamic link library
[ -z "${BASE_LD_LIBRARY_PATH}" ] && export BASE_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${BASE_LD_LIBRARY_PATH}"

# env path
[ -z "${BASE_PATH}" ] && export BASE_PATH="$HOME/.bin:$HOME/bin:$PATH"
export PATH="${BASE_PATH}"

