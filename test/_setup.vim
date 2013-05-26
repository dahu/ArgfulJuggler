for plugin in [expand('<sfile>:p:h:h'), expand('<sfile>:p:h:h:h') . '/Vimpeg']
  let &rtp = plugin . ',' . &rtp . ',' . plugin . '/after'
endfor

runtime autoload/vimpeg.vim
runtime autoload/argful_juggler.vim
runtime autoload/argful_juggler_grammar.vim
