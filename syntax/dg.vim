" Vim syntax file
" Language: dg
" Maintainer: Michele Lacchia
" Latest Revision: #TODO

if exists("b:current_syntax")
    finish
endif

syn keyword operators ( ) - + / * ** -> <- $ @ . .~ & | // % ^ ~ !! !!~ ==
syn keyword operators or and not
syn match operators '`\w+`'
syn keyword specialOperator =>

let b:current_syntax = "dg"
