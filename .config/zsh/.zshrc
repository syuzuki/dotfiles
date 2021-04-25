() {
    if type rustup >/dev/null; then
        local rust_site_functions=~/.rustup/toolchains/"${$(rustup show active-toolchain)%% *}"/share/zsh/site-functions
        fpath=(${rust_site_functions} ${fpath})
    fi
}
fpath=(${ZDOTDIR}/function ${fpath})

HISTFILE=${XDG_DATA_HOME:-~/.local/share}/zsh/history
HISTSIZE=10000
SAVEHIST=1000000

ZPLUG_HOME=${XDG_DATA_HOME:-~/.local/share}/zsh/zplug
if [[ ! -d ${ZPLUG_HOME} ]]; then
    echo "\e[32mInstalling zplug...\e[m"
    git clone --depth 1 https://github.com/zplug/zplug ${ZPLUG_HOME}
fi

# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=7'
ENHANCD_DIR=${XDG_DATA_HOME:-~/.local/share}/zsh/enhancd

source ${ZPLUG_HOME}/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug 'zsh-users/zsh-completions'
# use develop branch until PR #402 is merged to master branch
# https://github.com/zsh-users/zsh-autosuggestions/issues/398
# https://github.com/zsh-users/zsh-autosuggestions/pull/402
zplug 'zsh-users/zsh-autosuggestions', at:'develop'
zplug 'zdharma/fast-syntax-highlighting', defer:2
zplug 'b4b4r07/enhancd', use:'init.sh'
zplug 'mollifier/zload', use:'{,_}zload', lazy:true

zplug '/usr/share/git/completion', from:local

zplug check || zplug install
zplug load

# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=7'

# source /usr/share/fzf/completion.zsh
type pip >/dev/null && eval "$(pip completion --zsh)"

CORRECT_IGNORE_FILE='.*'

() {
    local user_name
    local color
    if [[ ${SSH_CONNECTION} != '' ]]; then
        user_name=" ${USER}@${HOST}"
        # color=yellow
        color=11
    elif [[ ${SUDO_COMMAND} != '' ]]; then
        user_name=" ${USER}"
        # color=yellow
        color=11
    else
        user_name=
        # color=blue
        color=12
    fi
    # ((${UID} == 0)) && color=red
    ((${UID} == 0)) && color=9

    local nest=$(repeat $((SHLVL - 1)) echo -n '>')

    PROMPT="%F{${color}}%B%y${user_name}${nest} %#%b%f "
    RPROMPT="%F{${color}}%B[%~]%b%f"
    PROMPT2="%F{${color}}%B%_ >%b%f "
    PROMPT3="%F{${color}}%B?#%b%f "
    PROMPT4="%F{${color}}%B+%N:%i >%b%f "
    SPROMPT="%F{green}%B'%R' -> '%r' [nyae]?%b%f "

    terminal_title="\e]2;${$(tty)#/dev/}${user_name}${nest}\a"
}

autoload -Uz add-zsh-hook

set-terminal-title() {
    echo -n ${terminal_title}
}
add-zsh-hook precmd set-terminal-title

autoload -Uz fzf-jobs.zsh; fzf-jobs.zsh
autoload -Uz zargs

alias l='ls -AhFv --color=always' ll='l -l' c='cd' c.='c ..' c-='c -'
alias v="${VISUAL}" vr='v -R' le="${PAGER}"
alias g='git'
alias j='fzf-jobs' f='fzf-fg' b='fzf-bg'
alias mv='mv -i' cp='cp -ir' md='mkdir -p'
alias rd='rmdir'
alias df='df -h' free='free -h' du='du -hs'
alias d='git diff --no-index --' vd='v -dR'
alias man='man'
alias t='bsdtar' tt='t -tf' tx='t -xf' tc='t -a -cf' tu='t -uf'
alias rg='rg -pS --hidden'
alias ma='make' ca='cargo'
alias sudo='sudo --preserve-env=EDITOR,VISUAL,PAGER,SHLVL,ZDOTDIR '
alias cal='cal -3'
alias rsync='rsync -av'
alias ip='ip --color'
alias dk='docker'
alias -g L='| less' G='| rg' S='| perl -pE' C='| wc' O='| sort' U='| sort -u'
alias -g X='| xargs' H='| head' T='| tail' D='| xxd'
alias -g GG='| grep' SS='| sed'
mc() {
    md "$@"
    cd "$@"
}
ssht() {
    ssh "$@" -t tmux new-session -A
}

[[ ${TERM} == alacritty ]] && eval $(TERM=xterm-256color dircolors -b) || eval $(dircolors -b)
# for kitty, modify bold font to 16-color colde
export LS_COLORS="$(echo "${LS_COLORS}" | perl -pE 's/00;//g, s/01;3(\d)/9\1/g, s/3(\d);01/9\1/g')"

bindkey -v
KEYTIMEOUT=1

# zmodload zsh/terminfo
# typeset -A keys
# keys[up]=${terminfo[kcuu1]}
# keys[down]=${terminfo[kcud1]}
# keys[right]=${terminfo[kcuf1]}
# keys[left]=${terminfo[kcub1]}
# keys[home]=${terminfo[khome]}
# keys[end]=${terminfo[kend]}
# keys[pageup]=${terminfo[kpp]}
# keys[pagedown]=${terminfo[knp]}
# keys[delete]=${terminfo[kdch1]}
# keys[insert]=${terminfo[kich1]}
# if [[ ${TERM} =~ '^xterm|^alacritty$' ]]; then # fix wrong terminfo
#     keys[up]=$'\e[A'
#     keys[down]=$'\e[B'
#     keys[right]=$'\e[C'
#     keys[left]=$'\e[D'
#     keys[home]=$'\e[H'
#     keys[end]=$'\e[F'
# elif [[ ${TERM} =~ '^tmux' ]]; then # fix wrong terminfo
#     keys[up]=$'\e[A'
#     keys[down]=$'\e[B'
#     keys[right]=$'\e[C'
#     keys[left]=$'\e[D'
# fi

alias run-help &>/dev/null && unalias run-help
autoload -Uz run-help
autoload -Uz run-help-sudo

autoload -Uz fzf-select-history
zle -N fzf-select-history
autoload -Uz vi-push-line
zle -N vi-push-line

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^F' vi-forward-char
bindkey '^B' vi-backward-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^D' delete-char
# bindkey "${keys[up]}" history-beginning-search-backward
# bindkey "${keys[down]}" history-beginning-search-forward
# bindkey "${keys[home]}" beginning-of-line
# bindkey "${keys[end]}" end-of-line
# bindkey "${keys[delete]}" delete-char
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^G' send-break
bindkey '^R' fzf-select-history
bindkey '^U' kill-whole-line
bindkey '^?' backward-delete-char
bindkey '^[q' push-line
bindkey '^[h' run-help

bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward
# bindkey -Mvicmd "${keys[up]}" history-beginning-search-backward
# bindkey -Mvicmd "${keys[down]}" history-beginning-search-forward
# bindkey -Mvicmd "${keys[home]}" beginning-of-line
# bindkey -Mvicmd "${keys[end]}" end-of-line
# bindkey -Mvicmd "${keys[delete]}" delete-char
bindkey -M vicmd '^[[A' history-beginning-search-backward
bindkey -M vicmd '^[[B' history-beginning-search-forward
bindkey -M vicmd '^[[H' vi-first-non-blank
bindkey -M vicmd '^[[F' vi-end-of-line
bindkey -M vicmd '^[[3~' vi-delete-char
bindkey -M vicmd '^[OA' history-beginning-search-backward
bindkey -M vicmd '^[OB' history-beginning-search-forward
bindkey -M vicmd '^[OH' vi-first-non-blank
bindkey -M vicmd '^[OF' vi-end-of-line
bindkey -M vicmd '^[[1~' vi-first-non-blank
bindkey -M vicmd '^[[4~' vi-end-of-line
bindkey -M vicmd '^G' send-break
bindkey -M vicmd '^R' fzf-select-history
bindkey -M vicmd '^U' vi-change-whole-line
bindkey -M vicmd '^[q' vi-push-line
bindkey -M vicmd '^[h' run-help

autoload -Uz select-bracketed
autoload -Uz select-quoted
zle -N select-bracketed
zle -N select-quoted

for m in visual viopp; do
    for c in {a,i}${(s::)^:-'()[]{}<>'}; do
        bindkey -M $m $c select-bracketed
    done
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

zmodload zsh/complist

bindkey -M menuselect '^P' up-history
bindkey -M menuselect '^N' down-history

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' use-cache true
zstyle ':completion:*' use-path ${XDG_CACHE_HOME:-~/.cache}/zsh/compcache

# Completion for sudo.vim
# execute after compinit
_my_vim() {
    local word=${words[${CURRENT}]}
    if [[ ${word} =~ '^sudo:' ]]; then
        compset -P 'sudo:'
        _files
    else
        _vim
    fi
}
compdef _my_vim vim
compdef _my_vim nvim

# Options
# Changing Directories

# Completion
setopt complete_in_word
setopt glob_complete
unsetopt list_ambiguous
setopt list_packed

# Expansion and Globbing
setopt extended_glob
setopt glob_dots
# setopt glob_subst # for enhancd
setopt magic_equal_subst
unsetopt nomatch
setopt numeric_glob_sort

# History
setopt extended_history
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history

# Initialisation

# Input/Output
setopt correct
# setopt correct_all
unsetopt flow_control
setopt ignore_eof
setopt interactive_comments
setopt print_exit_value
setopt rm_star_silent

# Job Control
# setopt monitor

# Prompting

# Scripts and Functions

# Shell Emulation

# Shell State

# Zle

stty -ixon

# `test` fails without file
[[ ${ZDOTDIR}/.zshrc.zwc -nt ${ZDOTDIR}/.zshrc ]] || zcompile ${ZDOTDIR}/.zshrc

[[ ${LESSKEY} -nt ${XDG_CONFIG_HOME:-~/.config}/less/lesskey ]] || lesskey ${XDG_CONFIG_HOME:-~/.config}/less/lesskey
