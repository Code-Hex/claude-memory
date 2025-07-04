#!/bin/bash

mkdir -p ~/.claude/docs
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/hooks

ln -s $(realpath "CLAUDE.md") $HOME/.claude/CLAUDE.md
ln -s $(realpath "settings.json") $HOME/.claude/settings.json

find docs -type f -name "*.md" -exec bash -c '
  target="$HOME/.claude/$1"
  mkdir -p "$(dirname "$target")"
  ln -s "$(realpath "$1")" "$target"
' bash {} \;

find commands -type f -name "*.md" -exec bash -c '
  target="$HOME/.claude/$1"
  mkdir -p "$(dirname "$target")"
  ln -s "$(realpath "$1")" "$target"
' bash {} \;

find hooks -type f -name "*.sh" -exec bash -c '
  target="$HOME/.claude/$1"
  mkdir -p "$(dirname "$target")"
  ln -s "$(realpath "$1")" "$target"
' bash {} \;
