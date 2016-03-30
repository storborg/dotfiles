############################## Scott's .bashrc ###############################

# Note that PAGER and EDITOR assignments should be before we check whether or
# not the shell is interactive, so that applications which don't actually
# launch an interactive shell can still check for them.

# less is a great editor, but it doesn't actually edit files.
export PAGER=less
# So we'll use vim for that.
export EDITOR=vim

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
set noclobber

# Use vim keybindings in bash.
set -o vi

# Disable cowsay in ansible.
export ANSIBLE_NOCOWS=1

# This will make clang not die on -mno-fused-madd args, which is necessary for
# a bunch of python shit to install.
#export CFLAGS="-Qunused-arguments -I/usr/X11/include -I/usr/X11/include/freetype2"
#export CPPFLAGS="-Qunused-arguments"
#export LDFLAGS="-L/usr/X11/lib"

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

#export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Base PATH.
export PATH=/usr/bin:/usr/sbin:/bin:/sbin

# If any of these dirs add them in this order.
for d in ~/devel/bin ~/bin ~/local/bin ~/external/adk/sdk/tools ~/external/adk/sdk/platform-tools
do
    [ -e $d ] && export PATH=$PATH:$d
done

# Add /usr/local dirs to the beginning so they take precedence.
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

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

# For Arduino toolchain...
#if [ -e /Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin ];
#then
#    export PATH=/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin:$PATH
#fi

#export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/Users/scott/local/gnuradio/build/lib/pkgconfig
#export PATH=$PATH:/Users/scott/local/gnuradio/build/bin

# Set up virtualenvwrapper.
if [ -e /usr/local/bin/virtualenvwrapper.sh ];
then
    export WORKON_HOME=~/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh

    # Activate the py34 virtualenv, if it exists.
    if [ -e $WORKON_HOME/default35 ];
    then
        workon default35
    fi
fi

# Run this file each time python starts up.
export PYTHONSTARTUP=~/.pythonrc.py

############################### Common Aliases ###############################

# Alias for cocoa vim.
#alias cvim='open -a Vim'

# Override everything to macvim
alias cvim=mvim
alias gvim=mvim

# This should be moved to a global "setup" script along with other git config.
#git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"

alias gist='git status'
alias f='finger'
alias fuckoff='logout'
alias ms='mysql -uroot'
alias msdump='mysqldump -uroot'

alias mcflush='echo flush_all | nc 127.0.0.1 11211'
alias mcstatus='echo stats | nc 127.0.0.1 11211'

alias nt=nosetests
alias lock='gnome-screensaver-command --lock'

alias grep='GREP_COLOR="1;37;41" LANG=C grep --color=auto'

alias ocean='play -q -c 2 -n synth brownnoise band -n 1600 1500 tremolo .1 30'

# Suggested style from https://matt.sh/howto-c
alias cleanup-format='clang-format -style="{BasedOnStyle: llvm, IndentWidth: 4, AllowShortFunctionsOnASingleLine: None, KeepEmptyLinesAtTheStartOfBlocks: false}"'

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
        xterm*|rxvt*)
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

source ~/local/dram/dram.sh
