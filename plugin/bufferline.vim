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

if !exists('g:bufferline_rotate')
  let g:bufferline_rotate=0
endif

" keep track of vimrc setting
let s:updatetime = &updatetime

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
      let name =  i . ':' . fname . modified

      if current_buffer == i
        let name = g:bufferline_active_buffer_left . name . g:bufferline_active_buffer_right
      else
        let name = g:bufferline_seperator . name . g:bufferline_seperator
      endif

      call add(names, name)
    endif
    let i += 1
  endwhile
  return names
endfunction

function! bufferline#generate_string()
  let names = s:generate_names()

  let line = ''
  for name in names
    let line .= name
  endfor

  return line
endfunction

function! s:echo()
  let line = bufferline#generate_string()

  " 12 is magical and is the threshold for when it doesn't wrap text anymore
  let width = winwidth(0) - 12
  if strlen(line) >= width
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
