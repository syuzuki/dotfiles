export PATH=/usr/local/bin:"${PATH}":~/bin:~/src/bin:~/.cargo/bin:~/.local/bin
export LESSKEY="${XDG_CONFIG_HOME:-${HOME}/.config}"/less/less FZF_DEFAULT_OPTS='--height=10'
export ZDOTDIR="${XDG_CONFIG_HOME:-${HOME}/.config}"/zsh
export HOSTALIASES=~/.hostaliases
export PAGER=less
if type nvim >/dev/null; then
    export EDITOR='nvim -O'
else
    export EDITOR=vim
fi
export VISUAL="${EDITOR}"
export MAKEFLAGS="-j$(($(cat /proc/cpuinfo | grep '^processor' | wc -l) + 1))"

[[ -e ~/.profile.local ]] && source ~/.profile.local
