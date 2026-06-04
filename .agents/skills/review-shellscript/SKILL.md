---
name: review-shellscript
description: 'Review a single shell script using project steering docs as baseline policy. Use when auditing one current script for bugs, safety, portability, and startup-script constraints.'
argument-hint: 'Script path to review (optional if current file is unambiguous)'
user-invocable: true
disable-model-invocation: false
---

# Review Shellscript

## What This Skill Produces
- A focused code review for exactly one shell script file.
- A Mocha-style checklist with emoji-prefixed pass/fail results.
- Concise detail only for failed or warning checks, including concrete file and line references.
- Suggested fixes for failed checks when applicable.
- A short residual risk and validation gap summary.

## Output Contract (Required)
- Use this exact review shape:
	1. `review-shellscript`
	2. `target: <path>`
	3. Checklist lines, one per test, prefixed with emoji:
		 - `✅` pass
		 - `❌` fail
		 - `⚠` warning (non-blocking)
	4. Add detail blocks only for `❌` and `⚠` checks.
	5. End with summary lines:
		 - `Summary: <passed> passed, <failed> failed, <warnings> warnings`
		 - `Result: PASS` or `Result: FAIL`
- Keep passing checks concise (single-line).
- For failed or warning checks, include only the detail needed to act:
	- line/location
	- why it failed
	- concrete suggestion
- Do not output a separate severity-ordered narrative section unless the user asks for it.

## Minimum Required Checks
- Apply formatting in-place to the script by running `shfmt -w <file>`, but do not treat formatting issues as review failures.
- Every review must include an explicit parse/syntax check result for the target shell dialect.
- Parse check commands by target shell:
	- bash: `bash -n <file>`
	- zsh: `zsh -n <file>`
- The checklist must include a dedicated parse line:
	- `✅ parses in target shell dialect`
	- or `❌ parses in target shell dialect`
- If parse tooling is unavailable, emit `⚠` with concise detail and suggested remediation.
- For files that are intended to be sourced, every review must include a sourced-session safety check.
- Sourced-session safety check commands:
	- bash: `bash -ic 'source <file>; echo __ALIVE__'`
	- zsh: `zsh -ic 'source <file>; echo __ALIVE__'`
- The checklist must include a dedicated sourced-session line when applicable:
	- `✅ sourced file does not terminate parent shell`
	- or `❌ sourced file does not terminate parent shell`
- If this check cannot be executed, emit `⚠` with concise detail and suggested remediation.


## When To Use
- You want a review of the current shell script only.
- You need feedback aligned to this repository's steering docs.
- You want risk-first review output rather than style-only commentary.

## Inputs
- Target script path (optional when the active file is clearly the intended target).
- Optional review scope hints (for example: security only, portability only, startup performance only).
- The style guide: .agents/skills/review-shellscript/style_guide.md

## Baseline Policy Sources
1. Read workspace-level instructions first when present (for example, copilot-instructions.md, AGENTS.md, and workspace instruction files).
2. Apply shell-specific guardrails from steering docs before generic lint conventions.
3. Prioritize startup-script requirements when file appears in startup load paths.

## Decision Points
1. Target file certainty:
- If exactly one candidate is obvious from user message or active editor context, review it.
- If uncertain, ask the user which single file to review before proceeding.

2. File type fit:
- If the file is not a shell script, ask whether to continue or switch target.

3. Output mode:
- Always emit the checklist format defined in `Output Contract (Required)`.
- If all checks pass, emit only pass lines plus summary.
- If any checks fail or warn, include concise detail blocks only for those items.

4. Severity profile:
- Use strict severity for startup scripts: treat startup performance, idempotency, silence-on-startup, and unsafe side effects as high-impact concerns.
- For non-startup scripts, use standard severity classification.

## Procedure
1. Resolve the single target file and confirm certainty.
2. Read steering docs and extract repository-specific shellscript constraints.
3. Read the target file fully.
4. Run parse/syntax validation for the target shell dialect and record pass/fail.
5. For files intended to be sourced, run a sourced-session safety check and record pass/fail.
6. Evaluate for:
- Correctness and behavioral bugs
- Security and unsafe patterns
- Portability and shell compatibility concerns
- Startup performance and silent-failure requirements
- Idempotency and side effects
- Input validation and error handling
- Exit behavior safety for sourced scripts (`return` for sourced-path exits; avoid top-level `exit`)
7. Produce findings ordered by severity with concrete references.
8. For each failed or warning check, include concise detail with references and suggested fix when practical.
9. Add open questions or assumptions only when they affect confidence.
10. Add residual risk and testing gaps in brief.

## Quality Checks
- Exactly one file is reviewed.
- Parse/syntax test is executed and explicitly reported.
- Sourced-session safety test is executed and explicitly reported when applicable.
- Findings are actionable and reference precise locations.
- Steering-doc constraints are explicitly reflected in the review rationale.
- Output matches the required emoji checklist format.
- Failed and warning checks include suggested fixes when practical.
- No fabricated behavior claims.

## Completion Criteria
- User receives a complete checklist-style review for one script.
- Any uncertainty about file selection is resolved explicitly.
- Residual risks and validation gaps are documented.

## Example Prompts
- Review shellscript: bash/.bashrc.d/10-direnv.sh
- Code review this current shell script against project steering docs.
- Review one script for startup safety and portability issues.

## Related Customizations To Create Next
- A shellscript fixer skill that applies approved review fixes and runs shellcheck.
- A startup-script checklist prompt for pre-merge validation.
- A portability-focused shell review skill split by bash and zsh targets.
