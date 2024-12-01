#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Colors and styles
readonly GREEN=82
readonly YELLOW=93
readonly BLUE=212
readonly RED=196

# Configuration
readonly EXPECTED_FILE="expected.txt"
readonly BINARY="./hello"

die() {
    gum style --foreground "$RED" "❌ Error: $1"
    exit 1
}

check_dependencies() {
    if ! command -v gum &>/dev/null; then
        echo "Error: gum is required but not installed."
        echo "Install with: brew install gum"
        exit 1
    }

    if [[ ! -x "$BINARY" ]]; then
        die "Binary $BINARY not found or not executable"
    }
}

generate_output() {
    local tmpfile=$1
    if ! "$BINARY" > "$tmpfile" 2>&1; then
        die "Failed to generate output from $BINARY"
    }
}

show_preview() {
    local tmpfile=$1
    if [[ ! -f "$EXPECTED_FILE" ]]; then
        gum style --foreground "$YELLOW" "⚠️  No existing $EXPECTED_FILE found"
        gum style --foreground "$BLUE" "New content will be:"
        gum style --border normal --padding "1 2" "$(cat "$tmpfile")"
        echo
        return 0
    fi

    if ! diff -q "$EXPECTED_FILE" "$tmpfile" &>/dev/null; then
        gum style --foreground "$BLUE" "Proposed changes:"
        diff -u --color "$EXPECTED_FILE" "$tmpfile" || true
        echo
        return 0
    fi

    gum style --foreground "$GREEN" "✓ No changes needed"
    return 1
}

main() {
    check_dependencies

    local tmpfile
    tmpfile=$(mktemp)
    trap 'rm -f "$tmpfile"' EXIT

    generate_output "$tmpfile"

    local operation operation_past
    if [[ ! -f "$EXPECTED_FILE" ]]; then
        operation="Create"
        operation_past="Created"
    else
        operation="Update"
        operation_past="Updated"
    fi

    show_preview "$tmpfile" || exit 0

    if gum confirm "$operation $EXPECTED_FILE?"; then
        mv "$tmpfile" "$EXPECTED_FILE"
        gum style --foreground "$GREEN" "✓ $operation_past $EXPECTED_FILE"
    else
        gum style --foreground "$RED" "✗ Cancelled"
        exit 0
    fi
}

main "$@"
