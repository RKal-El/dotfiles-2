call plug#begin()
	Plug 'ycm-core/YouCompleteMe'
	Plug 'joshdick/onedark.vim'
	Plug 'preservim/nerdtree'
	Plug 'ryanoasis/vim-devicons'
	Plug 'sheerun/vim-polyglot'
	Plug 'jiangmiao/auto-pairs'
	Plug 'vim-airline/vim-airline'
call plug#end()

" airline config
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" fold com {{{}}}
set foldmethod=marker

" Unicode
set encoding=UTF-8

" NERDTree config
let g:NERDTreeWinSize=20

" colorscheme
syntax on
colorscheme onedark
set termguicolors

" vim terminal bottom
let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
	if win_gotoid(g:term_win)
		hide
	else
		botright new
		exec "resize " . a:height
		try
			exec "buffer " . g:term_buf
		catch
			call termopen($SHELL, {"detach": 0})
			let g:term_buf = bufnr("")
			set nonumber
			set norelativenumber
			set signcolumn=no
		endtry
		startinsert!
		let g:term_win = win_getid()
	endif
endfunction

" lider
let mapleader = ','
set showcmd
nmap <leader>, :tabn<cr>
nmap <leader>n :NERDTree<cr>
nmap <leader>t :call TermToggle(4)<cr>

" exibir numeros
set number
set relativenumber

" não quebrar linhas
set nowrap

" cursor
set guicursor=v-c-sm:block,c-i-ci-ve:ver25,r-cr-o:hor20

" tamanho correto do Tab, importante estar no fim do arquivo
set autoindent noexpandtab tabstop=4 shiftwidth=4
