export PATH=/usr/local/bin:"${PATH}":~/bin:~/src/bin:~/.cargo/bin:~/.local/bin
export LESSKEY="${XDG_CONFIG_HOME:-${HOME}/.config}"/less/less FZF_DEFAULT_OPTS='--height=10'
export HOSTALIASES=~/.hostaliases
export PAGER=less
export EDITOR='nvim -O'
export VISUAL="${EDITOR}"
export MAKEFLAGS="-j$(($(cat /proc/cpuinfo | grep '^processor' | wc -l) + 1))"

[[ -e ~/.profile.local ]] && source ~/.profile.local
