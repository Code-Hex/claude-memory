#!/bin/bash

mkdir -p ~/.claude/docs

ln -s $(realpath "CLAUDE.md") $HOME/.claude/CLAUDE.md

find docs -type f -name "*.md" -exec bash -c '
  target="$HOME/.claude/$1"
  mkdir -p "$(dirname "$target")"
  ln -s "$(realpath "$1")" "$target"
' bash {} \;
