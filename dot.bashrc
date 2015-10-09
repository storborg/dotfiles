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
export CFLAGS="-Qunused-arguments -I/usr/X11/include -I/usr/X11/include/freetype2"
export CPPFLAGS="-Qunused-arguments"

export LDFLAGS="-L/usr/X11/lib"

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
export PATH=/brew/bin:/brew/sbin:/usr/bin:/usr/sbin:/bin:/sbin

# If any of these dirs add them in this order.
for d in ~/devel/bin ~/bin ~/local/bin ~/external/adk/sdk/tools ~/external/adk/sdk/platform-tools /Applications/Hugin/Hugin.app/Contents/MacOS;
do
    [ -e $d ] && export PATH=$PATH:$d
done

# Add /usr/local dirs to the beginning so they take precedence.
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

case "$platform" in
    Darwin)
        export PATH=$PATH:/usr/X11/bin:$EC2_HOME/bin:/usr/local/mysql/bin
        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
        # this is for macports
        #export PATH=$PATH:/opt/local/bin:/opt/local/sbin
        ;;
    Linux)
        ;;
esac

if [ -e /usr/local/share/npm/bin ];
then
    export PATH=/usr/local/share/npm/bin:$PATH
fi

if [ -e /usr/local/mysql ];
then
    export PATH=/usr/local/mysql/bin:$PATH
fi

if [ -e /usr/local/gcc-arm-none-eabi ];
then
    export PATH=/usr/local/gcc-arm-none-eabi/bin:$PATH
fi

if [ -e /Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin ];
then
    export PATH=/Applications/Arduino.app/Contents/Java/hardware/tools/avr/bin:$PATH
fi

#export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/Users/scott/local/gnuradio/build/lib/pkgconfig
#export PATH=$PATH:/Users/scott/local/gnuradio/build/bin

# Set up virtualenvwrapper.
if [ -e /usr/local/bin/virtualenvwrapper.sh ];
then
    export WORKON_HOME=~/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh

    # Activate the py34 virtualenv, if it exists.
    if [ -e $WORKON_HOME/py34 ];
    then
        workon py34
    fi
elif [ -e /var/sw/py34 ];
then
    source /var/sw/py34/bin/activate
elif [ -e /var/sw/pylons27 ];
then
    source /var/sw/pylons27/bin/activate
fi

# Run this file each time python starts up.
export PYTHONSTARTUP=~/.pythonrc.py

####################### Cross-Platform Apache Aliases ########################

# These aliases help avoid confusion: some platforms have sudo, some don't,
# some use apachectl, some use apache2ctl, etc.

if [[ $(which apachectl) ]]
then
    apache_prefix="apachectl"
else
    if [[ $(which apache2ctl) ]]
    then
        apache_prefix="apache2ctl"
    fi
fi

if [ $apache_prefix ]
then
    if [ $(id -u) -ne 0 ]
    then
        apache_prefix="sudo $apache_prefix"
    fi
    
    alias sar="$apache_prefix restart"
    alias sag="$apache_prefix graceful"
    alias sac="$apache_prefix configtest"
    alias sas="$apache_prefix stop"
fi

############################### Common Aliases ###############################

# Alias for cocoa vim.
#alias cvim='open -a Vim'

# Override everything to macvim
alias cvim=mvim
alias gvim=mvim

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"

alias gist='git status'
alias f='finger'
alias fuckoff='logout'
alias logthefuckout='logout'
alias term='xterm -fg white -bg black'
alias fixit='git checkout HEAD~1 && sag'
alias ms='mysql -uroot'
alias msdump='mysqldump -uroot'

alias psr='paster serve --reload'
alias psa='paster setup-app'
alias ppo='paster populate'
alias pui='paster update-images'

alias mcflush='echo flush_all | nc 127.0.0.1 11211'
alias mcstatus='echo stats | nc 127.0.0.1 11211'

alias webserver='python -m SimpleHTTPServer'

alias nt=nosetests

alias grep='GREP_COLOR="1;37;41" LANG=C grep --color=auto'

alias notify='/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier'

alias ocean='play -q -c 2 -n synth brownnoise band -n 1600 1500 tremolo .1 30'

############################## Prompt Settings ###############################

# Update the terminal window title with user@hostname:dir even when
# logged into a remote machine (xterm, Terminal.app, etc).
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'

# Tab complete in sudo.
complete -cf sudo

# Check for terminal color support.
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
		    ps1_username=" \[\e[31;1m\]\u#\[\e[0m\] "
		else
		    # You are a normal user, set blue color prompt with $.
		    ps1_username=" \[\e[36;1m\]\u$\[\e[0m\] "
		fi
	    
	    # Combine prompt string.
	    export PS1="\[$ps1_hostname:\[\e[32;1m\]\w\[\e[37;1m\]]$ps1_username"

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

