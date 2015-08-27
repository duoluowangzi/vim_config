" favorite files and direcotries
let $favorites=''
if has("win32")
  let $favorites='E:/Material/Linux/Vim/config/favorites.vim'
endif
if $favorites != ""
  so $favorites
endif

" ============================ appearence =============================== {{{2
" ---------- indent {{{3
set autoindent " ai
set sw=2 " shift width, indent width
set tabstop=2 " ts, tabstop width
set tw=80
set et " extendtab
autocmd BufEnter * set et
autocmd BufEnter,BufRead *.txt,*.md set noet

" --------- display as more lines as possible, do not use @@ {{{3
set display=lastline " dy=lastline

set backspace=indent,eol,start
set number
set encoding=utf-8
set fencs=utf8,gbk,gb2312,cp936,gb18030

" scrolling {{{3
set scrolloff=3 "margin of moving to top or bot of current screen

" ---------- folding option {{{3
" marker manual indent
set foldmethod=marker
set foldenable
set fdl=3
" foldlevel

" --------- status line, command line {{{3
set statusline=%<%F\ %y\ %m%r%=0x%B\ %l/%L,%c%V\ [b%nw%{winnr()}]
" always display status line, 0 never, 1 more than 2 windows, 2 always
set laststatus=2
" ruler, command line appearance, if laststatus == 2, ruler is useless
set noruler " ru
set rulerformat =%30(%<%y\ %m%r%=0x%B\ %l,%c%V\ [%n]\ %P%)

" ---------- using system clipboard {{{3
set clipboard+=unnamed
" if has("win32")
"   set ff=dos
".proceed else
"   set ff=unix
" endif

" set right margin, only > 704 the cc option is available {{{3
if version >= 704
  set cc=80 " colorcolumn=80 " cc=80
endif
" hilight current line
set cursorline
" hilight column
set cursorcolumn

" netrw explorer {{{3
let g:netrw_winsize = 20
let g:netrw_liststyle= 3 " archive
let g:netrw_menu = 0 " no menu
let g:netrw_preview = 1 " preview in vertical new window

" menu bar {{{3
if has("gui")
  " set window(gui) size
  if has("win32")
    " ~x max ~n min ~r restore
    autocmd GUIEnter * simalt ~x
    " set lines=25
    " set columns=100
  endif
  " toggle menu bar, tool bar, scroll bar
  " guioptions == go
  set guioptions-=T " += is on, -= is off
  set guioptions-=m " menu bar
  set go-=M " system menu
  set go-=R " right scroll
  set go-=r " do not show right scroll
  set go-=L " left
  set go-=l
  " set selectmode+=mouse
endif

" ---------- disable mouse under unix system
if has("unix")
  set mouse=
endif

" theme {{{3
if &term == 'vt100' || &term == 'xterm'
  set term=xterm-256color
endif
colorscheme Monokai_Gavin
set guifont=Consolas:h13
" echo &t_Co
syntax enable
syntax on

" show white spaces {{{3
set listchars=tab:>-,trail:-
set list

" set tablabel as 'number filename' {{{3
if has("gui")
  function! GuiTabLabel()

"     Add '*' if one of the buffers in the tab page is modified
"     let bufnrlist = tabpagebuflist(v:lnum)
"     for bufnr in bufnrlist
"       if getbufvar(bufnr, "&modified")
"         let label = '*'
"         break
"       endif
"     endfor

    let t:winCount = tabpagewinnr(tabpagenr(), '$')

    " do not change the tablabel when focus on tlist or netrw
    let t:TlistWinnr = bufwinnr(g:TagList_title)
    if t:TlistWinnr > 1 && winnr() == t:TlistWinnr
      return t:label
    endif
    " change netrw_treelistnum in netrw.vim to non-increasing
    " NetrwTreeListing, can match all netrw windows
    let t:netrwWinnr = bufwinnr('NetrwTreeListing')
    if t:netrwWinnr > 0 && winnr() == t:netrwWinnr
      if t:winCount == 1 || !exists('t:label')
        let t:label = tabpagenr() . ' NetrwTreeListing'
      endif
      return t:label
    endif

    " add '*' if the current window(file) has been modified
    if getwinvar(winnr(), "&modified")
      let t:label = '*'
    else
      let t:label = ''
    endif

    let t:name =  " " . expand("%:t")
    if t:name == ' '
      let t:name = ' [No Name]'
    endif
    if t:TlistWinnr > 1 && t:winCount > 1 | let t:winCount = t:winCount - 1 | endif
    if t:netrwWinnr > 0 && t:winCount > 1 | let t:winCount = t:winCount - 1 | endif
    if t:winCount > 1
      let t:winCount = " " . t:winCount
    else
      let t:winCount = ''
    endif
    let t:label = t:label . tabpagenr() . t:name . t:winCount
    return t:label
  endfunction

  set guitablabel=%{GuiTabLabel()}
  " equivalent, but no *
  " set guitablabel=%N\ %t
endif

" ---------- custom tabs for terminal version
function! MyTabLabel(n)
  let label = ''
  let bufnrlist = tabpagebuflist(a:n)
  " Add '*' if one of the buffers in the tab page is modified
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      let label = '*'
      break
    endif
  endfor
  " get all file names
  let winCount = tabpagewinnr(a:n, '$')
  let winnr = tabpagewinnr(a:n)
  let fileName = bufname(bufnrlist[winnr - 1])
  let lastOccur = strridx(fileName, "/")
  if (lastOccur > 0)
    let fileName = strpart(fileName, lastOccur + 1, strlen(fileName))
  endif
  let label = label . a:n . " " . fileName . " ". winCount
  return label
endfunction

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} |'
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction
" %! means the things following it will be evaluated as expression
set tabline=%!MyTabLine()

" ============================== key mapping ============================ {{{2
" tab mappings
nmap <M-1> <ESC>1gt
nmap <M-2> <ESC>2gt
nmap <M-3> <ESC>3gt
nmap <M-4> <ESC>4gt
nmap <M-5> <ESC>5gt
nmap <M-6> <ESC>6gt
nmap <M-7> <ESC>7gt
nmap <M-8> <ESC>8gt
nmap <M-9> <ESC>9gt
nmap <M-t> <ESC>:tabnew<CR>
nmap <M-w> <ESC>:tabclose<CR>
map <C-Tab> <ESC>gt
imap <C-Tab> <ESC>gt
imap <C-F4> <ESC>:tabc<CR>
map <C-F4> <ESC>:tabc<CR>

" Use CTRL-S for saving, also in Insert mode
noremap <C-S> :update<CR>
vnoremap <C-S> <C-C>:update<CR>
inoremap <C-S> <C-O>:update<CR>

" comment
let g:COMMENT_1 = 1 " add comment string at the begin of the line
let g:COMMENT_2 = 2 " add comment string before the first word of the line
let g:UNCOMMENT = 3 " uncomment
function! CommentImpl(commentStr, mode)
  " echo a:commentStr
  " execute "echo " . '"' . a:commentStr . '"'
  let l:cs = ""
  let l:cse = ""
  if a:commentStr == "vim"
    let l:cs = '"'
  elseif a:commentStr == "xml"
    let l:cs = "<!--"
    let l:cse = " -->"
  else
    let l:cs .= a:commentStr
  endif

  " comment
  if a:mode == g:COMMENT_1
    " comment codes, add commentStr at the begin of line
    " exe 's!^!' . l:cs . ' !'
    exe 's/\(^\s*\)\(.*\)/' . l:cs . ' \1\2' . l:cse . '/e'
  elseif a:mode == g:COMMENT_2
    " comment description, add commentStr before the first word
    exe 's/\(^\s*\)\(.*\)/\1' . l:cs . ' \2' . l:cse . '/e'
  " uncomment
  elseif a:mode == g:UNCOMMENT
    exe 's/^\(\s*\)' . l:cs . ' \{0,1\}\(.*\)' . l:cse . '/\1\2/e'
  endif
  exe 'noh'
endfunction

function! Comment(mode)
  " comment string is //
  for tmp in ["cpp", "c", "java", "php", "javascript"]
    if &ft == tmp
      call CommentImpl("\\/\\/", a:mode)
      return "//"
    endif
  endfor
  " comment string is "
  if &ft == "vim"
    call CommentImpl("vim", a:mode)
    return "vim"
  endif
  " comment string is #
  for tmp in ["python","sed","apache","bash","conf", "sh", "make", "cfg"]
    if &ft == tmp
      call CommentImpl("#", a:mode)
      return tmp
    endif
  endfor
  " comment string is ;
  if &ft == "dosini" || &ft == "ini" || &ft == "autohotkey"
    call CommentImpl(";", a:mode)
    return "dosini"
  endif
  " comment string is REM
  if &ft == "dosbatch" || &ft == "cmd" || &ft == "bat"
    let l:caseChanged = 0
    let l:smartcaseChanged = 0
    if &ignorecase == 0
      set ignorecase
      let l:caseChanged = 1
    endif
    if &smartcase == 1
      set nosmartcase
      let l:smartcaseChanged = 1
    end
    call CommentImpl("REM", a:mode)
    if l:caseChanged == 1
      set noignorecase
    endif
    if l:smartcaseChanged == 1
      set smartcase
    end
    return "dosbatch"
  endif
  " comment string is '
  if &ft == "vbs" || &ft == "vb"
    call CommentImpl("'", a:mode)
    return "vbs"
  endif
  
  " comment string is <!--  -->
  for tmp in ["html", "xml", "axml", "htm", "xhtml"]
    if &ft == tmp
      call CommentImpl("xml", a:mode)
      return "xml"
    endif
  endfor

  " comment string is %
  if &ft == "matlab"
    call CommentImpl("%", a:mode)
    return "matlab"
  endif

  " comment string is --
  if &ft == "lua"
    call CommentImpl("--", a:mode)
    return "lua"
  endif

  echo "No comment command support for " . &ft . " --- Gavin"
endfunction

nmap <silent> cc :call Comment(COMMENT_1)<CR>
vmap <silent> cc :call Comment(COMMENT_1)<CR>
nmap <silent> CC :call Comment(COMMENT_2)<CR>
vmap <silent> CC :call Comment(COMMENT_2)<CR>
nmap <silent> cz :call Comment(UNCOMMENT)<CR>
nmap <silent> cx :call Comment(UNCOMMENT)<CR>
vmap <silent> cz :call Comment(UNCOMMENT)<CR>
vmap <silent> cx :call Comment(UNCOMMENT)<CR>

function! Run()
  if &ft == "vim"
    exe 'source %'
    return "vim"
  endif
  for ext in ["cc", "cpp", "c", "cxx", "h", "hpp"]
    if &ft == ext
      if has("win32")
        exe '!start cmd /c start "vim run cpp" g++.lnk "%:p"'
      elseif has("unix")
        exe '!rm ~/tmp/vim.out 2>/dev/null; g++ -Wall -std=c++11 "%:p" -o ~/tmp/vim.out && ~/tmp/vim.out;read -n1 -p "Press any key to continue...";echo'
        " refresh when return from external command
        call RefreshCurrentTab()
      endif
      return ""
    endif
  endfor
  if (&ft == 'sh')
    exe "!source %; read -n1 -p 'Press any key to continue...'"
    call RefreshCurrentTab()
    return "bash"
  endif
  if (&ft == 'markdown')
    if (has('unix'))
      exe '!killall Mou; mou %:p'
    endif
  endif
  if has("win32")
    exe '!start cmd /c start "vim run" nppCompileAndRun.lnk "%:p"'
  elseif has("unix")
"     exe '!g++ -Wall "%:p"'
  elseif has("mac")
    " do nothing
  endif
  return ""
endfunction

map <F5> :silent call Run()<CR>


nmap <F4> :call MakeSurround("normal")<CR>
vmap <F4> <ESC>:call MakeSurround("visual")<CR>


" taglist, make tag file
function! MakeTags()
  if &ft == "cpp"
"     exe '!ctags -R --langmap=.h.inl.cxx.cc --c++-kinds=+p --fields=+iaSK --extra=+q --languages=c++'
    exe '!ctags -R --language-force=c++ --exclude=.git --exclude=.svn --langmap=c++:+.inl+.cc+.h+.cxx -h +.inl --c++-kinds=+p --fields=+iaSK --extra=+q --languages=c++'
  elseif &ft == "java"
    exe '!ctags -R --java-kinds=+p --fields=+iaS --extra=+q --languages=java'
  elseif &ft == "php"
    exe '!ctags -R --php-kinds=+cidfvj --fields=+iaSK --fields=-k --extra=+q --languages=php'
  elseif &ft == "javascript"
    exe '!ctags -R --javascript-kinds=+cfv --fields=+iaSK --fields=-k --extra=+q --languages=javascript'
  endif
endfunction

map <F12> :call MakeTags()<CR>

" select all
nmap <C-A> ggVG

" ---------- redirect for ESC
" imap fds <ESC>
" map fds <ESC>
" omap fds <ESC>
" imap FDS <ESC>:echo "CAPS_LOCK!"<CR><ESC>
" map FDS <ESC>:echo "CAPS_LOCK!"<CR><ESC>
" omap FDS <ESC>:echo "CAPS_LOCK!"<CR><ESC>
" cnoremap fds <C-U><ESC>
" cnoremap FDS <C-U><ESC>:echo "CAPS_LOCK!"<CR><ESC>

" deletion, use backspace as backspace key, using black hole register
nmap <silent> <BS> h"_x
vmap <silent> <BS> h"_x

" ---------- open selected file
vnoremap <M-g> "zy:!start cmd /c start npp_open_document.lnk "<C-R>z" "%:p" "vim"<CR>
vmap <M-g> "zy:!start cmd /c start npp_open_document.lnk "<C-R>z" "%:p" "vim"<CR>

" --------- using * and # search for selected content in visual mode
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
    \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
    \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" adjust the window size
" :resize n or :vertical resize n, where n is the size in height/width
" horizontal size, height
nmap <M-]> :resize +1<CR>
nmap <M-[> :resize -1<CR>
" vertical size, width
nmap <M-=> :vertical resize +1<CR>
nmap <M--> :vertical resize -1<CR>
" maximize window
nmap <F11> :simalt ~x<CR>

" ----------append ";" at the end of line, for cpp,php,js
" imap ;; <ESC>A;
" nmap ;; <ESC>A;<ESC>

" ---------- auto complete key map
autocmd BufRead,BufEnter * call AutoCompletionKeyMap()
function! AutoCompletionKeyMap()
  if &ft == "cpp"
    imap <C-space> <C-x><C-o><C-p>
  else
    imap <C-space> <C-n><C-p>
  endif
endfunc

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap j gj
vnoremap k gk
vnoremap gj j
vnoremap gk k

" ---------- resize vertical explorer to width 30
nmap <F3> :vertical resize 20<BAR>
  \Tlist<CR>
" ---------- build project
nmap <F7> :!make clean; make -j7<CR>

" ================================ misc ================================ {{{2
" where the swap file stored
if has('win32')
  set dir=e:/temp/
elseif has('unix')
  set dir=~/temp/,~/tmp/
endif

" ignore case while search
set ignorecase " noignorecase
set smartcase " if upper case letters are typed, case sensitive

" language
if has('win32')
  language us
endif

" nocapatible with vi
set nocompatible
set magic
set nobackup
set hlsearch
set incsearch "increase search, search when typing a pattern
set showmatch
filetype on
filetype plugin on
filetype indent on

" -------- tags, taglist, file explorer
set tags=tags,./tags
set tags+=E:/Material/C++/SOURCE/cygwin_gcc_c++_tags
set tags+=E:/Material/C++/SOURCE/linux_systags
set tags+=~/cpp_stdlib.tags
set autochdir
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1
let Tlist_Enable_Fold_Column = 0

" php dictionary
autocmd filetype php set dictionary-=E:/Material/Linux/Vim/config/php_function_list.txt
autocmd filetype php set dictionary+=E:/Material/Linux/Vim/config/php_function_list.txt

"let g:winManagerWindowLayout='FileExplorer|TagList'
"nmap wm :WMToggle<cr>

" ---------- OmniCppComplete
" let g:OmniCpp_NamespaceSearch = 1
" let g:OmniCpp_GlobalScopeSearch = 1
" let g:OmniCpp_ShowAccess = 1
let g:OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
" let g:OmniCpp_MayCompleteDot = 1 " autocomplete after .
" let g:OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
" let g:OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let g:OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD", "__gnu_std"]
let g:OmniCpp_SelectFirstItem = 2 " select first popup item (without inserting it to the text)
" automatically open and close the popup menu / preview window
" au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" set completeopt=menuone,menu,longest,preview
set completeopt=menuone,menu
au BufNewFile,BufRead,BufEnter *.cpp,*.hpp,*.h,*.cc set omnifunc=omni#cpp#complete#Main

" ---------- virtual edit
set virtualedit=block

" ---------- format option
" for multibyte text width line break, for text block: select lines, press Jgqgq
set formatoptions+=m 

" ================================ commands ============================ {{{2
" ---------- trim the heading/trailing whitespaces {{{3
function! RemoveTrailingWhitespace()
  for lineNo in range(a:firstline, a:lastline)
    let line = getline(lineNo)
    let cleanLine = substitute(line, '\s\+$', '', 'e')
    call setline(lineNo, cleanLine)
  endfor
endfunction
function! RemoveBeginningWhitespace()
  for lineNo in range(a:firstline, a:lastline)
    let line = getline(lineNo)
    let cleanLine = substitute(line, '^\s\+', '', 'e')
    call setline(lineNo, cleanLine)
  endfor
endfunction
command! -range Trim <line1>,<line2>call RemoveTrailingWhitespace()
command! -range T <line1>,<line2>call RemoveTrailingWhitespace()
command! -range TrimLeft <line1>,<line2>call RemoveBeginningWhitespace()
command! -range Tl <line1>,<line2>call RemoveBeginningWhitespace()

" --------- rename current file {{{3
command! -nargs=+ -bang Rename let newName = "<args>"<BAR>
  \let curExt = expand("%:e")<BAR>
  \let oldFullPath = expand("%:p")<BAR>
  \exe "saveas<bang> " . newName<BAR>
  \echo "renamed current file to: " . expand("%:t")<BAR>
  \if newName == expand("%:t")<BAR>
    \echo "suceeded to save the file " . newName<BAR>
    \let delResult =  delete(oldFullPath)<BAR>
    \if delResult != 0<BAR>
      \echo "fail to delete the old file: " . oldFullPath<BAR>
    \endif<BAR>
  \endif<BAR>

nmap <F2> :Ren 

" --------- make/load session {{{3
" command! -nargs=? -bang Mks mks<bang> $ses
command! -nargs=? -bang Mks silent echo "try to make session"<BAR>
  \if "<args>" != ""<BAR>
    \mks<bang> <args><BAR>
    \echo "made session at: <args>"<BAR>
  \else<BAR>
    \mks<bang> $ses<BAR>
    \echo "made session at: ".$ses<BAR>
  \endif
" command! -nargs=? -bang Loadsession so $ses <args>
command! -nargs=? -bang Loadsession silent echo "try to load session"<BAR>
  \if "<args>" != ""<BAR>
    \so <args><BAR>
    \echo "loaded session from: <args>"<BAR>
  \else<BAR>
    \so $ses<BAR>
    \echo "loaded session from: ".$ses<BAR>
  \endif<BAR>

" --------- insert current time in the current position, after the cursor box {{{3
command! Time echo strftime("%Y-%m-%d-%a %H:%M:%S")<BAR>
"   \"=strftime("%Y-%m-%d %H:%M:%S")<CR><BAR>
"   \gP
" = register is the expression output register, 6. Expression register "= can only be used onece
" normal mode insert current time, and enter insert mode
nnoremap time "=strftime("%Y-%m-%d-%a %H:%M:%S")<CR>pa
nnoremap timelog "="\n##" . strftime("%Y-%m-%d-%a %H:%M:%S") . "\ntag: \n"<CR>PjjA

" --------- auto change IME to en {{{3
" for some type of files auto ime is needed
autocmd! InsertLeave *.txt,*.md call ChangeIme(g:autoChangeIme)
let g:autoChangeIme = 1
function! ChangeIme(autoChangeIme)
  if has('win32') && a:autoChangeIme
    exe '!start /MIN cmd /c start "change ime" /MIN changeVimIme2En.lnk'
    exe 'echo "back to normal mode by calling changeVimIme2En.lnk"'
  endif
endfunc
command! AutoIme silent echo "toggle auto ime"<BAR>
  \if g:autoChangeIme<BAR>
    \echo "auto change ime disabled"<BAR>
  \else<BAR>
    \echo "auto change ime enabled"<BAR>
  \endif<BAR>
  \let g:autoChangeIme=!g:autoChangeIme

" --------- get file path into the system's clipboard {{{3
command! FilePath echo 'Get file full path'<BAR>
  \:!start cmd /c start get_current_file_full_path.lnk "%:p" "vim"<CR>

" --------- view in markdown previewer {{{3
if has('win32')
  command! Markdown silent !start cmd /c start "markdown" markdown.lnk "%:p"
elseif has('unix')
  " command! Markdown silent !open -a Mou "%:p"
  command! Markdown silent !killall Mou;mou "%:p"
endif

" --------- spell {{{3
" spell default off, default language is en_US, using spf to change spell
" language
command! Spell silent echo "toggle spell"<BAR>
  \if &spell<BAR>
    \setlocal nospell<BAR>
    \echo "spell check disabled"<BAR>
  \else<BAR>
    \setlocal spell<BAR>
    \echo "spell check enabled"<BAR>
  \endif

" ---------- focus certain window {{{3
" this also can be done with "number <c-w> w" under normal mode
" the win number is assending from top-down left-right seqeunce
command! -count=1 W <count> winc w

" ---------- set vim format footer fo baidu cpp {{{3
command! Baiducpp echo "added baidu cpp vim format footer"<BAR>
  \silent call append('$',  '// vim: tw=100 ts=4 sw=4 cc=100')

" ========================= file type ================================== {{{2
autocmd BufNewFile,BufRead *.alipaylog setf alipaylog
autocmd BufNewFile,BufRead *.md setf markdown

" ========================== functions ================================= {{{2
" ---------- judge if current char is the last char
function! IsLastChar(...)

  let l:isLastChar = 0

  if mode() == "v"
    exe 'norm! l'
    " in visual mode, cursor can move to the linebreak char
    if col('.') == col('$')
      let l:isLastChar = 1
    endif
    exe 'norm! h'
  else
    let l:pos = col('.')
    exe 'norm! l'
    let l:isLastChar = 0
    if col('.') == l:pos
      let l:isLastChar = 1
    else
      exe 'norm! h'
    endif
  endif
  return l:isLastChar

endfunc

" ---------- judge if current char is the first char
function! IsFirstChar()
  let l:pos = col('.')
  let l:isFirstChar = 0
  if l:pos == 1
    let l:isFirstChar = 1
  endif
  return l:isFirstChar
endfunc

function! GetCurrentChar()
  let l:str = getline('.')
  let l:pos = col('.')
  let l:char = l:str[l:pos - 1]
  return l:char
endfunc


function! MakeSurround1(mode, ...)

  let l:old = getreg('s')

  if a:0 < 2
    let l:delim = input("surround with:")
  else
    let l:delim = a:1
  endif
  if l:delim == ''
    return
  endif
  let l:ldelim = l:delim
  let l:delimDict = {"[":"]", "(":")", "/*":"*/", "{":"}", "<":">"}
  for key in keys(l:delimDict)
    if key == l:delim
      let l:delim = l:delimDict[key]
      break
    endif
  endfor
  let l:rdelim = l:delim

  if a:mode == "visual"
    " go back to visual mode, calling this function will enter normal mode
    norm! "<ESC>"
    let l:startPos = getpos("'<")
    let l:endPos = getpos("'>")
    echo l:endPos
    
    return
    echo getpos('.')
    let l:isLastChar = IsLastChar()
    echo getpos('.')
    exe "norm! gv"
    exe 'norm! "sx'
  else
    " normal mode
    if GetCurrentChar() == ' ' || GetCurrentChar() == '	'
      echo "no surround for white space"
      return
    endif
    if !IsFirstChar()
      " move backward and go to word end
      exe 'norm! he'
    endif
    let l:isLastChar = IsLastChar()
    " echo l:isLastChar
    exe 'norm! "sdiw'
  endif

  let l:str = l:ldelim . getreg('s') . l:rdelim
  call setreg('s', l:str, 'v')

  " if the cursor is at the end of line paste behined
  if l:isLastChar
    exe 'norm! "sp'
  else
    exe 'norm! "sP'
  endif

  call setreg('s', l:old)
endfunc


function! MakeSurround(mode, ...)

  let l:old = getreg('s')

  if a:0 < 2
    let l:delim = input("surround with:")
  else
    let l:delim = a:1
  endif
  if l:delim == ''
    return
  endif
  let l:ldelim = l:delim
  let l:delimDict = {"[":"]", "(":")", "/*":"*/", "{":"}", "<":">"}
  for key in keys(l:delimDict)
    if key == l:delim
      let l:delim = l:delimDict[key]
      break
    endif
  endfor
  let l:rdelim = l:delim

  if a:mode == "visual"
    " go back to visual mode, calling this function will enter normal mode
    exe "norm! gv"
    let l:isLastChar = IsLastChar()
    exe 'norm! "sx'
  else
    " normal mode
    if GetCurrentChar() == ' ' || GetCurrentChar() == '	'
      echo "no surround for white space"
      return
    endif
    if IsFirstChar() == 0
      " move backward and go to word end
      exe 'norm! he'
    endif
    let l:isLastChar = IsLastChar()
    " echo l:isLastChar
    exe 'norm! "sdiw'
  endif

  let l:str = l:ldelim . getreg('s') . l:rdelim
  call setreg('s', l:str, 'v')

  " if the cursor is at the end of line paste behined
  if l:isLastChar
    exe 'norm! "sp'
  else
    exe 'norm! "sP'
  endif

  call setreg('s', l:old)
endfunc

" ---------- GetSelection() {{{3
let g:sCount = 0
function! GetSelection()
  " Why is this not a built-in Vim script function?!
  let l:isVisual = 0
  if mode() == 'v'
    let l:isVisual = 1
    norm! "<esc>"
  endif
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  let g:sCount = g:sCount + 1
  let l:res =  join(lines, "\n")
  echo l:res
  if l:isVisual
    norm! "gv"
  endif
  return l:res
endfunction

" ---------- RefreshCurrentTab()
function! RefreshCurrentTab()
  " refresh the current tab
  " tabnew and tabc will make the next tab active if there are more than 1 tabs
  " save the current tabpage number
  let curTabNum = tabpagenr()
  exe 'tabnew'
  exe 'tabc'
  if tabpagenr('$') != curTabNum
    exe 'tabp'
  endif
endfunction

" ============================ test ====================================== {{{2
command! -nargs=* -bang TestCmd call <bang>TestFunc(<f-args>)
function! TestFunc()
"   exe "q"
  echo expand("<bang>") . "test -bang function"
endfunction
command! -nargs=* -bang TestCmd echo "test cmd"<BAR>
  \if "<bang>" != ""<BAR>
    \echo "test"<BAR>
  \endif<BAR>
  \echo "<lt>bang>" . "\n<bang>"<BAR>
  \let arg = "<args>"<BAR>
  \echo arg<BAR>

" nohlsearch
noh

" vim:tw=80:ts=2:ft=vim:set noet
