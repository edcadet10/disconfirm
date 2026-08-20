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

positive_prompts = [
    "Compare SQLite and Postgres for this write-heavy API; tell us which to adopt.",
    "Which framework should we use for the API?",
    "I think this cache fix works; validate it before rollout.",
    "What is the root cause of the latency spike?",
    "Is parser A faster than parser B on large files?",
    "Is this authentication design secure enough to ship?",
    "Does this retry strategy generalize across regions?",
    "Evaluate whether switching to Rust is worth it.",
    "Review whether this architecture can scale to 10k RPS.",
    "I suspect the new index is faster under production load.",
]
negative_prompts = [
    "Fix the typo in README.md.",
    "Look up the current Python release version.",
    "Research where UserService is defined in this repository.",
    "Prove that the square root of 2 is irrational.",
    "I will probably rename this variable.",
    "Compare these two strings for equality in Python.",
    "Run the benchmark script and paste its raw output.",
    "Evaluate 2 + 2.",
    "Which file contains the route?",
    "Validate this JSON against the schema and return the errors.",
]
variant_positive_prompts = [
    "Before rollout, test whether the new sanitizer is actually safe.",
    "Are we confident this migration is correct?",
    "Would DynamoDB be a better choice than Postgres here?",
    "Which design is most reliable under partial failure?",
    "The new queue should be cheaper than SQS; check that claim.",
    "Can this service handle 50,000 concurrent users?",
    "Will this fix hold under retries?",
    "I believe the memory leak comes from the cache.",
    "Validate the claim that compression improves throughput.",
    "We need a recommendation between gRPC and REST for mobile clients.",
]
variant_negative_prompts = [
    "Research the declaration of parseConfig.",
    "Compare x and y and return a boolean.",
    "Prove Lemma 4 by induction.",
    "Validate config.yaml against config.schema.json.",
    "Run the benchmark named latency and paste the output.",
    "Review README.md for spelling errors.",
    "Test the login endpoint and paste the status code.",
    "I think I left my notes in docs/.",
    "Which model file defines User?",
    "Calculate whether 17 is faster to type than seventeen.",
]

def hook_triggered(prompt: str) -> bool:
    result = run_hook(json.dumps({"prompt": prompt}))
    assert result.returncode == 0 and not result.stderr
    if not result.stdout:
        return False
    payload = json.loads(result.stdout)
    context = payload["hookSpecificOutput"]["additionalContext"]
    assert payload["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
    assert "disconfirm" in context and "FALSIFY" in context
    return True

true_positives = sum(hook_triggered(prompt) for prompt in positive_prompts)
false_positives = sum(hook_triggered(prompt) for prompt in negative_prompts)
assert true_positives >= 8, f"hook recall too low: {true_positives}/10"
assert false_positives <= 2, f"hook false-positive rate too high: {false_positives}/10"
variant_true_positives = sum(hook_triggered(prompt) for prompt in variant_positive_prompts)
variant_false_positives = sum(hook_triggered(prompt) for prompt in variant_negative_prompts)
assert variant_true_positives >= 8, (
    f"hook variant recall too low: {variant_true_positives}/10"
)
assert variant_false_positives <= 2, (
    f"hook variant false-positive rate too high: {variant_false_positives}/10"
)
assert hook_triggered("Prove that the new algorithm is correct before deployment.")

for raw_input in (json.dumps({"prompt": ""}), "not-json"):
    result = run_hook(raw_input)
    assert result.returncode == 0 and result.stdout == "" and result.stderr == ""

print(
    f"skill metadata, hook behavior ({true_positives}/10 positive, "
    f"{false_positives}/10 false positive; variants "
    f"{variant_true_positives}/10 positive, "
    f"{variant_false_positives}/10 false positive), SVG, JSON, and "
    f"{len(documents)} documents validated"
)
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
