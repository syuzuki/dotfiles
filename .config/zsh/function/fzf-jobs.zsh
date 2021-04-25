autoload -Uz zmathfunc
zmathfunc

declare -a _fzf_jobs_list_suspended
declare -a _fzf_jobs_list_running

-fzf-jobs-update() {
    local js_susp=()
    local js_run=()
    for i in "${(@k)jobstates}"; do
        if [[ "${jobstates[${i}]}" == suspended:* ]]; then
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
    local js_array=("${(@f)$(jobs -ld | perl -pE 's/^\[(\d+)][\s+-]+/\1\n/; s/^\(pwd : .*\n//')}")
    # 's/^\[(\d+)][\s+-]+(\d+)\s+(\w+)\s+(.*)$/\1\n\2:\3:\4/'
    local ds_array=("${(@f)$(jobs -ld | perl -pE 's/^\[(\d+)][\s+-]+.*$/\1/; s/^\(pwd : (.*)\)$/\1/')}")

    local -A js=()
    local -A ds=()
    if ((${#js_array} >= 2)); then
        js=("${js_array[@]}")
        ds=("${ds_array[@]}")
    fi

    local jobnum_width=1
    local info_width=0
    for i in "${(@Oa)_fzf_jobs_list_suspended}" "${(@Oa)_fzf_jobs_list_running}"; do
        ((jobnum_width = max(jobnum_width, ${#i})))
        ((info_width = max(info_width, ${#js[${i}]})))
    done

    for i in "${(@Oa)_fzf_jobs_list_suspended}" "${(@Oa)_fzf_jobs_list_running}"; do
        jobnum="$(repeat $((jobnum_width - ${#i})) echo -n ' ')${i}"
        info="${js[${i}]}"

        echo -n "[${jobnum}] ${info}"
        if [[ ! "$(eval echo ${ds[${i}]})" -ef . ]]; then
            echo -n "$(repeat $((info_width - ${#info})) echo -n ' ')  @${ds[${i}]}"
        fi
        echo
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

# add-zsh-hook precmd -fzf-jobs-update
add-zsh-hook preexec -fzf-jobs-update
