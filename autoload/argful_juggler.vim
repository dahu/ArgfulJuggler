" Abstract base node. All other nodes inherit (directly or eventually) from
" ast_node
function! argful_juggler#ast_node()
  let node = {}
  let node.type = 'UNASSIGNED_TYPE'
  let node.value = 'UNASSIGNED_VALUE'
  func node.render() dict
    if type(self.value) == type({}) && has_key(self, 'render')
      return self.render()
    else
      return self.value
    endif
  endfunc
  func node.rotate(dir) dict
    " by default, rotate() is a NOP for most nodes
    return self
  endfunc
  func node.new(elem) dict
    let self.value = a:elem
    return self
  endfunc
  return node
endfunction

function! argful_juggler#string_node(elem)
  let node = argful_juggler#ast_node()
  let node.type = 'string'
  return node.new(a:elem)
endfunction

function! argful_juggler#identifier_node(elem)
  let node = argful_juggler#ast_node()
  let node.type = 'identifier'
  return node.new(a:elem)
endfunction

function! argful_juggler#keyvalpair_node(elem)
  let node = argful_juggler#ast_node()
  let node.type = 'keyvalpair'
  func! node.render() dict
    return self.key.render() . ' : ' . self.value.render()
  endfunc
  " dubious useflness - rotating a keyvalpair swaps the key and val
  " Note: Not aware of datatypes, so this can cause invalid datastructures.
  " Use with care
  " Note: dir is a useless notion with a two-element collection
  func! node.rotate(...) dict
    let t = self.key
    let self.key = self.value
    let self.value = t
    return self
  endfunc
  func! node.new(elem) dict
    let self.key = a:elem[0]
    let self.value = a:elem[2]
    return self
  endfunc
  return node.new(a:elem)
endfunction

" Abstract collection node used by concrete collection types:
"   list, argument_list and dictionary
function! argful_juggler#paren_node()
  let node = argful_juggler#ast_node()
  let node.type = 'UNASSIGNED_PAREN_TYPE'
  let node.open_bracket = 'UNASSIGNED'
  func! node.render() dict
    let s = ''
    for e in self.value
      let s .= ((s == '') ? '' : ', ') . e.render()
    endfor
    return self.open_bracket . s . {'(':')','[':']','{':'}'}[self.open_bracket]
  endfunc
  " much firmer ground rotating a collection
  " dir == 1 -> rotate right
  func! node.rotate(dir) dict
    " plan to use logic like: add(copy(self.value[1:-1]), self.value[0])
    return self
  endfunc
  func! node.new(elem) dict
    let self.open_bracket = a:elem[0]
    let self.value = a:elem[1]
    return self
  endfunc
  return node
endfunction

function! argful_juggler#argument_list_node(elem)
  let node = argful_juggler#paren_node()
  let node.type = 'argument_list'
  return node.new(a:elem)
endfunction

function! argful_juggler#list_node(elem)
  let node = argful_juggler#paren_node()
  let node.type = 'list'
  return node.new(a:elem)
endfunction

function! argful_juggler#dictionary_node(elem)
  let node = argful_juggler#paren_node()
  let node.type = 'dictionary'
  return node.new(a:elem)
endfunction

function! argful_juggler#build_paren_node(elem)
  let type = a:elem[0]
  if type == '('
    return argful_juggler#argument_list_node(a:elem)
  elseif type == '['
    return argful_juggler#list_node(a:elem)
  elseif type == '{'
    return argful_juggler#dictionary_node(a:elem)
  else
    echoerr "Unknown paren object: " . string(a:elem)
  endif
endfunction

function! s:collect(elems)
  return map(a:elems, 'v:val[1]')
endfunction

function! s:join(elems)
  return join(map(a:elems, 'v:val[1]'), '')
endfunction

function! s:wrap(elems, left, right)
  return a:left . s:join(a:elems) . a:right
endfunction

function! argful_juggler#list(elems)
  return extend([a:elems[0]], s:collect(a:elems[1]))
endfunction

function! argful_juggler#string(elems)
  return argful_juggler#string_node(s:wrap(a:elems[1], a:elems[0], a:elems[0]))
endfunction

function! argful_juggler#identifier(elems)
  return argful_juggler#identifier_node(s:join(a:elems))
endfunction

function! argful_juggler#paren(elems)
  return argful_juggler#build_paren_node([a:elems[0], a:elems[1][0], a:elems[2]])
endfunction

function! argful_juggler#keyvalpair(elems)
  return argful_juggler#keyvalpair_node([a:elems[0], ':', a:elems[2]])
endfunction
