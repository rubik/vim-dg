This project adds `dg <https://pyos.github.com/dg/>`_ support to Vim. It covers
syntax and indenting.

.. image:: https://f.cloud.github.com/assets/238549/2309409/7fd61788-a2d2-11e3-944d-deeea65bcff9.png
   :alt: Syntax highlighting for dg with the Solarized Dark colorscheme.
   :align: center

Syntax highlighting for dg with the Solarized Dark colorscheme.

----

**Table of Contents**

.. contents::
   :local:
   :depth: 2
   :backlinks: none


Installation
------------

Using Pathogen
++++++++++++++

Just make sure you have the following lines in your `.vimrc`:

.. code-block:: vim

    call pathogen#infect()
    syntax enable
    filetype plugin indent on

And then install `vim-dg` as any other Pathogen plugin.

Using Vundle
++++++++++++

Check that you have the following lines (in this order) in your `.vimrc`:

.. code-block:: vim

    set nocompatible
    filetype off

    set rtp+=$HOME/.vim/bundle/vundle/
    call vundle#rc

    " let Vundle manage Vundle, required
    Bundle 'gmarik/vundle'

    Bundle 'rubik/vim-dg'

    syntax enable
    filetype plugin indent on

Then run `:BundleInstall` and you're ready to go.

From a zip file
+++++++++++++++

1. Download the latest zip from Githu
2. Extract the archive into `~/.vim`::

    unzip -od ~/.vim/ ARCHIVE.zip

   This should create the files `~/.vim/autoload/dg.vim`, `~/.vim/indent/dg.vim`, etc

You can update the plugin using the same steps.

Configuration variables
-----------------------

This is the full list of configuration variables available, with example
settings and default values. Use these in your vimrc to control the default
behavior.

Indenting
+++++++++

**dg_indent_keep_current**

By default, the indent function matches the indent of the previous line if it
doesn't find a reason to indent or outdent. To change this behavior so it
instead keeps the current indent of the cursor, use

    let dg_indent_keep_current = 1

*Default*: ``unlet dg_indent_keep_current``

Note that if you change this after a dg file has been loaded, you'll have to
reload the indent script for the change to take effect::

    unlet b:did_indent | runtime indent/dg.vim


Highlighting
++++++++++++

**dg_highlight_all**

If unset or set to `1``, every other highlight-related variable will be set to
`1`` (but only if unset).

*Default*: ```let g:dg_highlight_all = 1```

**dg_highlight_builtins**

If set and true, the other builtin-related variables will be set to true (only
if unset).

*Default*: ``let g:dg_highlight_builtins = 1``

**dg_highlight_builtin_objs**

If set to true, Vim will highlight built-in objects like `True`, `False`,
`None`, etc.

*Default*: ``let g:dg_highlight_builtin_objs = 1``

**dg_highlight_builtin_funcs**

If set to true, Vim will also highlight built-in functions.

*Default*: ``let g:dg_highlight_builtin_funcs = 1``

**dg_highlight_exceptions**

If set to true, Vim will highlight built-in exceptions.

*Default*: ``let g:dg_highlight_exceptions = 1``

**dg_highlight_indent_errors**

If set to true, Vim will highlight indenting errors (like mixing tabs and
spaces).

*Default*: ``let g:dg_highlight_indent_errors = 1``

**dg_highlight_space_errors**

If set to true, Vim will highlight whitespace errors.

*Default*: ``let g:dg_highlight_space_errors = 1``

So, if you don't touch anything, Vim will set these vars for you:

.. code-block:: vim

    let g:dg_highlight_builtin_objs = 1
    let g:dg_highlight_builtin_funcs = 1
    let g:dg_highlight_exceptions = 1
    let g:dg_highlight_indent_errors = 1
    let g:dg_highlight_space_errors = 1
