#!/usr/bin/env python3
"""UserPromptSubmit hook — force the `disconfirm` discipline.

When a prompt reads like a research / comparison / assumption-validation task,
inject a reminder that the model must invoke the `disconfirm` skill (grounded
research + a cheapest-falsifying calibration) before asserting a conclusion it
will act on. Fails open: any parse error or non-match emits nothing and exits 0,
so it can never block prompt submission.
"""

import json
import re
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

prompt = str(data.get("prompt") or "")

# A strong claim signal can trigger alone. Generic work verbs only trigger when
# paired with decision language, which avoids interrupting lookups, arithmetic,
# schema validation, and other pure execution.
CLAIM_SIGNAL = re.compile(
    r"(?:"
    r"\b(?:better|faster|slower|safer|cheaper|more reliable|less reliable)"
    r"(?:\s+[\w-]+){0,3}\s+than\b|"
    r"\bbest (?:way|approach|option|choice|method|model)\b|"
    r"\bwhich (?:approach|option|model|library|framework|tool|design|method|way)"
    r"\s+(?:should|is|would)\b|"
    r"\bshould (?:we|i) (?:use|pick|choose|adopt)\b|"
    r"\bis (?:it|this|that) worth\b|\bworth it\b|"
    r"\broot cause\b|\bhypothesis\b|\bassumption\b|"
    r"\b(?:comes?|stems?|results?)\s+from\b|"
    r"\brecommend(?:ation)?\s+between\b|"
    r"\b(?:does|will)\s+(?:it|this|that)\b(?:\s+[\w-]+){0,5}\s+"
    r"(?:work|hold|generalize)\b|"
    r"\bis\s+(?:it|this|that)\b(?:\s+[\w-]+){0,5}\s+"
    r"(?:safe|secure|correct|scalable|reliable|ready)\b|"
    r"\b(?:it|this|that)\b(?:\s+[\w-]+){0,5}\s+can\s+(?:scale|handle)\b|"
    r"\b(?:can|will)\s+(?:it|this|that)\b(?:\s+[\w-]+){0,5}\s+"
    r"(?:scale|handle)\b"
    r")",
    re.IGNORECASE,
)

CONFIDENCE_SIGNAL = re.compile(
    r"\b(?:"
    r"i (?:think|believe|assume|bet|suspect|reckon)|"
    r"(?:i(?:'m| am)|we(?:'re| are)|are we|am i)"
    r"(?:\s+(?:fairly|pretty))?\s+(?:sure|confident)"
    r")\b",
    re.IGNORECASE,
)

DECISION_ACTION = re.compile(
    r"\b(?:research|compar\w*|benchmark\w*|evaluat\w+|validat\w+|"
    r"calibrat\w+|review\w*|test\w*|prove|disprove)\b",
    re.IGNORECASE,
)
DECISION_CONTEXT = re.compile(
    r"\b(?:claim|hypothesis|assumption|decision|recommend\w*|choose|adopt|"
    r"ship|rollout|production|worth|better|faster|safe|safer|security|secure|"
    r"correct|works?|root cause|approach|option|library|framework|"
    r"architecture|design)\b",
    re.IGNORECASE,
)

should_trigger = bool(
    CLAIM_SIGNAL.search(prompt)
    or (CONFIDENCE_SIGNAL.search(prompt) and DECISION_CONTEXT.search(prompt))
    or (DECISION_ACTION.search(prompt) and DECISION_CONTEXT.search(prompt))
)

if should_trigger:
    msg = (
        "DISCONFIRM-CHECK (auto-injected): this reads as a research / "
        "assumption-validation / comparison task. Before asserting any conclusion "
        "you will act on, you MUST invoke the `disconfirm` skill (Skill tool, "
        'skill="disconfirm"): (1) ground the claim with real research — cite, do '
        "not recall; (2) run the CHEAPEST experiment that could FALSIFY it; (3) "
        "report what the data said, especially if it disproves you. State no "
        "confident conclusion until you have tried to break it. Right-size the "
        "test — discipline, not a fleet of agents."
    )
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": msg,
                }
            }
        )
    )

sys.exit(0)
