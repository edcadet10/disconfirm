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

# Targeted at language that signals a contested empirical/design claim or a
# decision-driving comparison — the cases where an untested conclusion is risky.
TRIGGER = re.compile(
    r"\b("
    r"research|compare|comparison|benchmark|evaluat\w+|validat\w+|calibrat\w+|"
    r"better than|best (?:way|approach|option|choice|method|model)|"
    r"which (?:approach|option|model|library|framework|tool|design|method|way)|"
    r"should (?:we|i) (?:use|pick|choose|adopt)|is it worth|worth it|"
    r"root cause|hypothesis|assumption|prove|disprove|"
    r"i (?:think|believe|assume|bet|suspect|reckon)|probably|"
    r"i'?m (?:fairly |pretty )?(?:sure|confident)|"
    r"does (?:it|this|that) (?:work|hold|generalize)"
    r")\b",
    re.IGNORECASE,
)

if TRIGGER.search(prompt):
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
