function lightline#colorscheme#flatten(p) abort
    let p = {}

    for mode in keys(a:p)
        let p[mode] = {}
        for where in keys(a:p[mode])
            let p[mode][where] = []
            for colors in a:p[mode][where]
                let new_colors = [colors[0][0], colors[1][0], colors[0][1], colors[1][1]]
                if len(colors) >= 3
                    call add(new_colors, colors[2])
                endif
                call add(p[mode][where], new_colors)
            endfor
        endfor
    endfor

    return p
endfunction
