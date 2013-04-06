let g:bufferline_active_buffer_left = '['
let g:bufferline_active_buffer_right = ']'
let g:bufferline_seperator = ' '
let g:bufferline_modified = '+'

" keep track of vimrc setting
let s:updatetime = &updatetime

function! bufferline#print()
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

    let line = join(names, '')
    if strlen(line) < winwidth(0)
        echo line
    endif

    if &updatetime != s:updatetime
        let &updatetime = s:updatetime
    endif
endfunction

function! bufferline#refresh(updatetime)
    let &updatetime = a:updatetime
    autocmd bufferline CursorHold *
                \ call bufferline#print() |
                \ autocmd! bufferline CursorHold
endfunction

augroup bufferline
    au!

    " events which output a message which should be immediately overwritten
    autocmd BufWinEnter,WinEnter,InsertLeave * call bufferline#refresh(1)

    " events which output a message, and should update after a delay
    autocmd BufWritePost,BufReadPost,BufWipeout * call bufferline#refresh(s:updatetime)
augroup END

