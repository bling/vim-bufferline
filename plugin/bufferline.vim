let g:bufferline_active_buffer_left = '['
let g:bufferline_active_buffer_right = ']'
let g:bufferline_seperator = ' '
let g:bufferline_modified = '+'

function! bufferline#refresh()
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
            let name = ' ' . i . ':' . fnamemodify(bufname(i), ':t') . modified

            if current_buffer == i
                let name = g:bufferline_active_buffer_left . name . g:bufferline_active_buffer_right
            else
                let name = g:bufferline_seperator . name . g:bufferline_seperator
            endif

            call add(names, name)
        endif
        let i += 1
    endwhile

    echo join(names, '')

    if &updatetime != s:updatetime
        let &updatetime = s:updatetime
    endif
endfunction

let s:updatetime = &updatetime
function! bufferline#delayrefresh(updatetime)
    let &updatetime = a:updatetime
    autocmd bufferline CursorHold *
                \ call bufferline#refresh() |
                \ autocmd! bufferline CursorHold
endfunction

augroup bufferline
    au!

    " events which output a message which should be immediately overwritten
    autocmd BufWinEnter,WinEnter * call bufferline#delayrefresh(1)

    " events which output a message, and should update after a delay
    autocmd BufWritePost,BufReadPost,BufWipeout * call bufferline#delayrefresh(s:updatetime)

    " events which do not output and can update immediately
    autocmd WinEnter,InsertLeave * call bufferline#refresh()
augroup END

