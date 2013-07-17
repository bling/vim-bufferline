if exists('g:bufferline_loaded')
  finish
endif
let g:bufferline_loaded = 1

if !exists('g:bufferline_active_buffer_left')
  let g:bufferline_active_buffer_left = '['
endif

if !exists('g:bufferline_active_buffer_right')
  let g:bufferline_active_buffer_right = ']'
endif

if !exists('g:bufferline_seperator')
  let g:bufferline_seperator = ' '
endif

if !exists('g:bufferline_modified')
  let g:bufferline_modified = '+'
endif

if !exists('g:bufferline_echo')
  let g:bufferline_echo=1
endif

if !exists('g:bufferline_show_bufnr')
  let g:bufferline_show_bufnr=1
endif

if !exists('g:bufferline_rotate')
  " 0: no rotate, no scrolling
  " 1: scrolling with fixed current buffer position
  " 2: scrolling without fixed current buffer position
  let g:bufferline_rotate=0
endif

" keep track of vimrc setting
let s:updatetime = &updatetime

" keep track of scrollinf window start
let s:window_start = 0

function! s:generate_names()
  let names = []
  let i = 1
  let last_buffer = bufnr('$')
  let current_buffer = bufnr('%')
  while i <= last_buffer
    if bufexists(i) && buflisted(i)
      let modified = ' '
      if getbufvar(i, '&mod')
        let modified = g:bufferline_modified
      endif
      let fname = fnamemodify(bufname(i), ":t")
      let fname = substitute(fname, "%", "%%", "g")

      let name = ''
      if g:bufferline_show_bufnr
        let name =  i . ':'
      endif
      let name .= fname . modified

      if current_buffer == i
        let name = g:bufferline_active_buffer_left . name . g:bufferline_active_buffer_right
      else
        let name = g:bufferline_seperator . name . g:bufferline_seperator
      endif

      call add(names, [i, name])
    endif
    let i += 1
  endwhile
  return names
endfunction

function! bufferline#generate_string()
  " check for special cases like help files
  let current = bufnr('%')
  if !bufexists(current) || !buflisted(current)
    return bufname('%')
  endif

  let names = s:generate_names()

  " force active buffer to be second in line always and wrap the others
  if g:bufferline_rotate == 1 && len(names) > 1
    while names[1][0] != current
      let first = remove(names, 0)
      call add(names, first)
    endwhile
  endif

  let line = ''
  for val in names
    let line .= val[1]
  endfor

  return line
endfunction

function! s:echo()
  let line = bufferline#generate_string()

  " 12 is magical and is the threshold for when it doesn't wrap text anymore
  let width = winwidth(0) - 12
  if g:bufferline_rotate == 2
    let current_buffer_start = stridx(line, g:bufferline_active_buffer_left)
    let current_buffer_end = stridx(line, g:bufferline_active_buffer_right)
    if current_buffer_start < s:window_start
      let s:window_start = current_buffer_start
    endif
    if current_buffer_end > (s:window_start + width)
      let s:window_start = current_buffer_end - width + 1
    endif
    let line = strpart(line, s:window_start, width)
  else
    let line = strpart(line, 0, width)
  endif

  echo line

  if &updatetime != s:updatetime
    let &updatetime = s:updatetime
  endif
endfunction

function! s:cursorhold_callback()
  call s:echo()
  autocmd! bufferline CursorHold
endfunction

function! s:refresh(updatetime)
  let &updatetime = a:updatetime
  autocmd bufferline CursorHold * call s:cursorhold_callback()
endfunction

if g:bufferline_echo
  augroup bufferline
    au!

    " events which output a message which should be immediately overwritten
    autocmd BufWinEnter,WinEnter,InsertLeave,VimResized * call s:refresh(1)

    " events which output a message, and should update after a delay
    autocmd BufWritePost,BufReadPost,BufWipeout * call s:refresh(s:updatetime)
  augroup END
endif
