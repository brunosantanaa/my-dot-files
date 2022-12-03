" Plugin  ----------------------------------------------------------------------------
call plug#begin()
Plug 'sainnhe/sonokai'  " Install theme Sonokai
call plug#end()

" Import old configuration -----------------------------------------------------------
" :source ~/.config/nvim/init.vim.before

" Global Sets ------------------------------------------------------------------------
syntax on			" Sintax highlight
set nu				" Enable line numbers
set tabstop=4			" Show existing tab with 4 spaces width
set softtabstop=4		" Show existing tab with 4 spaces width
set shiftwidth=4		" When indenting with '>' 4 spaces
set expandtab			" On pressing tab insert 4 spaces
set smarttab			" Insert tabs on the start of a line according to shift width
set smartindent			" Automatically inserts one extra level of indentation
set hidden 			" Hides the current buffer when a new file is openned
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
"set mouse=a			    " Enable mouse support
"set cursorline          " Enable highlight for the current line
filetype on			    " Detect and set the filetype option and ttrigger the FileType
filetype plugin on		" Load the plugin file for the file type, if any
filetype indent on		" Load the indent file for the file type, if any

" Remaps  ----------------------------------------------------------------------------

" Auto Commands  ---------------------------------------------------------------------

" Themes -----------------------------------------------------------------------------
let g:sonokai_style = 'maia'
let g:sonokai_enable_italic = 1
let g:sonokai_disable_italic_comment = 0
let g:sonokai_diagnostic_line_highlight = 1
let g:sonokai_current_word = 'bold'
colorscheme sonokai     " Set theme Sonokai https://github.com/sainnhe/sonokai
