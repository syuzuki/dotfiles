filetype off
filetype plugin indent off

let mapleader = ' '

let s:dein_dir = stdpath('cache') .. '/dein'
let s:dein_repo = 'github.com/Shougo/dein.vim'
let s:dein_repo_dir = s:dein_dir .. '/repos/' .. s:dein_repo

" Install dein.vim
if !isdirectory(s:dein_dir)
    echo 'Installing dein.vim...'
    let s:dein_repo_url = 'https://' .. s:dein_repo
    execute '!git clone' s:dein_repo_url s:dein_repo_dir
endif

" Load plugins
let &runtimepath = s:dein_repo_dir . ',' . &runtimepath
if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)
    call dein#load_toml(expand('<sfile>:h') . '/dein.toml')
    call dein#end()
    call dein#save_state()
endif

" Install plugins
if dein#check_install()
    call dein#install()
endif

function! s:highlight_ideographicspace() abort
    highlight link IdeographicSpace Visual
    match IdeographicSpace /\%u3000/
endfunction

augroup config
    autocmd!
    autocmd ColorScheme * call s:highlight_ideographicspace()
augroup end

lua <<EOF
    vim.cmd [[
        augroup config_statusline
            autocmd!
            autocmd ColorScheme * call v:lua.statusline_colorscheme()
        augroup end
    ]]

    _G.statusline_colorscheme = function()
        local function get_color(hl, color)
            return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), color)
        end

        local guibg_c = get_color('StatusLine', 'bg#')
        local guibg_nc = get_color('StatusLineNC', 'bg#')
        local function highlight(name, guifg_hl)
            local guifg = get_color(guifg_hl or name, 'fg#')

            local function def(name, guibg)
                vim.cmd('highlight StatusLine' .. name .. ' guifg=' .. guifg .. ' guibg=' .. guibg)
            end

            def(name, guibg_c)
            def(name .. 'NC', guibg_nc)
        end

        highlight('DiagnosticError')
        highlight('DiagnosticWarn')
        highlight('DiagnosticInfo')
        highlight('DiagnosticHint')

        highlight('GitSignsBranch', 'GitGutterChangeDelete')

        highlight('GitSignsAdd')
        highlight('GitSignsChange')
        highlight('GitSignsDelete')

        local devicons = require'nvim-web-devicons'
        devicons.set_up_highlights()
        for _, data in pairs(devicons.get_icons()) do
            if data.name ~= nil then
                highlight('DevIcon' .. data.name)
            end
        end
    end

    _G.statusline = function()
        return '%{%v:lua.statusline_impl(' .. vim.fn.winnr() .. ')%}'
    end

    _G.statusline_impl = function(current_winnr)
        local winnr = vim.fn.winnr()
        local active = winnr == current_winnr
        local hl_suffix = active and '' or 'NC'
        local left = ''
        local right = ''

        local function hl(name)
            name = name or ''
            local suffix = active and '' or 'NC'
            return '%#StatusLine' .. name .. suffix .. '#'
        end

        local function append_left(str)
            if str == nil then
                return
            end

            if left ~= '' then
                left = left .. ' '
            end
            left = left .. str
        end

        local function append_right(str)
            if str == nil then
                return
            end

            if right ~= '' then
                right = ' ' .. right
            end
            right = str .. right
        end

        -- Mode
        local mode = vim.fn.mode()
        local mode_highlights = {
            n = 'Normal',
            v = 'Visual',
            V = 'Visual',
            ['\022'] = 'Visual',
            s = 'Select',
            S = 'Select',
            ['\019'] = 'Select',
            i = 'Insert',
            R = 'Replace',
            c = 'Command',
            r = 'Command',
            ['!'] = 'Command',
            t = 'Terminal',
        }
        local mode_highlight
        if active and mode_highlights[mode] then
            mode_highlight = hl('Mode' .. mode_highlights[mode])
        else
            mode_highlight = hl()
        end
        mode_str = mode_highlight .. '  ' .. hl()

        -- Flags
        local flags = ''
        if vim.bo.filetype == 'help' then
            flags = flags .. '[Help]'
        end
        if vim.bo.readonly then
            flags = flags .. '[RO]'
        end
        if not vim.bo.modifiable then
            flags = flags .. '[-]'
        elseif vim.bo.modified then
            flags = flags .. '[+]'
        end
        if flags == '' then
            flags = nil
        end

        -- Filetype
        local ft_icon, ft_icon_hl = require'nvim-web-devicons'.get_icon(
            vim.fn.expand('%:t'), vim.fn.expand('%:e'))
        local ft_icon = ft_icon and ft_icon .. ' ' or ''
        local filetype = hl(ft_icon_hl) .. ft_icon .. hl() .. vim.bo.filetype

        -- Info
        info = ''
        if vim.bo.fileencoding ~= '' then
            info = vim.bo.fileencoding
        else
            info = vim.o.encoding
        end
        if vim.bo.bomb then
            info = info .. ' '
        end
        if vim.bo.fileformat == 'dos' then
            info = info .. ' '
        elseif vim.bo.fileformat == 'unix' then
            info = info .. ' '
        elseif vim.bo.fileformat == 'mac' then
            info = info .. ' '
        end

        -- Column
        local line = vim.fn.getline('.')
        local cols_bytes = vim.fn.strlen(line)
        local cols_width = vim.fn.strdisplaywidth(line)
        local column = '%c%V/' .. cols_bytes ..
            (cols_width ~= cols_bytes and '-' .. cols_width or '')

        -- Diagnostics
        local diag = ''
        for _, kind in ipairs { 'Error', 'Warn', 'Info', 'Hint' } do
            local severity = vim.diagnostic.severity[string.upper(kind)]
            local n = #vim.diagnostic.get(0, { severity = severity })
            local icon = vim.fn.sign_getdefined('DiagnosticSign' .. kind)[1].text
            if n > 0 then
                diag = diag .. hl('Diagnostic' .. kind) .. icon .. n
            end
        end
        if diag == '' then
            diag = nil
        else
            diag = diag .. hl()
        end

        -- Gitsigns
        local gitbranch = nil
        local gitdiff = ''
        if vim.b.gitsigns_status_dict ~= nil then
            if vim.b.gitsigns_status_dict.head ~= nil then
                gitbranch = hl('GitSignsBranch') .. ' ' ..
                    vim.b.gitsigns_status_dict.head .. hl()
            end

            if vim.b.gitsigns_status_dict.added ~= nil and
                vim.b.gitsigns_status_dict.added > 0 then
                gitdiff = gitdiff .. hl('GitSignsAdd') .. '+' ..
                    vim.b.gitsigns_status_dict.added
            end
            if vim.b.gitsigns_status_dict.changed ~= nil and
                vim.b.gitsigns_status_dict.changed > 0 then
                gitdiff = gitdiff .. hl('GitSignsChange') .. '~' ..
                    vim.b.gitsigns_status_dict.changed
            end
            if vim.b.gitsigns_status_dict.removed ~= nil and
                vim.b.gitsigns_status_dict.removed > 0 then
                gitdiff = gitdiff .. hl('GitSignsDelete') .. '-' ..
                    vim.b.gitsigns_status_dict.removed
            end
        end
        if gitdiff == '' then
            gitdiff = nil
        else
            gitdiff = gitdiff .. hl()
        end

        -- Left
        append_left(mode_str)
        append_left('%f')
        append_left(flags)
        append_left(gitbranch)
        append_left(gitdiff)
        append_left(diag)

        -- Right
        append_right(mode_str)
        append_right('%p%%')
        append_right(column)
        append_right('%l/%L')
        append_right(info)
        append_right(filetype)

        return left .. ' %= ' .. right
    end
EOF

set modeline
set signcolumn=yes
set fileencodings=utf-8,cp932,euc-jp,utf-16le
set nofixendofline
set autoindent smartindent
set tabstop=4 shiftwidth=0 expandtab
set scrolloff=3
set ignorecase smartcase noincsearch hlsearch nowrapscan
set wildmode=longest:full,full wildignorecase
set ttimeout ttimeoutlen=10
set splitbelow splitright
set clipboard=unnamed
set autoread
set termguicolors
set list listchars=tab:»-,trail:␣,nbsp:%
set statusline=%!v:lua.statusline()

noremap <C-e> 3<C-e>
noremap <C-y> 3<C-y>

noremap fj f<C-k>j
noremap Fj F<C-k>j
noremap tj t<C-k>j
noremap Tj T<C-k>j

noremap gK K
nnoremap Y y$
nnoremap / /\v

nnoremap <silent> - <Cmd>split<CR>
nnoremap <silent> <bar> <Cmd>vsplit<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <M-h> <C-w>H
nnoremap <M-j> <C-w>J
nnoremap <M-k> <C-w>K
nnoremap <M-l> <C-w>L

nnoremap <M--> <C-w>=
nnoremap <M-w> <C-w>c

nnoremap <silent> <M-d> <Cmd>bp<CR><Cmd>bd #<CR>
nnoremap <silent> <M-D> <Cmd>bp<CR><Cmd>bd! #<CR>
nnoremap <silent> <M-u> <Cmd>nohlsearch<CR>
nnoremap <silent> <M-s> <Cmd>w<CR>
nnoremap <silent> <M-q> <Cmd>qa<CR>
nnoremap <silent> <M-Q> <Cmd>qa!<CR>
nnoremap <M-z> zz

xnoremap <silent> * y/\V<C-r>"<CR>
xnoremap <M-z> zz

inoremap <C-e> <C-o>3<C-e>
inoremap <C-y> <C-o>3<C-y>
inoremap <C-z> <C-o>zz

cnoremap <expr> <CR> wildmenumode() ? '<C-y>' : '<CR>'
cnoremap <expr> <Esc> wildmenumode() ? '<C-e>' : '<C-c>'
cnoremap <expr> <Up> wildmenumode() ? '<C-p>' : '<Up>'
cnoremap <expr> <Down> wildmenumode() ? '<C-n>' : '<Down>'

cabbrev <expr> h (getcmdtype() ==# ':' && getcmdline() ==# 'h') ? 'vert h' : 'h'
cabbrev <expr> m (getcmdtype() ==# ':' && getcmdline() ==# 'm') ? 'vert Man' : 'm'

digraph jj 106   " j

digraph js 12288 " '　'(\u3000, ideographic space)
digraph j! 65281 " ！
digraph j? 65311 " ？
digraph j, 12289 " 、
digraph j. 12290 " 。
digraph j< 65292 " ，
digraph j> 65294 " ．
digraph j: 65306 " ：
digraph j; 65307 " ；
digraph j- 12540 " ー
digraph j~ 12316 " 〜
digraph j/ 12539 " ・

digraph j( 65288 " （
digraph j) 65289 " ）
digraph j[ 12300 " 「
digraph j] 12301 " 」
digraph j{ 12302 " 『
digraph j} 12303 " 』

digraph j0 65296 " ０
digraph j1 65297 " １
digraph j2 65298 " ２
digraph j3 65299 " ３
digraph j4 65300 " ４
digraph j5 65301 " ５
digraph j6 65302 " ６
digraph j7 65303 " ７
digraph j8 65304 " ８
digraph j9 65305 " ９

filetype plugin indent on
syntax enable
