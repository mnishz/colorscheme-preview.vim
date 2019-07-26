scriptencoding utf-8

let s:color_selected = v:false
let s:org_highlight = []
const s:NUM_HELP_LINES = 4

function colorscheme_preview#list_contents() abort
  let s:color_selected = v:false
  call s:save_highlight()
  let l:ctx = s:show_popup()
  call s:add_contents(l:ctx, 'move: j, k')
  call s:add_contents(l:ctx, 'select: <CR>, <Space>')
  " <C-c> doesn't call callback function???
  " call s:add_contents(l:ctx, 'cancel: <Esc>, <C-c>, x')
  call s:add_contents(l:ctx, 'cancel: <Esc>, x')
  call s:add_contents(l:ctx, '')
  call s:add_contents(l:ctx, '(original)')
  for color in getcompletion('', 'color')
    call s:add_contents(l:ctx, color)
  endfor
  let l:ctx.curr_idx = s:NUM_HELP_LINES
  call s:update_contents(l:ctx)
endfunction

function s:show_popup() abort
  let l:ctx = {'curr_idx': 0, 'contents': [], 'wid': 0}
  let l:ctx.wid = popup_create(l:ctx.contents, {
        \ 'title': ' colorscheme-preview ',
        \ 'border': [],
        \ 'padding': [],
        \ 'filter': function('s:popup_filter', [l:ctx]),
        \ 'callback': 's:closing_handler',
        \})
  return l:ctx
endfunction

function s:add_contents(ctx, n) abort
  call add(a:ctx.contents, a:n)
endfunction

function s:update_contents(ctx) abort
  if a:ctx.curr_idx <= s:NUM_HELP_LINES
    call s:restore_highlight()
  else
    execute 'colorscheme ' .. a:ctx.contents[a:ctx.curr_idx]
  endif
  let l:buf = winbufnr(a:ctx.wid)
  let l:contents = map(copy(a:ctx.contents), '(v:key == a:ctx.curr_idx ? "->" : "  ") .. v:val')
  call setbufline(l:buf, 1, l:contents)
endfunction

function s:popup_filter(ctx, wid, c) abort
  if a:c ==# 'j'
    let a:ctx.curr_idx += a:ctx.curr_idx ==# len(a:ctx.contents)-1 ? 0 : 1
    call s:update_contents(a:ctx)
  elseif a:c ==# 'k'
    let a:ctx.curr_idx -= a:ctx.curr_idx ==# s:NUM_HELP_LINES ? 0 : 1
    call s:update_contents(a:ctx)
  elseif a:c ==# "\n" || a:c ==# "\r" || a:c ==# ' '
    let s:color_selected = v:true
    call popup_close(a:wid)
  elseif a:c ==# 'x' || a:c ==# "\x1b"
    call popup_close(a:wid)
  endif
  return 1
endfunction

function s:closing_handler(id, result) abort
  if s:color_selected
    echo 'colorscheme selected'
  else
    call s:restore_highlight()
    redraw
    echo 'colorscheme restored'
  endif
endfunction

function s:save_highlight() abort
  let s:org_highlight = []
  for hi_group in getcompletion('', 'highlight')
    " join(split()) removes '^@' in the text. Is there any better way?
    let s:org_highlight += [join(split(execute('highlight ' .. hi_group)))]
  endfor
endfunction

function s:restore_highlight() abort
  for hi_group in getcompletion('', 'highlight')
    execute 'highlight clear ' .. hi_group
  endfor
  for hi_group in s:org_highlight
    if hi_group =~# 'xxx cleared'
    elseif hi_group =~# 'xxx links'
    else
      let l:xxx_idx = stridx(hi_group, 'xxx ')
      let l:hi_name = hi_group[:l:xxx_idx-1]
      let l:hi_pattern = hi_group[l:xxx_idx+4:]
      execute 'hi ' .. l:hi_name .. ' ' .. l:hi_pattern
    endif
  endfor
endfunction
