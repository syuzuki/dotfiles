local wezterm = require 'wezterm';

return {
    font = wezterm.font('Sarasa Nerd Term J'),
    font_size = 9,

    colors = {
        -- Customized sainnhe/sonokai
        foreground = "#e2e2e3",
        background = "#181819",

        selection_fg = "#e2e2e3",
        selection_bg = "#3b3e48",

        ansi = {
            "#181819",
            "#b64359",
            "#86b161",
            "#c4a855",
            "#64adbe",
            "#9885cf",
            "#4fbea7",
            "#cbcbcc",
        },
        brights = {
            "#78787d",
            "#fc5d7c",
            "#9ed072",
            "#e7c664",
            "#76cce0",
            "#b39df3",
            "#5de0c4",
            "#e2e2e3",
        },
    },
    force_reverse_video_cursor = true,

    enable_tab_bar = false,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },

    use_ime = true,
}
