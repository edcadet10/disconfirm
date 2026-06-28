---
name: disconfirm
description: >-
  Invoke BEFORE committing to any non-trivial empirical or design claim — "X is
  better/faster/safer than Y", "we should use Z", "this approach works", "the
  root cause is W", "this is correct/safe", or any compare / benchmark / evaluate
  / validate / research task whose result drives a decision. Forces the two
  things that are easy to skip and that genuinely de-risk a conclusion: (1)
  grounded research (cite real sources / search / read the actual data — never
  answer from memory), and (2) the cheapest experiment that could FALSIFY the
  claim, run and reported honestly. This is the disconfirmation-first /
  red-team-your-own-belief discipline; use it the moment you notice yourself
  confident without having tried to break the belief.
---

# Disconfirm — research + falsify before you conclude

Confident-feeling conclusions are routinely wrong. This skill forces you to **try
to break your own claim with evidence before you state or act on it.** Reserve it
for consequential beliefs — not trivia.

> Origin: it was built after an over-engineered verification exercise where the
> *only* parts that earned their cost were a grounded research pass and a
> calibration that **disproved the author's own assumption**. This skill is those
> two parts, isolated — minus the wasteful machinery around them.

## Method (right-sized — do the minimum that can falsify)

1. **State the claim + the kill criterion.** One line for the belief; one line for
   the single observation that would prove it FALSE. If nothing could falsify it,
   it isn't an empirical claim — stop presenting it as one.
2. **Ground it (research, don't recall).** Gather real evidence — search/cite,
   read the actual source, code, or data. Deliberately collect what *contradicts*
   the claim, not only what supports it. If you can't cite it, you don't know it.
3. **Design the cheapest falsifying test.** The smallest experiment whose result
   could kill the claim: a small labeled set + confusion matrix, a repeat/variance
   check (does it hold across N runs?), an adversarial probe, a held-out case, a
   quick A/B. **Pre-register the pass/fail line before running.**
4. **Run it. Report what the data said — especially if it disconfirmed you.** State
   the measured result, then hold / revise / retract the claim. A disproved
   assumption is the success case, not a failure.
5. **Right-size — discipline, not ceremony.** The test is the minimum that can
   falsify, not a fleet of agents. (Hard-won: building elaborate apparatus to
   "validate" a claim one sharp test would settle is the exact anti-pattern this
   skill exists to prevent.)

## When to use
- "X is better / faster / safer / cheaper than Y"; "we should use Z"; "the best
  approach is…".
- A benchmark, evaluation, or comparison whose result drives a decision.
- "The root cause is…", "this fix works", "this is injection-safe / correct",
  before you ship or act on it.
- Any time you're confident and haven't yet tried to break the belief.

## When NOT to use
- A verifiable fact — look it up once (that's research, not a calibration).
- Trivial or easily-reversible choices where being wrong is cheap.
- Pure execution with no contested claim.

## Output (lead with whether the data changed your mind)
- **Claim** + **kill criterion**.
- **Evidence** (cited — supporting and contradicting).
- **Falsifying test** + its **measured result**.
- **Updated claim**: held / revised / retracted, and why.
