filetype plugin indent on

let s:cache_home = !empty($XDG_DATA_HOME) ? $XDG_DATA_HOME : expand('~/.local/share')
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo = '/Shougo/dein.vim'

" Install dein.vim
if !isdirectory(s:dein_dir)
    echo 'Installing dein.vim...'
    let s:dein_installer = 'https://raw.githubusercontent.com' . s:dein_repo . '/master/bin/installer.sh'
    call system('curl ' . shellescape(s:dein_installer) . ' | sh -s -- ' . shellescape(s:dein_dir))
endif

" Load plugins
let s:dein_repo_dir = s:dein_dir . '/repos/github.com' . s:dein_repo
let &runtimepath = s:dein_repo_dir . ',' . &runtimepath
if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)
    call dein#load_toml(expand('<sfile>:h') . '/dein.toml')
    call dein#end()
    call dein#save_state()
    call dein#call_hook('source')
endif
" call dein#call_hook('source')
augroup config_dein
    autocmd!
    autocmd VimEnter * call dein#call_hook('post_source')
augroup end

" Install plugins
if dein#check_install()
    call dein#install()
endif

augroup config
    autocmd!
    autocmd BufWinEnter *.txt if &buftype == 'help' | wincmd L | endif
    autocmd ColorScheme * highlight link IdeographicSpace Visual
    autocmd BufNew,BufRead * match IdeographicSpace /\%u3000/
augroup end

syntax on
colorscheme lucius
LuciusBlack

set modeline
set fileencodings=utf-8,cp932,euc-jp
set autoindent smartindent
set tabstop=4 shiftwidth=0 expandtab
set scrolloff=3
set ignorecase smartcase noincsearch hlsearch nowrapscan
set wildmode=list:longest,full wildignorecase
set ttimeout ttimeoutlen=10
set clipboard=unnamed
set autoread
set termguicolors
set pumblend=20
set completeopt=menuone,noinsert
set list listchars=tab:»-,trail:␣,nbsp:%

let mapleader = ' '

noremap <C-e> 3<C-e>
noremap <C-y> 3<C-y>

noremap fj f<C-k>j
noremap Fj F<C-k>j
noremap tj t<C-k>j
noremap Tj T<C-k>j

noremap gK K
nnoremap Y y$
nnoremap / /\v

nnoremap <silent> - :<C-u>split<CR>
nnoremap <silent> <bar> :<C-u>vsplit<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
if has('nvim')
    nnoremap <M-h> <C-w>H
    nnoremap <M-j> <C-w>J
    nnoremap <M-k> <C-w>K
    nnoremap <M-l> <C-w>L

    nnoremap <M--> <C-w>=
    nnoremap <M-w> <C-w>c

    nnoremap <silent> <M-d> :<C-u>bp<cr>:bd #<cr>
    nnoremap <silent> <M-D> :<C-u>bd<cr>
    nnoremap <silent> <M-u> :<C-u>nohlsearch<cr>
    nnoremap <silent> <M-s> :<C-u>w<cr>
    nnoremap <silent> <M-q> :<C-u>qa<cr>
    nnoremap <silent> <M-Q> :<C-u>qa!<cr>
else
    nnoremap <Esc> <Nop>
    nnoremap <Esc>h <C-w>H
    nnoremap <Esc>j <C-w>J
    nnoremap <Esc>k <C-w>K
    nnoremap <Esc>l <C-w>L

    nnoremap <Esc>w <C-w>c
    nnoremap <Esc>- <C-w>=

    nnoremap <silent> <Esc>d :<C-u>bp<CR>:bd #<CR>
    nnoremap <silent> <Esc>D :<C-u>bd<CR>
    nnoremap <silent> <Esc>u :<C-u>nohlsearch<CR>
    nnoremap <silent> <Esc>s :<C-u>w<CR>
    nnoremap <silent> <Esc>q :<C-u>qa<CR>
    nnoremap <silent> <Esc>Q :<C-u>qa!<CR>
endif

vnoremap <silent> * y/\V<C-r>"<CR>

inoremap <C-e> <C-o>3<C-e>
inoremap <C-y> <C-o>3<C-y>
inoremap <C-z> <C-o>zz
inoremap <C-p> <Up>
inoremap <C-n> <Down>
inoremap <expr> <C-g> pumvisible() ? '<C-e>' : ''

cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
" cnoremap <C-d> <Delete>
cnoremap <C-d> <Del>
cnoremap <expr> / stridx('/?', getcmdtype()) >= 0 ? '\/' : '/'

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
