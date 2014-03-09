" Language: dg
" Maintainer: Michele Lacchia
" License: MIT

if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=GetDgIndent(v:lnum)
" Make sure GetDgIndent is run when these are typed so they can be indented or
" outdented
setlocal indentkeys+=0],0),0.,->,~>,=>
setlocal indentkeys+==except,=where,=if

" If no indenting or outdenting is needed, either keep the indent of the cursor
" (use autoindent) or match the indent of the previous line.
if exists('g:dg_indent_keep_current')
  let s:DEFAULT_LEVEL = '-1'
else
  let s:DEFAULT_LEVEL = 'indent(prevnlnum)'
endif

" Keywords that begin a block
let s:BEGIN_BLOCK_KEYWORD = '\C\%(if\|where\|except\|finally\)\s*\(#\.*\)\?'

" Operators that begin a block but also count as a continuation
let s:BEGIN_BLOCK_OP = '[([{:=]$'

" Begins a function/method block
let s:FUNCTION = '[-=~]>$'

" Operators that continue a line onto the next line
let s:CONTINUATION_OP = '\C\%(\<\%(is\|is not\|and\|or\)\>\|'
\                     . '[^-]-\|[^+]+\|[^-=]>\|[^.]\.\|[<*/%&|^,]\)$'

" Ancestor operators that prevent continuation indenting
let s:CONTINUATION = s:CONTINUATION_OP . '\|' . s:BEGIN_BLOCK_OP

" A closing bracket by itself on a line followed by a continuation
let s:BRACKET_CONTINUATION = '^\s*[}\])]\s*' . s:CONTINUATION_OP

" A continuation dot access
let s:DOT_ACCESS = '^\.'

" Keywords that break out of a block
let s:BREAK_BLOCK_OP = '\C^\%(break\|continue\|raise\)\>'

" A condition attached to the end of a statement
let s:POSTFIX_CONDITION = '\C\S\s\+\zs\<\%(if\|where\|for\|while\)\>'

" A then contained in brackets
"let s:CONTAINED_THEN = '\C[(\[].\{-}\<then\>.\{-\}[)\]]'

" An else with a condition attached
"let s:ELSE_COND = '\C^\s*else\s\+\<\%(if\|unless\)\>'

" A single-line else statement (without a condition attached)
let s:SINGLE_LINE_ELSE = '\C^otherwise\s\+\%(\<if\>\)\@!'

" Pairs of starting and ending keywords, with an initial pattern to match
"let s:KEYWORD_PAIRS = [
"\  ['\C^else\>', '\C\<\%(if\|unless\|when\|else\s\+\%(if\|unless\)\)\>',
"\   '\C\<else\>'],
"\  ['\C^catch\>', '\C\<try\>', '\C\<catch\>'],
"\  ['\C^finally\>', '\C\<try\>', '\C\<finally\>']
"\]

" Pairs of starting and ending brackets
let s:BRACKET_PAIRS = {'}': '{', ')': '('}

" Max lines to look back for a match
let s:MAX_LOOKBACK = 50

" Syntax names for strings
let s:SYNTAX_STRING = 'dg\%(String\)'

" Syntax names for comments
let s:SYNTAX_COMMENT = 'dg\%(Comment\)'

" Syntax names for strings and comments
let s:SYNTAX_STRING_COMMENT = s:SYNTAX_STRING . '\|' . s:SYNTAX_COMMENT

" Compatibility code for shiftwidth() as recommended by the docs, but modified
" so there isn't as much of a penalty if shiftwidth() exists.
if exists('*shiftwidth')
  let s:ShiftWidth = function('shiftwidth')
else
  function! s:ShiftWidth()
    return &shiftwidth
  endfunction
endif

" Get the linked syntax name of a character.
function! s:SyntaxName(lnum, col)
  return synIDattr(synID(a:lnum, a:col, 1), 'name')
endfunction

" Check if a character is in a comment.
function! s:IsComment(lnum, col)
  return s:SyntaxName(a:lnum, a:col) =~ s:SYNTAX_COMMENT
endfunction

" Check if a character is in a string.
function! s:IsString(lnum, col)
  return s:SyntaxName(a:lnum, a:col) =~ s:SYNTAX_STRING
endfunction

" Check if a character is in a comment or string.
function! s:IsCommentOrString(lnum, col)
  return s:SyntaxName(a:lnum, a:col) =~ s:SYNTAX_STRING_COMMENT
endfunction

" Search a line for a regex until one is found outside a string or comment.
function! s:SearchCode(lnum, regex)
  " Start at the first column and look for an initial match (including at the
  " cursor.)
  call cursor(a:lnum, 1)
  let pos = search(a:regex, 'c', a:lnum)

  while pos
    if !s:IsCommentOrString(a:lnum, col('.'))
      return 1
    endif

    " Move to the match and continue searching (don't accept matches at the
    " cursor.)
    let pos = search(a:regex, '', a:lnum)
  endwhile

  return 0
endfunction

" Search for the nearest previous line that isn't a comment.
function! s:GetPrevNormalLine(startlnum)
  let curlnum = a:startlnum

  while curlnum
    let curlnum = prevnonblank(curlnum - 1)

    " Return the line if the first non-whitespace character isn't a comment.
    if !s:IsComment(curlnum, indent(curlnum) + 1)
      return curlnum
    endif
  endwhile

  return 0
endfunction

function! s:SearchPair(startlnum, lookback, skip, open, close)
  " Go to the first column so a:close will be matched even if it's at the
  " beginning of the line.
  call cursor(a:startlnum, 1)
  return searchpair(a:open, '', a:close, 'bnW', a:skip, max([1, a:lookback]))
endfunction

" Skip if a match
"  - is in a string or comment
"  - is a single-line statement that isn't immediately
"    adjacent
"  - has a postfix condition and isn't an else statement or compound
"    expression
function! s:ShouldSkip(startlnum, lnum, col)
  return s:IsCommentOrString(a:lnum, a:col) ||
  \      s:SearchCode(a:lnum, s:POSTFIX_CONDITION) &&
  \     !s:SearchCode(a:lnum, s:COMPOUND_EXPRESSION)
endfunction

" Search for the nearest and farthest match for a keyword pair.
function! s:SearchMatchingKeyword(startlnum, open, close)
  let skip = 's:ShouldSkip(' . a:startlnum . ", line('.'), line('.'))"

  " Search for the nearest match.
  let nearestlnum = s:SearchPair(a:startlnum, a:startlnum - s:MAX_LOOKBACK,
  \                              skip, a:open, a:close)

  if !nearestlnum
    return []
  endif

  " Find the nearest previous line with indent less than or equal to startlnum.
  let ind = indent(a:startlnum)
  let lookback = s:GetPrevNormalLine(a:startlnum)

  while lookback && indent(lookback) > ind
    let lookback = s:GetPrevNormalLine(lookback)
  endwhile

  " Search for the farthest match. If there are no other matches, then the
  " nearest match is also the farthest one.
  let matchlnum = nearestlnum

  while matchlnum
    let lnum = matchlnum
    let matchlnum = s:SearchPair(matchlnum, lookback, skip, a:open, a:close)
  endwhile

  return [nearestlnum, lnum]
endfunction

" Strip a line of a trailing comment and surrounding whitespace.
function! s:GetTrimmedLine(lnum)
  " Try to find a comment starting at the first column.
  call cursor(a:lnum, 1)
  let pos = search('#', 'c', a:lnum)

  " Keep searching until a comment is found or search returns 0.
  while pos
    if s:IsComment(a:lnum, col('.'))
      break
    endif

    let pos = search('#', '', a:lnum)
  endwhile

  if !pos
    " No comment was found so use the whole line.
    let line = getline(a:lnum)
  else
    " Subtract 1 to get to the column before the comment and another 1 for
    " column indexing -> zero-based indexing.
    let line = getline(a:lnum)[:col('.') - 2]
  endif

  return substitute(substitute(line, '^\s\+', '', ''),
  \                                  '\s\+$', '', '')
endfunction

" Get the indent policy when no special rules are used.
function! s:GetDefaultPolicy(curlnum)
  " Check whether equalprg is being ran on existing lines.
  if strlen(getline(a:curlnum)) == indent(a:curlnum)
    " If not indenting an existing line, use the default policy.
    return s:DEFAULT_LEVEL
  else
    " Otherwise let autoindent determine what to do with an existing line.
    return '-1'
  endif
endfunction

function! GetDgIndent(curlnum)
  " Get the previous non-blank line (may be a comment.)
  let prevlnum = prevnonblank(a:curlnum - 1)

  " Bail if there's no code before.
  if !prevlnum
    return -1
  endif

  " Bail if inside a multiline string.
  if s:IsString(a:curlnum, 1)
    let prevnlnum = prevlnum
    exec 'return' s:GetDefaultPolicy(a:curlnum)
  endif

  " Get the code part of the current line.
  let curline = s:GetTrimmedLine(a:curlnum)
  " Get the previous non-comment line.
  let prevnlnum = s:GetPrevNormalLine(a:curlnum)

  " Check if the current line is the closing bracket in a bracket pair.
  if has_key(s:BRACKET_PAIRS, curline[0])
    " Search for a matching opening bracket.
    let matchlnum = s:SearchPair(a:curlnum, a:curlnum - s:MAX_LOOKBACK,
    \                            "s:IsCommentOrString(line('.'), col('.'))",
    \                            s:BRACKET_PAIRS[curline[0]], curline[0])

    if matchlnum
      " Match the indent of the opening bracket.
      return indent(matchlnum)
    else
      " No opening bracket found (bad syntax), so bail.
      exec 'return' s:GetDefaultPolicy(a:curlnum)
    endif
  endif

  " If the previous line is a comment, use its indentation, but don't force
  " indenting.
  if prevlnum != prevnlnum
    return min([indent(a:curlnum), indent(prevlnum)])
  endif

  let prevline = s:GetTrimmedLine(prevnlnum)

  " Always indent after these operators.
  if prevline =~ s:BEGIN_BLOCK_OP
    return indent(prevnlnum) + s:ShiftWidth()
  endif

  " Indent if the previous line starts a function block, but don't force
  " indenting if the line is non-blank (for empty function bodies.)
  if prevline =~ s:FUNCTION
    if strlen(getline(a:curlnum)) > indent(a:curlnum)
      return min([indent(prevnlnum) + s:ShiftWidth(), indent(a:curlnum)])
    else
      return indent(prevnlnum) + s:ShiftWidth()
    endif
  endif

  " Check if continuation indenting is needed. If the line ends in a slash, make
  " sure it isn't a regex.
  if prevline =~ s:CONTINUATION_OP &&
  \  !(prevline =~ '/$' && s:IsString(prevnlnum, col([prevnlnum, '$']) - 1))
    " Don't indent if the continuation follows a closing bracket.
    if prevline =~ s:BRACKET_CONTINUATION
      exec 'return' s:GetDefaultPolicy(a:curlnum)
    endif

    let prevprevnlnum = s:GetPrevNormalLine(prevnlnum)

    " Don't indent if not the first continuation.
    if prevprevnlnum && s:GetTrimmedLine(prevprevnlnum) =~ s:CONTINUATION
      exec 'return' s:GetDefaultPolicy(a:curlnum)
    endif

    " Continuation indenting seems to vary between programmers, so if the line
    " is non-blank, don't override the indentation
    if strlen(getline(a:curlnum)) > indent(a:curlnum)
      exec 'return' s:GetDefaultPolicy(a:curlnum)
    endif

    " Otherwise indent a level.
    return indent(prevnlnum) + s:ShiftWidth()
  endif

  " Check if the previous line starts with a keyword that begins a block.
  if prevline =~ s:BEGIN_BLOCK_KEYWORD
    return indent(prevnlnum) + s:ShiftWidth()
  endif

  " Indent a dot access if it's the first.
  if curline =~ s:DOT_ACCESS
    if prevline !~ s:DOT_ACCESS
      return indent(prevnlnum) + s:ShiftWidth()
    else
      exec 'return' s:GetDefaultPolicy(a:curlnum)
    endif
  endif

  " Outdent if a keyword breaks out of a block as long as it doesn't have a
  " postfix condition (and the postfix condition isn't a single-line statement.)
  if prevline =~ s:BREAK_BLOCK_OP
    if !s:SearchCode(prevnlnum, s:POSTFIX_CONDITION)
      " Don't force indenting.
      return min([indent(a:curlnum), indent(prevnlnum) - s:ShiftWidth()])
    else
      exec 'return' s:GetDefaultPolicy(a:curlnum)
    endif
  endif

  " Check if inside brackets.
  let matchlnum = s:SearchPair(a:curlnum, a:curlnum - s:MAX_LOOKBACK,
  \                            "s:IsCommentOrString(line('.'), col('.'))",
  \                            '\[\|(\|{', '\]\|)\|}')

  " If inside brackets, indent relative to the brackets, but don't outdent an
  " already indented line.
  if matchlnum
    return max([indent(a:curlnum), indent(matchlnum) + s:ShiftWidth()])
  endif

  " No special rules applied, so use the default policy.
  exec 'return' s:GetDefaultPolicy(a:curlnum)
endfunction
