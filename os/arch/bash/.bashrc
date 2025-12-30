#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    if uwsm check may-start; then
        exec uwsm start hyprland.desktop
    fi
fi

source /usr/share/nvm/init-nvm.sh
