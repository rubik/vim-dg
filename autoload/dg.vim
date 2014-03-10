" Language: dg
" Maintainer: Michele Lacchia
" License: MIT

function! dg#DgSetUpVariables()
  if !exists("g:dg_highlight_all")
    let g:dg_highlight_all = 1
  endif
  if exists("g:dg_highlight_all") && g:dg_highlight_all != 0
    " Not override previously set options
    if !exists("g:dg_highlight_builtins")
      if !exists("g:dg_highlight_builtin_objs")
        let g:dg_highlight_builtin_objs = 1
      endif
      if !exists("g:dg_highlight_builtin_funcs")
        let g:dg_highlight_builtin_funcs = 1
      endif
    else
      let g:dg_highlight_builtin_objs = g:dg_highlight_builtins
      let g:dg_highlight_builtin_funcs = g:dg_highlight_builtins
    endif
    if !exists("g:dg_highlight_exceptions")
      let g:dg_highlight_exceptions = 1
    endif
    if !exists("g:dg_highlight_indent_errors")
      let g:dg_highlight_indent_errors = 1
    endif
    if !exists("g:dg_highlight_space_errors")
      let g:dg_highlight_space_errors = 1
    endif
  endif
endfunction
