" algorith which pins the active buffer to first in the list, and appends
" buffers which are not open in any other window
function! bufferline#algos#active_hidden#modify(names)
  call bufferline#algos#fixed_position#modify(a:names, 0)

  let i = 1
  while i < len(a:names)
    if bufwinnr(a:names[i][0]) < 0
      let i = i + 1
      continue
    endif
    call remove(a:names, i)
  endwhile
endfunction
