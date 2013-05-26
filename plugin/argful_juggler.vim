function! ArgfulInWhat()
  let orig_pos = getpos('.')
  let distances = {}
  for c in ['(', '[', '{']
    call setpos('.', orig_pos)
    exe "normal! va" . c
    exe "normal! \<esc>"
    let lhs_pos = getpos("'<")
    let rhs_pos = getpos("'>")
    if (lhs_pos != rhs_pos) &&
          \ (lhs_pos[1] <= orig_pos[1]) && (rhs_pos[1] >= orig_pos[1]) &&
          \ (lhs_pos[2] <= orig_pos[2]) && (rhs_pos[2] >= orig_pos[2])
      let distances[c] = (orig_pos[1]-lhs_pos[1])*1000 + (orig_pos[2]-lhs_pos[2])
    else
      let distances[c] = 99999
    endif
  endfor
  call setpos('.', orig_pos)
  let min = min(values(distances))
  if min == 99999
    return ''
  else
    call filter(distances, 'v:val == min')
    return keys(distances)[0]
  endif
endfunction

function! ArgfulVisualiseCollection()
  let what = ArgfulInWhat()
  if what != ''
    let reg_save = @@
    exe "normal! va" . what . 'y'
    exe "normal! gvo"
    let b:artful_collection = {
          \ 'pos' : getpos('.'),
          \ 'collection' : g:argful_juggler#parser.match(@@)['value']}
    let @@ = reg_save
  endif
endfunction

" test(text, [a, b], "blah {blah} blah")

nnoremap <down> :call ArgfulVisualiseCollection()<cr>

" vmap <up> should expand the selection scope to the next outer collection
" vmap <right> should move the current visual selection to the next element of
" the currently selected collection (likewise for left). If the whole
" collection is selected then the first <right> should move inside the
" collection, selecting the first elem. Subsequent <right> adjust the selected
" elem. This should look a bit like skipping through whole cells in a
" spreadhseet.
" vmap <s-right> should shift the current visually selected
" element, either rotating or maxing on the border (and shift-left)

" I also " want border adjustments, so with the cursor at | in:
" [a, [b, c], |d], we could get the following each in single steps:
" [a, [b], c, d]  = pull elem from neighbour
" [a, [b, c, d]]  = push elem into neighbour

