" Vim syntax file
" Language: dg
" Maintainer: Michele Lacchia
" License: MIT

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax") && b:current_syntax == 'dg'
  finish
endif

call dg#DgSetUpVariables()

syn match dgOperator "\(==\|!=\|>=\|<=\|\.\~\?\|!!\~\?\|>\|<\)" skipwhite
syn match dgOperator "\(!!\||\|&\|/\|//\|\^\|\*\*\?\|<<\|>>\|[-+.%]\)=\?" skipwhite
syn match dgOperator "\(::\|:=\|\~\|:+\|+:\)" skipwhite
syn keyword dgOperator or and not is in
syn match dgSpecialOperator "\(=>\|\$\|->\|\~>\|<-\)"

" Numbers (ints, longs, floats, complex)
syn match dgHexNumber "\<0[xX]\x\+[lL]\=\>" display
syn match dgOctNumber "\<0[oO]\o\+[lL]\=\>" display
syn match dgBinNumber "\<0[bB][01]\+[lL]\=\>" display
syn match dgNumber "\<\d\+[lLjJ]\=\>" display
syn match dgFloat "\.\d\+\([eE][+-]\=\d\+\)\=[jJ]\=\>" display
syn match dgFloat "\<\d\+[eE][+-]\=\d\+[jJ]\=\>" display
syn match dgFloat "\<\d\+\.\d*\([eE][+-]\=\d\+\)\=[jJ]\=" display
syn match dgOctError "\<0[oO]\=\o*[8-9]\d*[lL]\=\>" display
syn match dgBinError "\<0[bB][01]*[2-9]\d*[lL]\=\>" display
syn match dgHexError "\<0[xX]\x*[g-zG-Z]\x*[lL]\=\>" display

" Builtins
if g:dg_highlight_builtin_objs != 0
  syn keyword dgBuiltinObj True False Ellipsis None NotImplemented
  syn keyword dgBuiltinObj __debug__ __doc__ __file__ __name__ __package__
endif

if g:dg_highlight_builtin_funcs != 0
  syn keyword dgBuiltinFunc __import__ abs all any ascii bin bool
  syn keyword dgBuiltinFunc bytearray bytes callable chr classmethod compile
  syn keyword dgBuiltinFunc complex delattr dict dir divmod
  syn keyword dgBuiltinFunc enumerate exec eval filter float format frozenset
  syn keyword dgBuiltinFunc getattr globals hasattr hash help hex id input int
  syn keyword dgBuiltinFunc isinstance issubclass iter len list
  syn keyword dgBuiltinFunc locals map max memoryview min next object oct open
  syn keyword dgBuiltinFunc ord pow print property range repr reversed round set
  syn keyword dgBuiltinFunc setattr slice sorted staticmethod str sum super tuple
  syn keyword dgBuiltinFunc type vars zip

  " dg-specific builtins
  syn keyword dgBuiltinFunc bind break continue flip foldl foldl1 drop dropwhile
  syn keyword dgBuiltinFunc iterate scanl scanl1 take takewhile
  syn keyword dgBuiltinFunc exhaust head fst snd tail init last
  syn match dgBuiltinFunc /list'/
  syn match dgBuiltinFunc /tuple'/
  syn match dgBuiltinFunc /dict'/
  syn match dgBuiltinFunc /set'/
endif

if g:dg_highlight_exceptions != 0
  " Builtin exceptions and warnings
  syn keyword dgExClass BaseException
  syn keyword dgExClass Exception StandardError ArithmeticError
  syn keyword dgExClass LookupError EnvironmentError

  syn keyword dgExClass AssertionError AttributeError BufferError EOFError
  syn keyword dgExClass FloatingPointError GeneratorExit IOError
  syn keyword dgExClass ImportError IndexError KeyError
  syn keyword dgExClass KeyboardInterrupt MemoryError NameError
  syn keyword dgExClass NotImplementedError OSError OverflowError
  syn keyword dgExClass ReferenceError RuntimeError StopIteration
  syn keyword dgExClass SyntaxError IndentationError TabError
  syn keyword dgExClass SystemError SystemExit TypeError
  syn keyword dgExClass UnboundLocalError UnicodeError
  syn keyword dgExClass UnicodeEncodeError UnicodeDecodeError
  syn keyword dgExClass UnicodeTranslateError ValueError VMSError
  syn keyword dgExClass WindowsError ZeroDivisionError

  syn keyword dgExClass Warning UserWarning BytesWarning DeprecationWarning
  syn keyword dgExClass PendingDepricationWarning SyntaxWarning
  syn keyword dgExClass RuntimeWarning FutureWarning
  syn keyword dgExClass ImportWarning UnicodeWarning
endif

syn region dgBacktick start="`" end="`" keepend

" Statements
syn keyword dgStatement if while for where subclass yield qualified import
syn keyword dgStatement otherwise raise except with finally

" Comments
syn match dgComment "#.*$" display

" Strings
syn region dgString start=+\%(\w\@<!\|\<[bB]\)'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=dgEscape,dgEscapeError
syn region dgString start=+[bB]\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=dgEscape,dgEscapeError
syn region dgString start=+[bB]\="""+ end=+"""+ keepend contains=dgEscape,dgEscapeError
syn region dgString start=+[bB]\='''+ end=+'''+ keepend contains=dgEscape,dgEscapeError

syn match  dgEscape +\\[abfnrtv'"\\]+ display contained
syn match  dgEscape "\\\o\o\=\o\=" display contained
syn match  dgEscapeError "\\\o\{,2}[89]" display contained
syn match  dgEscape "\\x\x\{2}" display contained
syn match  dgEscapeError "\\x\x\=\X" display contained
syn match  dgEscape "\\$"

" TODO: Mixing spaces and tabs also may be used for pretty formatting multiline
" statements. For now I don't know how to work around this.
if g:dg_highlight_indent_errors != 0
  syn match dgIndentError "^\s*\( \t\|\t \)\s*\S"me=e-1 display
endif

" Trailing space errors
if g:dg_highlight_space_errors != 0
  syn match dgSpaceError "\s\+$" display
endif


if version >= 508 || !exists("did_dg_syn_inits")
  if version <= 508
    let did_dg_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

    HiLink dgOperator Operator
    HiLink dgStatement Statement
    HiLink dgSpecialOperator Special
    HiLink dgString String
    HiLink dgEscape Special
    HiLink dgEscapeError Error
    HiLink dgComment Comment
    HiLink dgNumber Number
    HiLink dgBinNumber Number
    HiLink dgOctNumber Number
    HiLink dgHexNumber Number
    HiLink dgFloat Number
    HiLink dgBinError Error
    HiLink dgHexError Error
    HiLink dgOctError Error
    HiLink dgIndentError Error
    HiLink dgSpaceError Error
    HiLink dgExClass Exception

    HiLink dgBuiltinObj Structure
    HiLink dgBuiltinFunc Function
    HiLink dgBacktick Underlined
  delcommand HiLink
endif

let b:current_syntax = 'dg'
