" Vim Plugin for opening specification files
" Maintainer: Fabio Pelosin <fabiopelosin@gmail.com>
" Version: 0.1.0

if exists("g:rubyspec_plugin_loaded")
  finish
endif
let g:rubyspec_plugin_loaded = 1


if !hasmapto("rubyspec#VOpenRelated()")
  " && empty(mapcheck("gK", "n"))
  nnoremap <C-s> :call rubyspec#VOpenRelated()<CR>
endif
