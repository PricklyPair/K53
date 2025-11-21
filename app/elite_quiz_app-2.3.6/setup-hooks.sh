#!/bin/sh

echo "Setting up Git hooks..."

HOOKS_DIR=".githooks"
TARGET_DIR=".git/hooks"

if [ -d "$HOOKS_DIR" ]; then
  for hook in "$HOOKS_DIR"/*; do
    hook_name=$(basename "$hook")
    ln -sf "../../$HOOKS_DIR/$hook_name" "$TARGET_DIR/$hook_name"
    echo "Installed $hook_name hook"
  done
else
  echo "Hooks directory $HOOKS_DIR does not exist."
fi
