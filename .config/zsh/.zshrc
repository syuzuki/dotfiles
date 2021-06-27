typeset -A ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME:-"${HOME}/.local/share"}/zsh/zinit"
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/bin"
ZINIT[ZCOMPDUMP_PATH]="${XDG_DATA_HOME:-"${HOME}/.local/share"}/zsh/compdump"

if [[ ! -d "${ZINIT[HOME_DIR]}" ]]; then
    echo "\e[32mInstalling Zinit...\e[m"
    git clone --filter=blob:none https://github.com/zdharma/zinit.git "${ZINIT[BIN_DIR]}"
fi

ENHANCD_DIR="${XDG_DATA_HOME:-"${HOME}/.local/share"}/zsh/enhancd"
ZSH_THEME_GIT_PROMPT_PREFIX=''
ZSH_THEME_GIT_PROMPT_SUFFIX=' '
ZSH_THEME_GIT_PROMPT_BRANCH='%F{magenta} '
ZSH_GIT_PROMPT_SHOW_UPSTREAM=symbol
ZSH_GIT_PROMPT_SHOW_STASH=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8,underline'
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()

source "${ZINIT[BIN_DIR]}/zinit.zsh"

zinit wait lucid for \
        'zsh-vi-more/vi-motions' \
    blockf \
        'zsh-users/zsh-completions' \
        'b4b4r07/enhancd' \
        'mollifier/zload' \
    atload'!_zsh_git_prompt_precmd_hook' nocd \
        'woefe/git-prompt.zsh'
zinit wait'0s' lucid atinit'zicompinit; zicdreplay; compdef _my_nvim nvim' for \
        'zdharma/fast-syntax-highlighting'
zinit wait'0x' lucid atload'!_zsh_autosuggest_start' for \
        'zsh-users/zsh-autosuggestions'

if type rustup &>/dev/null; then
    local active_toolchain="$(rustup show active-toolchain)"
    zinit fpath ~/.rustup/toolchains/"${active_toolchain% (default)}"/share/zsh/site-functions
fi
# Completion function generated by `pip` uses old `compctl`, so it should be `source`d
zinit wait lucid has'pip' id-as'pip-completion' atpull'%atclone' run-atpull \
    atclone'pip completion --zsh >pip-completion.plugin.zsh' for \
        'zdharma/null'

zinit fpath "${ZDOTDIR}/completion"
zinit fpath "${ZDOTDIR}/function"

HISTFILE="${XDG_DATA_HOME:-"${HOME}/.local/share"}/zsh/history"
HISTSIZE=10000
SAVEHIST=1000000

REPORTTIME=3

CORRECT_IGNORE_FILE='.*'

() {
    local user= host= color=12
    if [[ -n "${SSH_CONNECTION:-}" ]]; then
        user=true
        host=true
        color=11
    fi
    if [[ -n "${SUDO_COMMAND:-}" ]]; then
        user=true
        color=11
    fi
    if (( $(id -u) == 0 )); then
        user=true
        color=9
    fi

    PROMPT="%F{${color}}%B${host:+"%M:"}%y${user:+" %n"} ${(l:SHLVL::❯:)}%b%f "
    RPROMPT="%F{${color}}%B[%(1j.⏳%j .)%b%f\$(type gitprompt >&/dev/null && gitprompt)%F{${color}}%B%~]%b%f"
    PROMPT2="%F{${color}}%B%_ ❯%b%f "
    PROMPT3="%F{${color}}%B?#%b%f "
    PROMPT4="%F{${color}}%B+%N:%i ❯%b%f "
    SPROMPT="%F{10}%B'%R' -> '%r' [Nyae]?%b%f "

    terminal_title="${host:+"%M:"}%y${user:+" %n"}"
}

autoload -Uz add-zsh-hook

set-terminal-title() {
    print -P -f '\e]2;%s\a' "${terminal_title}"
}
add-zsh-hook precmd set-terminal-title

autoload -Uz fzf-jobs.zsh; fzf-jobs.zsh
autoload -Uz zargs

alias l='ls -AhFv --color=always' ll='l -l' c='cd' c.='c ..' c-='c -'
alias v="${VISUAL:-nvim}" vr='v -R' le="${PAGER:-less}"
alias g='git'
alias j='fzf-jobs' f='fzf-fg' b='fzf-bg'
alias mv='mv -i' cp='cp -ai' md='mkdir -p'
alias rd='rmdir'
alias df='df -h' free='free -h' du='du -hs'
alias d='git diff --no-index --' vd='v -dR'
alias t='bsdtar' tt='t -tf' tx='t -xf' tc='t -a -cf' tu='t -uf'
alias rg='rg -pS --hidden'
alias ma='make' ca='cargo'
alias sudo='sudo --preserve-env=EDITOR,VISUAL,PAGER,SHLVL,ZDOTDIR '
alias cal='cal -3'
alias rsync='rsync -av'
alias ip='ip --color'
alias dk='docker' va='vagrant'
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

eval "$(TERM="${TERM:/alacritty/xterm-256color}" dircolors -b)"
# Modify bold font to 16-color colde
export LS_COLORS="$(echo "${LS_COLORS}" | perl -pE 's/00;//g, s/01;3(\d)/9\1/g, s/3(\d);01/9\1/g')"

alias run-help &>/dev/null && unalias run-help
autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz run-help-ip
autoload -Uz run-help-openssl
autoload -Uz run-help-sudo

bindkey -v
KEYTIMEOUT=1

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^F' vi-forward-char
bindkey '^B' vi-backward-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^D' delete-char
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

bindkey -a 'k' history-beginning-search-backward
bindkey -a 'j' history-beginning-search-forward
bindkey -a '^[[A' history-beginning-search-backward
bindkey -a '^[[B' history-beginning-search-forward
bindkey -a '^[[H' vi-first-non-blank
bindkey -a '^[[F' vi-end-of-line
bindkey -a '^[[3~' vi-delete-char
bindkey -a '^[OA' history-beginning-search-backward
bindkey -a '^[OB' history-beginning-search-forward
bindkey -a '^[OH' vi-first-non-blank
bindkey -a '^[OF' vi-end-of-line
bindkey -a '^[[1~' vi-first-non-blank
bindkey -a '^[[4~' vi-end-of-line
bindkey -a '^G' send-break
bindkey -a '^R' fzf-select-history
bindkey -a '^U' vi-change-whole-line
bindkey -a '^[q' vi-push-line
bindkey -a '^[h' run-help

autoload -Uz fzf-select-history
zle -N fzf-select-history
autoload -Uz vi-push-line
zle -N vi-push-line

zmodload zsh/complist

bindkey -M menuselect '^P' up-history
bindkey -M menuselect '^N' down-history

zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' use-cache true
zstyle ':completion:*' use-path "${XDG_CACHE_HOME:-"${HOME}/.cache"}/zsh/compcache"

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
setopt glob_subst
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
unsetopt flow_control
setopt ignore_eof
setopt interactive_comments
setopt print_exit_value
setopt rm_star_silent

# Job Control
# setopt monitor

# Prompting
setopt prompt_subst

# Scripts and Functions

# Shell Emulation

# Shell State

# Zle

[[ ${ZDOTDIR}/.zshrc.zwc -nt ${ZDOTDIR}/.zshrc ]] || zcompile ${ZDOTDIR}/.zshrc

[[ "${LESSKEY}" -nt "${XDG_CONFIG_HOME:-"${HOME}/.config"}/less/lesskey" ]] || lesskey "${XDG_CONFIG_HOME:-"${HOME}/.config"}/less/lesskey"
