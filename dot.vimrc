
" Scott's .vimrc file, based on the example vim distribution example.

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" keep 50 lines of command line history
set history=50

" show the cursor position all the time
set ruler

" display incomplete commands
set showcmd

" do incremental searching
set incsearch

" show line numbers
set number

" don't blink the cursor
set guicursor+=i:blinkwait0

" set some sensible tab settings (death to \t!)
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set softtabstop=4
set autoindent

" Use ctrl + movement keys to move around windows
map <C-H> <C-W>h<C-W>_
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Hide pyc files and .anything files in file explorer.
let g:netrw_list_hide='^\.[^\.],\.pyc$'

" Some different HTML indenting behavior.
let g:html_indent_inctags = "li" 

" If the gui is launching, set the window size to a reasonable default.
if has("gui_running")
  " do ---- for tabs
  set list listchars=tab:\ \ ,trail:·

  set lines=50
  set columns=85
  set go-=T
  if has("gui_gtk2")
    " For Ubuntu
    set guifont=Ubuntu\ Mono
  elseif has("gui_macvim")
    " For Mac OS X
    set guifont=Bitstream\ Vera\ Sans\ Mono:h10
  endif
endif

call pathogen#infect()

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  fun! s:SelectHTML()
    let n = 1
    while n < 50 && n < line("$")
      " check for jinja
      if getline(n) =~ '{%\s*\(extends\|block\|macro\|set\|if\|for\|include\|trans\)\>'
        set ft=htmljinja
        return
      endif
      " check for django
      if getline(n) =~ '{%\s*\(extends\|block\|comment\|ssi\|if\|for\|blocktrans\)\>'
        set ft=htmldjango
        return
      endif
      " check for mako
      if getline(n) =~ '<%\(def\|inherit\|include\|page\|namespace\|doc\)'
        set ft=mako
        return
      endif
      " check for genshi
      if getline(n) =~ 'xmlns:py\|py:\(match\|for\|if\|def\|strip\|xmlns\)'
        set ft=genshi
        return
      endif
      let n = n + 1
    endwhile
    " go with html
    set ft=html
  endfun

  " Do differently smart indenting in HTML (2 space tabs)
  autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako setlocal tabstop=2 shiftwidth=2 softtabstop=2
 
  autocmd BufNewFile,BufRead host.conf setlocal ft=apache
  autocmd BufNewFile,BufRead *.rhtml setlocal ft=eruby
  autocmd BufNewFile,BufRead *.mako setlocal ft=mako
  autocmd BufNewFile,BufRead *.mcss setlocal ft=css
  autocmd BufNewFile,BufRead *.py_tmpl setlocal ft=python
  autocmd BufNewFile,BufRead *.html,*.html call s:SelectHTML()
  "autocmd BufNewFile,BufRead *.html,*.htm setlocal ft=mako
  
  autocmd FileType css setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
  autocmd FileType javascript setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
  autocmd FileType vim setlocal expandtab shiftwidth=2 tabstop=8 softtabstop=2
  
  let g:closetag_default_xml=1
  autocmd FileType html,htmldjango,htmljinja,eruby,mako let b:closetag_html_style=1
  autocmd FileType html,html,xhtml,xml,htmldjango,htmljinja,eruby,mako source ~/.vim/scripts/closetag.vim
  imap <C--> <C-_>

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has("gui_running")
    " Settings for GPG integration.
    " Don't use GPG agent, we don't have it by default on OS X.
    let g:GPGUseAgent = 0
    " If no recipients are set, encrypt to me.
    let g:GPGDefaultRecipients = ["storborg@mit.edu"]
    " Use vibrantink in GUI mode.
    "colorscheme vibrantink 
    colorscheme molokai
endif


