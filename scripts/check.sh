#!/usr/bin/env bash
set -euo pipefail

DISCONFIRM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISCONFIRM_TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$DISCONFIRM_TMP_DIR"' EXIT

bash -n "$DISCONFIRM_ROOT/install.sh"
PYTHONPYCACHEPREFIX="$DISCONFIRM_TMP_DIR/pycache" \
  python3 -m py_compile "$DISCONFIRM_ROOT/hooks/disconfirm-nudge.py"

python3 - "$DISCONFIRM_ROOT" <<'PY'
from html import unescape
from pathlib import Path
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

root = Path(sys.argv[1])
skill = root / "skills/disconfirm/SKILL.md"
text = skill.read_text()
parts = text.split("---", 2)
assert len(parts) == 3 and not parts[0].strip(), "SKILL.md needs YAML frontmatter"
frontmatter, body = parts[1], parts[2]
assert re.search(r"^name: disconfirm$", frontmatter, re.MULTILINE)
assert re.search(r"^description:\s*(?:\S|>-)", frontmatter, re.MULTILINE)
assert body.strip(), "SKILL.md needs an instruction body"
assert len(text.splitlines()) < 500, "SKILL.md must stay below 500 lines"

ET.parse(root / "assets/banner.svg")
json.loads((root / "hooks/settings.example.json").read_text())

documents = [
    root / "README.md",
    root / "CONTRIBUTING.md",
    root / "CODE_OF_CONDUCT.md",
    root / "SECURITY.md",
]
missing = []
for document in documents:
    content = document.read_text()
    targets = re.findall(r"!?\[[^]]*\]\(([^)]+)\)", content)
    targets += [a or b for a, b in re.findall(r'(?:href|src)="([^"]+)"|<(https?://[^>]+)>', content)]
    for raw_target in targets:
        target = unescape(raw_target).split("#", 1)[0]
        if not target or re.match(r"^(?:https?://|mailto:)", target):
            continue
        if not (root / target).exists():
            missing.append(f"{document.name}: {target}")
assert not missing, "missing local links: " + ", ".join(missing)

hook = root / "hooks/disconfirm-nudge.py"

def run_hook(raw_input: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(hook)],
        input=raw_input,
        text=True,
        capture_output=True,
        check=False,
    )

triggered = run_hook(json.dumps({"prompt": "Compare two frameworks and tell me which we should use."}))
assert triggered.returncode == 0 and not triggered.stderr
payload = json.loads(triggered.stdout)
context = payload["hookSpecificOutput"]["additionalContext"]
assert payload["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
assert "disconfirm" in context and "FALSIFY" in context

for raw_input in (
    json.dumps({"prompt": "Fix the typo in README.md."}),
    json.dumps({"prompt": ""}),
    "not-json",
):
    result = run_hook(raw_input)
    assert result.returncode == 0 and result.stdout == "" and result.stderr == ""

print(f"skill metadata, hook behavior, SVG, JSON, and {len(documents)} documents validated")
PY

for DISCONFIRM_RUN in 1 2; do
  CLAUDE_CONFIG_DIR="$DISCONFIRM_TMP_DIR/claude" \
    "$DISCONFIRM_ROOT/install.sh" >"$DISCONFIRM_TMP_DIR/install-$DISCONFIRM_RUN.log"
done

cmp \
  "$DISCONFIRM_ROOT/skills/disconfirm/SKILL.md" \
  "$DISCONFIRM_TMP_DIR/claude/skills/disconfirm/SKILL.md"
cmp \
  "$DISCONFIRM_ROOT/hooks/disconfirm-nudge.py" \
  "$DISCONFIRM_TMP_DIR/claude/hooks/disconfirm-nudge.py"
test -x "$DISCONFIRM_TMP_DIR/claude/hooks/disconfirm-nudge.py"
test ! -d "$DISCONFIRM_TMP_DIR/claude/skills/disconfirm/disconfirm"
test "$(find "$DISCONFIRM_TMP_DIR/claude" -type f | wc -l)" -eq 2
grep -q 'skill="disconfirm"' "$DISCONFIRM_TMP_DIR/install-2.log"

printf 'disconfirm checks passed\n'
