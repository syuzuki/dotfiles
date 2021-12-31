local wezterm = require 'wezterm';

return {
    font = wezterm.font('Sarasa Nerd Term J'),
    font_size = 9,

    colors = {
        -- Customized RRethy/nvim-base16 decaf
        foreground = '#cccccc', -- base05
        background = '#16161d', -- base00

        cursor_border = '#cccccc', -- base05

        selection_fg = '#cccccc', -- base05
        selection_bg = '#404040', -- base02

        ansi = {
            '#16161d', -- base00
            '#c26b53', -- base08*0.85
            '#91a65b', -- base0b*0.85
            '#cdac63', -- base0a*0.85
            '#7399b5', -- base0d*0.85
            '#c090c6', -- base0e*0.85
            '#91a3c2', -- base0c*0.85
            '#aaaaaa', -- base04
        },
        brights = {
            '#808080', -- base03
            '#e57e62', -- base08
            '#abc46c', -- base0b
            '#f2cb75', -- base0a
            '#88b4d5', -- base0d
            '#e3aaea', -- base0e
            '#abc0e5', -- base0c
            '#cccccc', -- base05
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
