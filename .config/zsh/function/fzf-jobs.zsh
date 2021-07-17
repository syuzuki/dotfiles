autoload -Uz zmathfunc
zmathfunc

_fzf_jobs_list_suspended=()
_fzf_jobs_list_running=()

-fzf-jobs-update() {
    local js_susp=()
    local js_run=()
    local i v
    for i v in "${(@kv)jobstates}"; do
        if [[ "${v}" == suspended:* ]]; then
            js_susp+=("${i}")
        else
            js_run+=("${i}")
        fi
    done

    _fzf_jobs_list_suspended=("${(@)_fzf_jobs_list_suspended:*js_susp}")  # _fzf_jobs_list_suspended &= js_susp
    _fzf_jobs_list_suspended+=("${(@)js_susp:|_fzf_jobs_list_suspended}") # _fzf_jobs_list_suspended |= js_susp

    _fzf_jobs_list_running=("${(@)_fzf_jobs_list_running:*js_run}")  # _fzf_jobs_list_running &= js_run
    _fzf_jobs_list_running+=("${(@)js_run:|_fzf_jobs_list_running}") # _fzf_jobs_list_running |= js_run
}

fzf-jobs() {
    local jobnum_width=0
    local state_width=0
    local text_width=0
    local i
    for i in "${(@Oa)_fzf_jobs_list_suspended}" "${(@Oa)_fzf_jobs_list_running}"; do
        ((jobnum_width = max(jobnum_width, ${#i})))
        ((state_width = max(state_width, ${#jobstates[${i}]%%:*})))
        ((text_width = max(text_width, ${#jobtexts[${i}]})))
    done

    for i in "${(@Oa)_fzf_jobs_list_suspended}" "${(@Oa)_fzf_jobs_list_running}"; do
        local text="${jobtexts[${i}]}"

        print -nr -- "[${(l:jobnum_width:: :)i}]"
        print -nr -- " ${(r:state_width:: :)jobstates[${i}]%%:*}"
        print -nr -- "  ${text}"
        if [[ ! "${jobdirs[${i}]}" -ef . ]]; then
            print -nr -- "${(l:text_width - ${#text}:: :)}"
            print -nr -- "  @${jobdirs[${i}]/#"${HOME}"/~}"
        fi
        print
    done
}

-fzf-jobs-select() {
    local j="$(fzf-jobs | fzf --prompt='Job > ' --layout='reverse' --exit-0 --select-1)"

    if [[ ! -z "${j}" ]]; then
        echo "${(R)${(R)j#\[}%\]*}"
    fi
}

fzf-fg() {
    local j="$(-fzf-jobs-select)"

    if [[ ! -z "${j}" ]]; then
        # move i to the last of _fzf_jobs_list_suspended
        _fzf_jobs_list_suspended=("${(@)_fzf_jobs_list_suspended:#${j}}")
        _fzf_jobs_list_suspended+=("${j}")

        fg %"${j}"
    fi
}

fzf-bg() {
    local j="$(-fzf-jobs-select)"

    if [[ ! -z "${j}" ]]; then
        # move i to the last of _fzf_jobs_list_running
        _fzf_jobs_list_running=("${(@)_fzf_jobs_list_running:#${j}}")
        _fzf_jobs_list_running+=("${j}")

        bg %"${j}"
    fi
}

add-zsh-hook preexec -fzf-jobs-update
