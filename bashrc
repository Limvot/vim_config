if [ -f /etc/bash_completion ]; then
	    . /etc/bash_completion
fi


xhost +local:root > /dev/null 2>&1

complete -cf sudo

shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s expand_aliases
shopt -s extglob
shopt -s histappend
shopt -s hostcomplete
shopt -s nocaseglob

export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL=ignoreboth

alias ls='echo "You Should Be Using LISP"; ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias grep='grep --color=tty -d skip'
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
#alias tmux='tmux -2'                      # automatically support 256 colors
alias lg='java -jar ~/Downloads/Logisim2.jar'
alias np='nano PKGBUILD'
alias dir='netcat lu-serve.gatech.edu 105'

alias o='xdg-open'
alias desk='mosh -p 8765 --ssh="ssh -p 8766" nathan@room409.xyz'
alias serv='mosh -p 8768 --ssh="ssh -p 8767" nathan@room409.xyz'
alias pi='mosh -p 9001 --ssh="ssh -p 9000" pi@room409.xyz'
alias cloud='ssh 104.238.179.164'

alias l='i3lock; systemctl suspend'

#alias nixc='vim /home/nathan/vim_config/configuration.nix'
alias nixc='vim /etc/nixos/configuration.nix'
#alias nixc='sudo vim /etc/nixos/configuration.nix'
alias nixr='sudo nixos-rebuild switch'
alias nixu='sudo nixos-rebuild switch --upgrade'


alias algo='cd ~/currentSemester/CS3510'
alias ai='cd ~/currentSemester/CS3600'
alias comp='cd ~/currentSemester/CS4240'
alias os='cd ~/currentSemester/CS3210'
alias ta='cd ~/currentSemester/TA2CS110'

alias minecraft='java -jar ~/minecraft/Minecraft.jar'
alias nightly='~/firefox/firefox'
setxkbmap -layout us -option ctrl:nocaps

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;

      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# prompt
PS1='[\u@\h \W]\$ '
BROWSER=/usr/bin/xdg-open

# JS aliases
alias jscleanmk="cd .. && rm -rf build-debug && mkdir build-debug && autoconf-2.13 && cd build-debug && ../configure --enable-debug --disable-optimize && make -j4"
alias jstest="python2 ../tests/jstests.py ./dist/bin/js"

export PATH=$PATH:~/bin:~/.gem/ruby/2.1.0/bin:~/Nim/bin:/opt/android-sdk/android-sdk-linux/tools

export PATH=/home/nbraswell6/packages/installed/bin:$PATH
export LD_LIBRARY_PATH=/home/nbraswell6/packages/installed/lib:$LD_LIBRARY_PATH
