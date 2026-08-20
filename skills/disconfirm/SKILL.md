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

## Method (right-sized — do the minimum that can falsify)

1. **State the claim + the kill criterion.** One line for the belief; one line for
   the single observation that would prove it FALSE. If nothing could falsify it,
   it isn't an empirical claim — stop presenting it as one. This is the original
   claim under test, not a requirement to nominate a replacement.
2. **Ground it (research, don't recall).** Gather real evidence — search/cite,
   read the actual source, code, or data. Deliberately collect what *contradicts*
   the claim, not only what supports it. Supplied measurements and repository
   evidence count when their provenance is clear. If required evidence or tools
   are unavailable, say the claim is untested and name the exact next check;
   do not fill the gap from memory.
3. **Design the cheapest falsifying test.** The smallest experiment whose result
   could kill the claim: a small labeled set + confusion matrix, a repeat/variance
   check (does it hold across N runs?), an adversarial probe, a held-out case, a
   quick A/B. **Pre-register the pass/fail line before running.**
4. **Run it. Audit the result.** Compute only what the kill criterion needs. Check
   each derived value with code/a calculator, or show enough arithmetic to verify
   it. With a small sample, report an observed maximum rather than calling it a
   population tail percentile unless a percentile method is supplied. Separate
   observations from extrapolations. Then hold / revise / retract the claim.
   Disproving A does **not** prove rival B: a relative comparison can reject A,
   but B remains untested against any independent acceptance bar. A disproved
   assumption is the success case.
5. **Right-size — discipline, not ceremony.** The test is the minimum that can
   falsify, not a fleet of agents. (Hard-won: building elaborate apparatus to
   "validate" a claim one sharp test would settle is the exact anti-pattern this
   skill exists to prevent.)

## Hard inference boundaries

- Evaluate only the pre-registered kill criterion. Do not add a mean, median,
  percentile, ratio, cause, or general explanation unless that value is required
  by the criterion or the user asked for it.
- Label only the original claim held / revised / retracted / untested. In a
  relative A-vs-B test, B is a comparator — never mark it "passing," suitable, or
  recommended without a separate acceptance criterion.
- A finite sample establishes only what was observed in that sample. It does not
  establish a population tail, future reliability, or the cause of an outlier.
- These boundaries override any temptation to make the answer more complete.

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

If the skill is explicitly invoked for one of these, perform the task directly
and concisely. Do not force the method or add a lecture.

## Strict output contract

Use exactly these five labels unless the user requests another format:

- **Updated claim:** held / revised / retracted / untested, and why.
- **Claim / kill criterion:** the original claim and pre-registered boundary.
- **Evidence:** only cited observations relevant to that boundary; no derived values.
- **Test / result:** only the calculation the boundary requires, with enough work
  to audit it. Do not add ratios or other metrics.
- **Boundary:** at most one sentence naming the material limit on the conclusion.

Do not add a table, unlabeled paragraph, background explanation, recommendation,
optional metric, or next-step list.
