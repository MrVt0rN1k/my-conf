" =========================
" БАЗА
" =========================
syntax on
set number
set relativenumber
set cursorline
set termguicolors

set ttimeout
set ttimeoutlen=1
set ttyfast
" =========================
" УДОБСТВО
" =========================
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent

set clipboard=unnamedplus

set ignorecase
set smartcase

set incsearch
set hlsearch

" Быстрый выход из insert
inoremap jk <Esc>

" Очистка поиска
nnoremap <leader>h :nohlsearch<CR>
