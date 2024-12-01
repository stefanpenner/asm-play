#!/usr/bin/env bash
set -euo pipefail

# Ensure gum is available
if ! command -v gum &>/dev/null; then
  echo "Error: gum is required but not installed."
  echo "Install with: brew install gum"
  exit 1
fi

# Create secure temporary file
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Generate new output
./hello >"$TMPFILE"

# Check if expected.txt exists
if [[ ! -f expected.txt ]]; then
  OPERATION="Create"
  OPERATION_PAST="Created"
  gum style --foreground 93 "⚠️  No existing expected.txt found"
  gum style --foreground 212 "New content will be:"
  gum style "$(cat "$TMPFILE")"
elif ! diff -q expected.txt "$TMPFILE" &>/dev/null; then
  OPERATION="Update"
  OPERATION_PAST="Updated"
  gum style --foreground 212 "Proposed changes:"
  diff -u --color expected.txt "$TMPFILE" || true
else
  gum style --foreground 82 "✓ No changes needed"
  exit 0
fi

# Prompt for confirmation
if gum confirm "$OPERATION expected.txt?"; then
  mv "$TMPFILE" expected.txt
  gum style --foreground 82 "✓ $OPERATION_PAST expected.txt"
else
  gum style --foreground 196 "✗ Cancelled"
  exit 0
fi
