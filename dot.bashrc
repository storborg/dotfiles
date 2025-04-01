############################## Scott's .bashrc ###############################

# Note that PAGER and EDITOR assignments should be before we check whether or
# not the shell is interactive, so that applications which don't actually
# launch an interactive shell can still check for them.

# less is a great editor, but it doesn't actually edit files.
export PAGER=less
# So we'll use vim for that.
export EDITOR=vim

export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Helps GPG with shell invocations.
export GPG_TTY=`tty`

if [[ $- != *i* ]]; then
    # Shell is non-interactive, return.
    return
fi

# Grab the platform so we can check it later.
platform=`uname`

# Disable ^D for logout.
set -o ignoreeof

# Disable redirect overwrite, so if we 'cat foo > bar' it will only work if
# bar doesn't already exist.
#set noclobber

# Use vim keybindings in bash.
set -o vi

# Disable cowsay in ansible.
export ANSIBLE_NOCOWS=1

# Use lots of jobs in Make
NCPUS=$(grep -c ^process /proc/cpuinfo)
export MAKEFLAGS="-j$NCPUS"

############################# Bash History Stuff #############################

HISTFILESIZE=100000000
HISTSIZE=100000

# Don't add these commands to the history file.
HISTIGNORE="cd:ls:[bf]g:clear:exit"

# Don't put duplicate lines in the history.
export HISTCONTROL=ignoredups

# Append to history rather than overwriting it. This helps make things useful
# when using lots of different terminals.
shopt -s histappend

############################## Initialize Paths ##############################

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Base PATH, with /usr/local first.
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/games

# If any of these dirs exist, add them ahead of /usr/local.
for d in ~/.node_modules_global/bin ~/external/adk/sdk/tools ~/external/adk/sdk/platform-tools /opt/apache-maven-3.6.0/bin ~/.cargo/bin /opt/blender ~/opt/openEMS/bin
do
    [ -e $d ] && export PATH=$d:$PATH
done

export PATH=~/local/dotfiles/bin:$PATH

case "$platform" in
    Darwin)
        export PATH=$PATH:/usr/X11/bin
        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
        ;;
    Linux)
        ;;
esac

# For ARM toolchain...
if [ -e /usr/local/gcc-arm-none-eabi ];
then
    export PATH=/usr/local/gcc-arm-none-eabi/bin:$PATH
fi

# Set up virtualenvwrapper.
if [ -e /usr/share/virtualenvwrapper/virtualenvwrapper.sh ];
then
    export WORKON_HOME=~/.virtualenvs
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

    # Activate the default Python 3.x virtualenv, if it exists.
    if [ -e $WORKON_HOME/default3 ];
    then
        workon default3
    fi
fi

# Run this file each time python starts up.
export PYTHONSTARTUP=~/.pythonrc.py

############################### Common Aliases ###############################

# This should be moved to a global "setup" script along with other git config.
#git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"

alias gist='git status'
alias grep='GREP_COLOR="mt=1;37;41" LANG=C grep --color=auto'

if [[ $platform == "Linux" ]]
then
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'

    alias open='xdg-open'
fi

############################## Prompt Settings ###############################

# Update the terminal window title with user@hostname:dir even when
# logged into a remote machine (xterm, Terminal.app, etc).
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

# Tab complete in sudo.
complete -cf sudo

# Check for terminal color support.
function update_prompt () {
    ps1_extra=$1
    case "$TERM" in
        xterm*|rxvt*|screen.xterm*)
            # This terminal supports colors.
            case "$platform" in
                Darwin)
                    # You are on an OS X machine, so set green hostname.
                    ps1_hostname="\e[37;1m\][\[\e[32;1m\]\h\[\e[37;1m\]"
                    ;;
                Linux)
                    # You are on a Linux machine, set red hostname.
                    ps1_hostname="\e[37;1m\][\[\e[31;1m\]\h\[\e[37;1m\]"
                    ;;
            esac

            if [ $(id -u) -eq 0 ];
            then
                # You are root, set red colour prompt with #.
                ps1_username="\[\e[31;1m\]\u#\[\e[0m\] "
            else
                # You are a normal user, set blue color prompt with $.
                ps1_username="\[\e[36;1m\]\u$\[\e[0m\] "
            fi

            # Combine prompt string.
            export PS1="\[$ps1_hostname:\[\e[32;1m\]\w\[\e[37;1m\]] $ps1_extra $ps1_username"

            # Set ls colorization, use yellow for directories.
            export CLICOLOR=1
            export LSCOLORS=dxfxcxdxbxegedabagacad
            ;;
        *)
            if [ $(id -u) -eq 0 ];
            then
                # You are root, set rootish.
                export PS1="[\h:\w] \u# "
            else
                export PS1="[\h:\w] \u$ "
            fi
            ;;
    esac
}

update_prompt "-"

############################## Package Managers ###############################

# Set up dram.
function deactivate_any_virtualenv () {
    type deactivate >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        deactivate
    fi
}

function dram_hook_preactivate () {
    local dram_name=$1
    local dram_prefix=$2

    deactivate_any_virtualenv
}

function dram_hook_postactivate () {
    local dram_name=$1
    local dram_prefix=$2

    update_prompt $dram_name
}


# Configuration written by dram-install on 2016-08-21 05:51:55.252469 UTC
export DRAM_ROOT=/dram
source $HOME/local/dram/dram/dram.sh

. "$HOME/.local/bin/env"
