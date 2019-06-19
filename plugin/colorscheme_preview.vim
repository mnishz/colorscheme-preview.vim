if exists('g:loaded_colorscheme_preview')
  finish
endif
let g:loaded_colorscheme_preview = 1

let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

command ColorschemePreview call colorscheme_preview#list_contents()

let &cpo = s:save_cpo
unlet s:save_cpo
