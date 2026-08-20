# Contributing

Thanks for helping make `disconfirm` more rigorous without making it ceremonial.
Documentation, hook precision, adversarial examples, installer portability, and
focused skill improvements are welcome.

## Start here

- Open a focused pull request directly for a small fix.
- Use an [issue form](https://github.com/edcadet10/disconfirm/issues/new/choose) for a reproducible bug or feature proposal.
- Start a [Discussion](https://github.com/edcadet10/disconfirm/discussions) before changing the skill's core method or hook trigger policy.
- Report vulnerabilities through [GitHub's private reporting form](https://github.com/edcadet10/disconfirm/security/advisories/new), never a public issue.

You do not need an assignment for an unclaimed small issue. Comment before
starting larger work so contributors do not duplicate effort. Draft pull
requests are welcome.

## Validate your change

The repository needs Bash and Python 3; it has no package-install step.

```bash
./scripts/check.sh
```

The check validates skill metadata, repository links, SVG and JSON syntax, hook
trigger/non-trigger behavior, and a repeatable clean-room install under a
temporary Claude directory.

For behavior changes, include fictional examples covering:

- one consequential claim that should invoke `disconfirm`;
- one ordinary execution request that should not invoke it;
- the cheapest result that would falsify the proposed behavior.

## Design guardrails

- Require both grounded research and a cheapest falsifying test.
- State the claim and kill criterion before testing.
- Treat disconfirmation as a successful result, not an error.
- Keep tests proportional; do not turn the method into an agent fleet.
- Keep the hook targeted and fail-open on every malformed or non-matching input.
- Avoid new runtime dependencies without a concrete need.
- Never add private prompts, credentials, or proprietary evidence as fixtures.

Keep pull requests focused on one concern. Link the relevant issue and explain
the measured behavioral effect, compatibility impact, and rollback path.

Participation follows the [Code of Conduct](CODE_OF_CONDUCT.md).
