---
name: update-readme
description: 'Discover public-facing features from repository scripts and update README Features. Use when syncing docs with implemented shell capabilities or replacing a stale feature list.'
argument-hint: 'README path, optional feature input, and optional script discovery scope'
user-invocable: true
disable-model-invocation: false
---

# Update README Feature List

## What This Skill Produces
- A discovered and verified list of public-facing features provided by scripts in the repository.
- A clean README update that adds or refreshes a Features section using that verified list.
- A split Features structure with:
- General features as a standard Markdown bullet list.
- Tool-specific features in a 2-column HTML table where column 1 is tool name and column 2 is a list of public features for that tool.
- A short exclusions list for script behaviors that are internal-only and should not be presented as user-facing features.

## When To Use
- You have a list of features and need them reflected in README.
- The README has no Features section and one must be added.
- Existing feature bullets are outdated and need reconciliation.
- You want automatic feature discovery from shell scripts instead of manually supplied bullets.

## Inputs
- Target README path.
- Optional provided feature list content.
- Optional constraints: ordering preference, grouping rules, wording style, max bullet length.
- Discovery scope (optional): paths to scan for scripts, defaults to shell customization directories.

## Decision Points
1. Section discovery:
- If a Features section exists, update in place.
- If no Features section exists, create one in the most logical position (typically after overview and before setup/usage).

2. Content normalization:
- If items are duplicates or near-duplicates, merge to one concise bullet.
- If items are implementation details, rewrite as user-facing outcomes unless the project conventions require technical phrasing.

3. Scope control:
- If a provided item is unsupported by code or project docs, mark as uncertain and ask before including.

4. Discovery source priority:
- If a provided feature list exists, reconcile it against discovered script features.
- If no provided list exists, generate the full candidate feature list from scripts and docs.

5. Public-facing filter:
- Include capabilities a user can directly invoke, configure, or observe (aliases, commands, startup behavior, install helpers, completion behavior).
- Exclude internal implementation mechanics (variable naming, helper internals, private cache details) unless they affect user-visible behavior.

6. Feature grouping format:
- Classify each validated feature as either general (cross-tool or repository-wide) or tool-specific (belongs to a named tool).
- Render tool-specific features in a 2-column HTML table: first column tool name, second column list of public features for that tool.

## Procedure
1. Discover candidate features from script files in scope (for example: bash/.bashrc.d, zsh/.zshrc.d, and helper installer scripts).
2. Extract only public-facing capabilities from each script (aliases, functions intended for user invocation, setup behavior, completions, install flows).
3. Merge discovered features with any provided feature list, then deduplicate semantically similar items.
4. Validate each candidate against source evidence; mark uncertain items for confirmation.
5. Classify validated features into:
- General features (repository-wide behaviors, cross-tool workflows, shared shell UX features).
- Tool-specific features (features tied to one tool such as aws, azure, docker, git, tofu, node, direnv, powershell).
6. Convert general features into concise, parallel, user-facing Markdown bullets.
7. Convert tool-specific features into a 3-column HTML table with:
- Column 1 (Name: Tool): tool name.
- Column 2 (Name: Features): an unordered list of public features for that tool.
- Column 3 (Name: Shell support): a list of shells that are supported
8. Only include column 3 if tool support is materially different across shells; otherwise, note shell support in the features list.
9. Read the target README and identify the best insertion or replacement location for Features.
10. Preserve existing heading style, capitalization, and bullet conventions.
11. Apply the README update.
12. Produce a short note listing excluded internal-only items and unresolved ambiguities.
13. Run a final pass for grammar, consistency, and markdown formatting.

## Discovery Heuristics
- Treat user-callable aliases and functions as feature candidates.
- Treat documented startup behavior that changes user workflow as feature candidates.
- Treat install scripts that provision optional toolchains as feature candidates.
- Collapse near-duplicate features that appear across bash and zsh into a single cross-shell bullet when behavior is equivalent.
- Keep shell-specific bullets only when behavior materially differs.

## Quality Checks
- Every discovered and/or provided feature is represented, merged, or explicitly called out as excluded.
- Bullets are parallel in grammar and tense.
- No marketing exaggeration or unverifiable claims.
- Markdown renders cleanly with consistent spacing.
- Indentation uses spaces only — tabs are never used in any output.
- Existing unrelated README content remains unchanged.
- Each included feature has at least one concrete source in scripts or docs.
- Features are split into general and tool-specific groups.
- Tool-specific group is rendered as a 2-column HTML table with tool name and public-feature list.

## Completion Criteria
- README contains an accurate public-facing feature list aligned with discovered script capabilities and any provided input.
- README presents general features separately from tool-specific features.
- Tool-specific features are organized in a 2-column HTML table (tool, features).
- Placement and style match repository documentation patterns.
- Internal-only behaviors are not presented as product features.
- Any unresolved ambiguities are listed with explicit questions.

## Example Prompts
- Update README to include this feature list from my release notes.
- Refresh the Features section in README using these six bullets.
- Add a new Features section to README from this plain text list.
- Discover all public-facing features from scripts, then rewrite README Features accordingly.
- Scan bash and zsh script folders, produce a verified feature list, and update README.

## Related Customizations To Create Next
- A skill to verify README claims against code symbols and commands.
- A prompt template that converts release notes into README-ready feature bullets.
- File instructions for markdown heading and list style conventions in this repo.
