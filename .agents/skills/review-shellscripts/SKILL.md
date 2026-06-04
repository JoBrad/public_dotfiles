---
name: review-shellscripts
description: 'Review all shell scripts in the project script directories. Use when auditing the full set of bash/.bashrc.d and zsh/.zshrc.d scripts for bugs, safety, portability, and startup-script constraints.'
argument-hint: 'Required: specific directory path(s) to scan'
user-invocable: true
disable-model-invocation: false
---

# Review Shellscripts (Batch)

## What This Skill Produces
- A per-file checklist review for every script in the scanned directories.
- Each file reviewed using the same checks as `review-shellscript`.
- A roll-up summary across all files: total files, aggregate pass/fail/warning counts, and a list of files that failed.

## Output Contract (Required)

### Per-file section
For each file, emit:
1. `review-shellscripts`
2. `target: <path>`
3. Checklist lines, one per test, prefixed with emoji:
   - `✅` pass
   - `❌` fail
   - `⚠` warning (non-blocking)
4. Detail blocks only for `❌` and `⚠` results — include line/location, why it failed, concrete suggestion.
5. Per-file summary line: `Summary: <passed> passed, <failed> failed, <warnings> warnings — Result: PASS / FAIL`

### Roll-up section
After all per-file sections, emit a `## Roll-up` section containing:
- Total files reviewed
- Aggregate passed / failed / warnings counts
- `Files with failures:` list (paths only) — omit if none
- `Files with warnings:` list (paths only) — omit if none
- Final line: `Overall result: PASS` or `Overall result: FAIL`

## Minimum Required Checks (per file)
Same as `review-shellscript`:
- Parse/syntax check for the target shell dialect:
  - bash: `bash -n <file>`
  - zsh: `zsh -n <file>`
- Sourced-session safety check for files intended to be sourced:
  - bash: `bash -ic 'source <file>; echo __ALIVE__'`
  - zsh: `zsh -ic 'source <file>; echo __ALIVE__'`
- Correctness and behavioral bugs
- Security and unsafe patterns
- Portability and shell compatibility
- Startup performance and silent-failure requirements
- Idempotency and side effects
- Input validation and error handling
- Exit behavior safety (`return` for sourced-path exits; avoid top-level `exit`)

## When To Use
- You want a full audit of all scripts in the project's rc drop-in directories.
- Pre-merge or pre-release review pass.
- You want a roll-up view of health across the script set.

## Inputs
- Optional: specific directory path(s) to scan. Defaults to `bash/.bashrc.d` and `zsh/.zshrc.d`.
- Optional: shell name (`bash` or `zsh`) to limit scope to one directory.

## Default Scan Targets
- `bash/.bashrc.d/` — all `*.sh` files
- `zsh/.zshrc.d/` — all `*.zsh` files

## Baseline Policy Sources
1. `AGENTS.md` — workspace-level instructions and project constraints.
2. `../.agents/skills/review-shellscript/style_guide.md` — shell style guide.
3. Apply startup-script severity rules for all files in rc drop-in directories.

## Procedure
1. Resolve scan scope: use provided paths/shell filter, or default to both directories.
2. Discover all script files in scope (`*.sh` for bash dirs, `*.zsh` for zsh dirs). Sort alphabetically.
3. Read `AGENTS.md` and `style_guide.md` once; apply to all file reviews.
4. For each file:
   a. Run parse/syntax check and record result.
   b. Run sourced-session safety check and record result.
   c. Evaluate all remaining checks.
   d. Emit the per-file checklist section per the Output Contract.
5. After all files, emit the Roll-up section.

## Quality Checks
- Every file in scope is reviewed — none skipped silently.
- Parse and sourced-session checks are executed and reported per file.
- Roll-up counts match the sum of per-file results.
- Findings are actionable with precise file and line references.
- No fabricated behavior claims.

## Completion Criteria
- All in-scope scripts have a checklist section.
- Roll-up section is present with accurate aggregate counts.
- Any files that could not be reviewed (missing, unreadable) are listed explicitly in the roll-up.

## Example Prompts
- Review all shellscripts
- Batch review bash scripts
- Run review-shellscripts on zsh only
- Audit all scripts in the project
