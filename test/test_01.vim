call vimtest#StartTap()
call vimtap#Plan(1)

append
func(arg1, "arg2", [arg3, 'arg4'], {'arg5': arg6})
.

normal! gg0wva(y
exe "normal! `<v`>c\<c-r>=argful_juggler#parser.match(@@)['value'].render()\<cr>\<cr>"

let line1 = "func(arg1, \"arg2\", [arg3, 'arg4'], {'arg5' : arg6})"
call vimtap#Is(getline(1), line1, 'renders clean')
call vimtest#Quit()

" echo argful_juggler#string_node('"a"').render()
" echo argful_juggler#string_node("'a'").render()
" echo argful_juggler#identifier_node('foo').render()
" echo argful_juggler#keyvalpair_node([argful_juggler#string_node('a'), ':', argful_juggler#string_node('b')]).render()
" echo g:argful_juggler#parser.match('{''foo'': grob, ''baz'': sog}')['value'].render()
" echo g:argful_juggler#parser.match('[''foo'', grob, ''baz'', sog]')['value'].render()
" echo g:argful_juggler#parser.match('(''foo'', grob, ''baz'', sog)')['value'].render()
" echo g:argful_juggler#parser.match('(''foo'', [grob, ''baz''], {''a'' : sog, ''b'' : dog})')['value'].render()
" echo argful_juggler#keyvalpair_node([argful_juggler#string_node('''a'''), ':', argful_juggler#string_node('"b"')]).render()

" echo argful_juggler#keyvalpair_node([argful_juggler#string_node('''a'''), ':', argful_juggler#string_node('"b"')]).rotate('a').render()

