#!/usr/bin/env bash
# Install this workflow's Claude Code plugins into this folder.
# Run it once after cloning, and again after every `git pull`.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v git >/dev/null; then
    echo "git is not installed. Install it first: https://git-scm.com/downloads" >&2
    exit 1
fi
if ! command -v claude >/dev/null; then
    echo "Claude Code is not installed. Install it first:" >&2
    echo "  https://docs.claude.com/en/docs/claude-code/setup" >&2
    exit 1
fi
if ! command -v uv >/dev/null; then
    echo "Installing uv (runs the plugin installer)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

uv run --quiet cs-plugin sync

echo
echo "Done. Start Claude Code in this folder (or restart it if it is open):"
echo "  claude"
