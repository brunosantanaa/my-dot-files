" Plugin  ----------------------------------------------------------------------------
call plug#begin()
" Theme Sonokai
Plug 'sainnhe/sonokai'

 " Status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" DevIcons
Plug 'ryanoasis/vim-devicons'

" HighLights of a collection of language packs
Plug 'sheerun/vim-polyglot'

" Folder tree
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Auto Format
Plug 'dense-analysis/ale'
Plug 'jiangmiao/auto-pairs'

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"" Snippets
Plug 'honza/vim-snippets'

" Telescope search
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
call plug#end()

" Import configuration -----------------------------------------------------------
:source ~/.config/nvim/init.vim.before
:source ~/.bsa/vim/lint/coc.vim

" Global Sets ------------------------------------------------------------------------
syntax on			    " Sintax highlight
set nu				    " Enable line numbers
set tabstop=4			" Show existing tab with 4 spaces width
set softtabstop=4		" Show existing tab with 4 spaces width
set shiftwidth=4		" When indenting with '>' 4 spaces
set expandtab			" On pressing tab insert 4 spaces
set smarttab			" Insert tabs on the start of a line according to shift width
set smartindent			" Automatically inserts one extra level of indentation
set hidden 			    " Hides the current buffer when a new file is openned
set incsearch 			" Incremental search
set ignorecase			" Ignore case in search
set smartcase			" Consider case if there is a upper case character
set scrolloff=8			" Minimum number of lines to keep above and below the cursor
set colorcolumn=100		" Draws a line at the given line to keep aware of the line size
set signcolumn=yes		" Add a column on the left. Useful for linting
set cmdheight=2 		" Givemore space for displaying messages
set updatetime=100		" Time in miliseconds to consider the changes
set encoding=utf-8		" The ecoding should be utf-8
set nobackup			" No backup files
set nowritebackup		" NO backup files
set splitright			" Create the vertical splits to the right
set splitbelow			" Create the horizontal splits below
set autoread			" Update Vim after file update from outside
set nocompatible        " Polyglot needs this
"set mouse=a			" Enable mouse support
"set cursorline         " Enable highlight for the current line
filetype on			    " Detect and set the filetype option and ttrigger the FileType
filetype plugin on		" Load the plugin file for the file type, if any
filetype indent on		" Load the indent file for the file type, if any

" ALE Sets  --------------------------------------------------------------------------
let g:ale_fixers = {
            \    '*': ['remove_trailing_lines', 'trim_whitespace'],
            \    }
let g:ale_fix_on_save = 1

" Remaps  ----------------------------------------------------------------------------
" NERDTree
nnoremap <C-b> :NERDTreeToggle<CR>
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
" Telescope
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Auto Commands  ---------------------------------------------------------------------
function! HighligthWordUnderCursor()
    if getline(".")[col(".")-1] !~# '[[:punct:][:blank:]]'
        exec 'match' 'Search' '/\V\<'.expand('<cword>').'\>/'
    else
        match none
    endif
endfunction

autocmd! CursorHold,CursorHoldI * call HighligthWordUnderCursor()
" Themes -----------------------------------------------------------------------------
if has('termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

let g:sonokai_style = 'maia'
let g:sonokai_enable_italic = 1
let g:sonokai_disable_italic_comment = 0
let g:sonokai_diagnostic_line_highlight = 1
let g:sonokai_current_word = 'bold'
colorscheme sonokai     " Set theme Sonokai https://github.com/sainnhe/sonokai

if(has("nvim")) " Transparent background, only for nvim
    highlight Normal guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
endif

"" Status Bar
let g:airline_theme = 'sonokai'
let g:airline#extensions#tabline#enabled = 1    " Enable File Status Top Bar
let g:airline_powerline_fonts = 1               " NerdFonts
