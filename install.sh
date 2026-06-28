#!/usr/bin/env bash
# Install the `disconfirm` Claude Code skill (+ optional auto-invoke hook).
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SRC="$(cd "$(dirname "$0")" && pwd)"

echo "Installing disconfirm into: $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/hooks"

cp -r "$SRC/skills/disconfirm" "$CLAUDE_DIR/skills/"
echo "  ok   skill  ->  $CLAUDE_DIR/skills/disconfirm/SKILL.md"

cp "$SRC/hooks/disconfirm-nudge.py" "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/disconfirm-nudge.py"
echo "  ok   hook   ->  $CLAUDE_DIR/hooks/disconfirm-nudge.py"

cat <<'SNIP'

Skill installed. To make Claude reach for it automatically on research /
comparison / "is this right?" prompts, add this to ~/.claude/settings.json
under "hooks" (full example in hooks/settings.example.json):

  "UserPromptSubmit": [
    { "hooks": [ { "type": "command", "command": "python3 ~/.claude/hooks/disconfirm-nudge.py" } ] }
  ]

The hook fails open: on any error it prints nothing and exits 0, so it can
never block a prompt. Skip it if you'd rather call the skill by hand with
the Skill tool (skill="disconfirm").
SNIP
