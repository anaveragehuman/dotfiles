setlocal iskeyword+=:,-
setlocal makeprg=pdflatex\ -file-line-error\ -interaction=nonstopmode\ %
inoremap <buffer> { {}<ESC>i
inoremap <buffer> [ []<ESC>i
