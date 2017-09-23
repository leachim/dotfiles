set nocompatible

" Vundle
source ~/.vundlerc

" Enable syntax processing and highlighting
syntax enable
syntax on


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Sets how many lines of history VIM has to remember
set history=3000

" copy paste to system clipboard, no vim registers
set clipboard=unnamed

" When scrolling always center view
set scrolloff=15

" do not store global and local values in a session
" set ssop-=options

" Enable filetype plugins
filetype plugin on
filetype indent on

" Leave curser at the point where it was before editing (VimTip1142)
nmap . .`[

" show full tag (together with ctags)
set sft

" rodent, begone!
set mouse=

" Set to auto read when a file is changed from the outside
set autoread

" timeout after key press
"set notimeout
"set ttimeoutlen=1000
"set timeoutlen=2000 
"set ttimeoutlen=1000

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => UI layout
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set number              " show line numbers
set showcmd             " show command in bottom bar
set nocursorline        " highlight current line
set showmatch           " higlight matching parenthesis
"set fillchars+=vert:┃
"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" Turn on the WiLd menu
set wildmode=longest,list,full
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.class
set wildignore+=.git\*,.hg\*,.svn\*

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Search settings
set ignorecase
set smartcase
set hlsearch
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" How many tenths of a second to blink when matching brackets
set mat=3

" No annoying sound on errors
set noerrorbells
set visualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 256 colors
set t_Co=256
colorscheme solarized
set background=dark


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" language and encoding support
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Python
augroup vimrc_autocmds
    autocmd!
    " highlight characters past column 120
    autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4
    autocmd FileType python highlight Excess ctermbg=DarkGrey guibg=Black
    autocmd FileType python match Excess /\%120v.*/
    autocmd FileType python set nowrap
    augroup END


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" backup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile
" If you really need it
" set directory=~/.vim/


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text formatting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Use spaces instead of tabs
set expandtab
" Be smart when using tabs ;)
set smarttab
" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
set softtabstop=4

" Linebreak on 500 characters
set lbr
set tw=300

" Enable autoindent
set autoindent
set nosmartindent
"Wrap lines
set wrap

" Show unfinished commands
set showcmd

filetype indent on
filetype plugin on

set foldmethod=indent   " fold based on indent level
set foldnestmax=10      " max 10 depth
set foldenable          " don't fold files by default on open
set foldlevelstart=10  " start with fold level of 1

augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd BufWritePre *.php,*.py,*.js,*.txt,*.hs,*.java,*.md,*.rb :call <SID>StripTrailingWhitespaces()
    autocmd BufEnter *.cls setlocal filetype=java
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab
    autocmd BufEnter *.sh setlocal tabstop=2
    autocmd BufEnter *.sh setlocal shiftwidth=2
    autocmd BufEnter *.sh setlocal softtabstop=2
    autocmd BufEnter *.py setlocal tabstop=4
    autocmd BufEnter *.md setlocal ft=markdown
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Moving around in vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Learn not to use the wrong keys
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
" let mapleader = "\"
" let g:mapleader = "\"

" remap esc to jk combination -> better than using Ctrl-c
inoremap jk <Esc>
nnoremap jk <Esc>
inoremap kj <Esc>
nnoremap kj <Esc>

" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f', '')<CR>
vnoremap <silent> # :call VisualSelection('b', '')<CR>

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
"map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
"map <leader>ba :bufdo bd<cr>

" nnoremap <leader>m :silent make\|redraw!\|cw<CR>
" nnoremap <leader>h :A<CR>
" nnoremap <leader>ev :vsp $MYVIMRC<CR>
" nnoremap <leader>et :exec ":vsp /Users/dblack/notes/vim/" . strftime('%m-%d-%y') . ".md"<CR>
" nnoremap <leader>ez :vsp ~/.zshrc<CR>
" nnoremap <leader>sv :source $MYVIMRC<CR>
" nnoremap <leader>l :call ToggleNumber()<CR>
" nnoremap <leader><space> :noh<CR>
" nnoremap <leader>s :mksession<CR>
" nnoremap <leader>a :Ag
" nnoremap <leader>c :SyntasticCheck<CR>:Errors<CR>
" nnoremap <leader>1 :set number!<CR>
" nnoremap <leader>d :Make!
" nnoremap <leader>r :TestFile<CR>
" nnoremap <leader>g :call RunGoFile()<CR>
" vnoremap <leader>y "+y

" tabs
" movement
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>

nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabmove<Space>
nnoremap tc  :tabclose<CR>
nnoremap to  :tabonly<CR>
" map <C-t><k> :tabr<cr>
" map <C-t><j> :tabl<cr>
" map <C-t><l> :tabp<cr>
" map <C-t><l> :tabn<cr>

" map <leader>te :tabedit<cr>
" map <leader>tn :tabnext<cr>
" map <leader>tp :tabprev<cr>
" map <leader>to :tabonly<cr>
" map <leader>tc :tabclose<cr>
" map <leader>tm :tabmove


" Remove the Windows ^M - when the encodings gets messed up
" noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
" map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
" map <leader>x :e ~/buffer.md<cr>

" Toggle paste mode on and off
" map <leader>pp :setlocal paste!<cr>

" Yank text to clipboad
noremap <leader>y "*y
noremap <leader>yy "*Y

" Switch CWD to the directory of the open buffer
" map <leader>cd :cd %:p:h<cr>:pwd<cr>

" EasyMotion
"let g:EasyMotion_leader_key = '<Space>'

" copy paste with urxvt and F7
:map <F7> :w !xclip<CR><CR>
:vmap <F7> "*y
:map <S-F7> :r!xclip -o<CR>

" Split windows with | and -
"nnoremap <silent> \| <C-w>v
"nnoremap <silent> - <C-w>s

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>





" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
"map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Buffers
"map <leader>n :new<cr>
"map <leader>bd :bdelete!<cr>
"map <leader>ba :1,1000 bd!<cr>

" The following mappings (which require gvim), you can press Ctrl-Left or Ctrl-Right to go to the previous or next tabs, and can press Alt-Left or Alt-Right to move the current tab to the left or right.
"nnoremap <C-Left> :tabprevious<CR>
"nnoremap <C-Right> :tabnext<CR>
" "nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
"nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>

" Let 'tl' toggle between this and the last accessed tab
" let g:lasttab = 1
" nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
" au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
" map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
" map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
" try
"   set switchbuf=useopen,usetab,newtab
"   set stal=2
" catch
" endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
" Remember info about open buffers on close
set viminfo^=%

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
"nmap <M-j> mz:m+<cr>`z
"nmap <M-k> mz:m-2<cr>`z
"vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
"vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell and Syntax checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>s? z=

" w0rp/ale, syntax checking
"let g:ale_lint_on_save = 1
"let g:ale_lint_on_text_changed = 0
" You can disable this option too
" " if you don't want linters to run on opening a file
"let g:ale_lint_on_enter = 0


""""""""""""""""""""""""""""""
" => Commenting
""""""""""""""""""""""""""""""

" Commenting blocks of code depending on file format
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python,julia   let b:comment_leader = '# '
autocmd FileType conf,fstab       let b:comment_leader = '# '
autocmd FileType tex              let b:comment_leader = '% '
autocmd FileType mail             let b:comment_leader = '> '
autocmd FileType vim              let b:comment_leader = '" '
noremap <silent> <leader>nc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> <leader>nn :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

filetype plugin indent on


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
let g:airline_theme='minimalist'

let g:airline_highlighting_cache = 1
"let g:bufferline_echo = 0
        
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#branch#enabled = 0
let g:airline#extensions#hunks#non_zero_only = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins and Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Plugin Shortcuts
map <leader>d :NERDTreeToggle<CR>
"map <leader>u :GundoToggle<CR>
"map <leader>p :CtrlP<CR>
"map <leader>h :HLint<CR>
"map <leader>c :NeoCompleteToggle<CR>
"map <leader>a :Ack
"map <leader>b :BufExplorer<CR>
"map <leader>z :NarrowRegion<CR>

" Copy Paste clipboard
" Copy to X CLIPBOARD
" map <leader>cc :w !xsel -i -b<CR>
" map <leader>cp :w !xsel -i -p<CR>
" map <leader>cs :w !xsel -i -s<CR>
" Paste from X CLIPBOARD
" map <leader>pp :r!xsel -p<CR>
" map <leader>ps :r!xsel -s<CR>
" map <leader>pb :r!xsel -b<CR>

" YCM - autocompletion
map <F9> :YcmCompleter FixIt<CR>
nnoremap <leader>jd :YcmCompleter GoTo<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" scrooloose/nerdcommenter

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
" let g:NERDCompactSexyComs = 1

" " Align line-wise comment delimiters flush left instead of following code indentation
" let g:NERDDefaultAlign = 'left'

" " Set a language to use its alternate delimiters by default
" let g:NERDAltDelims_java = 1

" " Add your own custom formats or override the defaults
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" " Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" " Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntastic - syntax highlighting 
"let python_highlight_all=1
"syntax on

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode="passive"
let g:syntastic_enable_signs=0

let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes':   [],'passive_filetypes': [] }
noremap <C-w>e :SyntasticCheck<CR>
noremap <C-w>q :SyntasticToggleMode<CR>

" ignore certain warnings
let g:syntastic_quiet_messages={'level':'warnings'}
let g:syntastic_python_checker_args = '--ignore=E402'
let g:syntastic_python_flake8_post_args='--ignore=E402'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CTRLP 
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc

" strips trailing whitespace at the end of files. this
" is called on buffer write in the autogroup above.
function! <SID>StripTrailingWhitespaces()
    " save last search & cursor position
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction

" function! <SID>CleanFile()
    " " Preparation: save last search, and cursor position.
    " let _s=@/
    " let l = line(".")
    " let c = col(".")
    " " Do the business:
    " %!git stripspace
    " " Clean up: restore previous search history, and cursor position
    " let @/=_s
    " call cursor(l, c)
" endfunction
" "


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("Ag \"" . l:pattern . "\" " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" " Don't close window, when deleting a buffer
" command! Bclose call <SID>BufcloseCloseIt()
" function! <SID>BufcloseCloseIt()
   " let l:currentBufNum = bufnr("%")
   " let l:alternateBufNum = bufnr("#")
"
   " if buflisted(l:alternateBufNum)
     " buffer #
   " else
     " bnext
   " endif
"
   " if bufnr("%") == l:currentBufNum
     " new
   " endif
"
   " if buflisted(l:currentBufNum)
     " execute("bdelete! ".l:currentBufNum)
   " endif
" endfunction
