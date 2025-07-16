set number
syntax on
filetype indent plugin on

map <Tab> <C-W>W:cd %:p:h<CR>:<CR>

" Set the maximum line length to 79
"highlight OverLength ctermbg=gray ctermfg=black guibg=#00bfff
"match OverLength /\%80v.\+/


set cpoptions+=$
set cursorline

" Map Switch between tabs
map <C-l> :tabn<CR>
map <C-h> :tabp<CR>

" Map Switch between screens
map <S-l> <C-w>l<CR>
map <S-h> <C-w>h<CR>
map <S-j> <C-w>j<CR>
map <S-k> <C-w>k<CR>

" make backspaces more powerfull
"set backspace=indent,eol,start

" Run python code in vim
nnoremap <silent> <F5> :!clear;python3 %<CR>

" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-I> :ZoomToggle<CR>

" Tab, indent, etc.
set showmatch

set hlsearch " Highligh search results

" Folding
"autocmd BufWinLeave *.* mkview
"autocmd BufWinEnter *.* silent loadview
set foldmethod=manual

" vertical line indentation
let g:indentLine_color_term = 239
let g:indentLine_color_gui = '#09AA08'
let g:indentLine_char = '│'

" Delimiter
let delimitMate_expand_cr = 1

" CtrlP
" Use <leader>t to open ctrlp
let g:ctrlp_map = '<leader>t'
" Ignore these directories
set wildignore+=*/build/**
" disable caching
let g:ctrlp_use_caching=0

"set autoindent
set smartindent
set smarttab
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
