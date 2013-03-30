let g:bufferline_active_buffer_left = '['
let g:bufferline_active_buffer_right = ']'
let g:bufferline_seperator = ' '
let g:bufferline_modified = '!'

function! bufferline#refresh()
    let names = []
    let i = 1
    let last_buffer = bufnr('$')
    let current_buffer = bufnr('%')
    while i <= last_buffer
        if bufexists(i) && buflisted(i)
            let name = i . ':' . fnamemodify(bufname(i), ':t')
            if getbufvar(i, '&mod')
                let name .= g:bufferline_modified
            endif

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
endfunction

function! bufferline#delayrefresh()
    let s:updatetime = &updatetime
    if &updatetime != 1
        let &updatetime = 1
    endif
    autocmd bufferline CursorHold *
                \ call bufferline#refresh() |
                \ autocmd! bufferline CursorHold
                \ let &updatetime = s:updatetime
endfunction

augroup bufferline
    au!
    autocmd BufWritePost,BufReadPost,BufWipeout,BufWinEnter * call bufferline#delayrefresh()
    autocmd WinEnter,InsertLeave * call bufferline#refresh()
augroup END

