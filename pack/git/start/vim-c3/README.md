# C3 Vim Plugin

Filetype detection, syntax highlighting, and compiler integration for C3.

## Install

Copy the contents into `~/.vim`:

```bash
cp -r . ~/.vim
```

## Compiler

To use `:make` with `c3c`, add to your `~/.vimrc`:

```vim
autocmd FileType c3 compiler c3c
```
