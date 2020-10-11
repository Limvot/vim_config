scriptencoding utf-8
" ^^ Please leave the above line at the start of the file.
" Default configuration file for Vim
" $Header: /var/cvsroot/gentoo-x86/app-editors/vim-core/files/vimrc-r3,v 1.1
" 2006/03/25 20:26:27 genstef Exp $
" Written by Aron Griffis <agriffis@gentoo.org>
" Modified by Ryan Phillips <rphillips@gentoo.org>
" Modified some more by Ciaran McCreesh <ciaranm@gentoo.org>
" Added Redhat's vimrc info by Seemant Kulleen <seemant@gentoo.org>
" You can override any of these settings on a global basis via the
" "/etc/vim/vimrc.local" file, and on a per-user basis via "~/.vimrc". You may
" need to create these.

" Some of my changes
set number      " line numbers!
set history=100 " More command history!
set incsearch   " Show first match while still typing it

" autoreload .vimrc
autocmd! bufwritepost .vimrc source %
autocmd! bufwritepost init.vim source %
autocmd! bufwritepost vimrc source %

" replace currently selected text with default register
" without yanking it
vnoremap <leader>p "_dP

nnoremap <leader>v <C-w>v<C-w>l
nnoremap <leader>h <C-w>s<C-w>l
:nnoremap <Space> :exec "normal i".nr2char(getchar())."\e"<CR>
:nnoremap <Space>l :exec "normal a".nr2char(getchar())."\e"<CR>

:nnoremap <leader>m :bn<CR>
:nnoremap <leader>t :tabnew<CR>
:nnoremap <leader>. :tabn<CR>
:nnoremap <leader>, :tabp<CR>
:nnoremap <leader>q :q<CR>
" press jk as Esc
:inoremap jk <Esc>
:inoremap kj <Esc>


" Color
"set termguicolors
"set guicolors
"set t_Co=256
"set term=xterm-256color
"set t_ut=
" in case t_Co alone doesn't work, add this as well:
"let &t_AB="\e[48;5;%dm"
"let &t_AF="\e[38;5;%dm"

"set termguicolors
"colorscheme kalisi
"colorscheme gruvbox
"colorscheme oxeded
"colorscheme mustang
"colorscheme monokain
"
"colorscheme lucius
"colorscheme onedark
"colorscheme sol

"set background=dark
"set background=light

" Airline
"let g:airline_powerline_fonts = 1
"set laststatus=2
"if !exists('g:airline_symbols')
  "let g:airline_symbols = {}
"endif
"let g:airline_symbols.space = "\ua0"

" Syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

"let g:syntastic_cpp_compiler = 'clang++'
"let g:syntastic_cpp_compiler_options = ' -std=c++11'
"let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'

" GLSL syntax highlighting 
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.geom,*.gp set filetype=glsl 

" Kraken syntax highlighting
au BufNewFile,BufRead *.krak set filetype=cpp 


" Easymotion
"nmap s <Plug>(easymotion-s)

" USER STUFF


" Remove trailing spaces
"function TrimWhiteSpace()
	"%s/\s*$//
	"''
":endfunction
"map <F2> :call TrimWhiteSpace()<CR>
"map! <F2> :call TrimWhiteSpace()<CR>

"autocmd FileType c,cpp,java,diff autocmd BufWritePre <buffer> :%s/\s\+$//e

" {{{ General settings
" The following are some sensible defaults for Vim for most users.
" We attempt to change as little as possible from Vim's defaults,
	" deviating only where it makes sense
	set nocompatible        " Use Vim defaults (much better!)
	set bs=2                " Allow backspacing over everything in insert mode
	set ai                  " Always set auto-indenting on
	set history=50          " keep 50 lines of command history
	set ruler               " Show the cursor position all the time
	set tabstop=4                " Indent tabs by 4 spaces.

	set viminfo='20,\"500   " Keep a .viminfo file.
	set shiftwidth=4
	set expandtab
	" Don't use Ex mode, use Q for formatting
	map Q gq

	" When doing tab completion, give the following files lower priority. You may
	" wish to set 'wildignore' to completely ignore files, and 'wildmenu' to enable
	" enhanced tab completion. These can be done in the user vimrc file.
	set suffixes+=.info,.aux,.log,.dvi,.bbl,.out,.o,.lo

	" When displaying line numbers, don't use an annoyingly wide number column. This
	" doesn't enable line numbers -- :set number will do that. The value given is a
	" minimum width to use for the number column, not a fixed size.
	if v:version >= 700
	set numberwidth=3
	endif
	" }}}

	" {{{ Modeline settings
	" We don't allow modelines by default. See bug #14088 and bug #73715.
	" If you're not concerned about these, you can enable them on a per-user
	" basis by adding "set modeline" to your ~/.vimrc file.
	set nomodeline
	" }}}

	" {{{ Locale settings
	" Try to come up with some nice sane GUI fonts. Also try to set a sensible
	" value for fileencodings based upon locale. These can all be overridden in
	" the user vimrc file.
	if v:lang =~? "^ko"
	set fileencodings=euc-kr
	set guifontset=-*-*-medium-r-normal--16-*-*-*-*-*-*-*
	elseif v:lang =~? "^ja_JP"
	set fileencodings=euc-jp
	set guifontset=-misc-fixed-medium-r-normal--14-*-*-*-*-*-*-*
	elseif v:lang =~? "^zh_TW"
	set fileencodings=big5
	set
	guifontset=-sony-fixed-medium-r-normal--16-150-75-75-c-80-iso8859-1,-taipei-fixed-medium-r-normal--16-150-75-75-c-160-big5-0
	elseif v:lang =~? "^zh_CN"
	set fileencodings=gb2312
	set guifontset=*-r-*
	endif

	" If we have a BOM, always honour that rather than trying to guess.
	if &fileencodings !~? "ucs-bom"
	set fileencodings^=ucs-bom
	endif

	" Always check for UTF-8 when trying to determine encodings.
	if &fileencodings !~? "utf-8"
	set fileencodings+=utf-8
	endif

	" Make sure we have a sane fallback for encoding detection
	set fileencodings+=default
	" }}}

	" {{{ Syntax highlighting settings
	" Switch syntax highlighting on, when the terminal has colors
	" Also switch on highlighting the last used search pattern.
	"if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
	"endif
	" }}}

	" {{{ Terminal fixes
	if &term ==? "xterm"
	set t_Sb=^[4%dm
	set t_Sf=^[3%dm
	set ttymouse=xterm2
	endif

	if &term ==? "gnome" && has("eval")
	" Set useful keys that vim doesn't discover via termcap but are in the
	" builtin xterm termcap. See bug #122562. We use exec to avoid having to
	" include raw escapes in the file.
	exec "set <C-Left>=\eO5D"
	exec "set <C-Right>=\eO5C"
	endif
	" }}}

	" {{{ Filetype plugin settings
	" Enable plugin-provided filetype settings, but only if the ftplugin
	" directory exists (which it won't on livecds, for example).
	if isdirectory(expand("$VIMRUNTIME/ftplugin"))
	filetype plugin on

	" Uncomment the next line (or copy to your ~/.vimrc) for plugin-provided
	" indent settings. Some people don't like these, so we won't turn them on by
	" default.
	" filetype indent on
	endif
	" }}}

	" {{{ Fix &shell, see bug #101665.
	if "" == &shell
	if executable("/bin/bash")
	set shell=/bin/bash
	elseif executable("/bin/sh")
	set shell=/bin/sh
	endif
	endif
	"}}}

	" {{{ Our default /bin/sh is bash, not ksh, so syntax highlighting for .sh
	" files should default to bash. See :help sh-syntax and bug #101819.
	if has("eval")
	let is_bash=1
	endif
	" }}}

	" {{{ Autocommands
	if has("autocmd")

	augroup gentoo
	au!

	" Gentoo-specific settings for ebuilds.  These are the federally-mandated
	" required tab settings.  See the following for more information:
	" http://www.gentoo.org/proj/en/devrel/handbook/handbook.xml
	" Note that the rules below are very minimal and don't cover everything.
	" Better to emerge app-vim/gentoo-syntax, which provides full syntax,
	" filetype and indent settings for all things Gentoo.
	au BufRead,BufNewFile *.e{build,class} let is_bash=1|setfiletype sh
	au BufRead,BufNewFile *.e{build,class} set ts=4 sw=4 noexpandtab

	" In text files, limit the width of text to 78 characters, but be careful
	" that we don't override the user's setting.
	autocmd BufNewFile,BufRead *.txt
	\ if &tw == 0 && ! exists("g:leave_my_textwidth_alone") |
	\     setlocal textwidth=78 |
	\ endif

    " I don't know exactly what's going on here, but it's screwing stuff up,
    " maybe b/c neovim
	"autocmd BufWrite * mkview
	"autocmd BufRead * silent loadview

	" When editing a file, always jump to the last cursor position
	autocmd BufReadPost *
	\ if ! exists("g:leave_my_cursor_position_alone") |
	\     if line("'\"") > 0 && line ("'\"") <= line("$") |
	\         exe "normal g'\"" |
	\     endif |
	\ endif

	" When editing a crontab file, set backupcopy to yes rather than auto. See
	" :help crontab and bug #53437.
	autocmd FileType crontab set backupcopy=yes

	augroup END

	endif " has("autocmd")
	" }}}

	" {{{ vimrc.local
	if filereadable("/etc/vim/vimrc.local")
	source /etc/vim/vimrc.local
	endif
	" }}}

	" vim: set fenc=utf-8 tw=80 sw=2 sts=2 et foldmethod=marker :
	filetype plugin indent on

