# Project overview

- This project contains shell script customizations for selected shells, and (to a much lesser extent) ad hoc scripts that the user executes.
- The repository structure is designed to neatly fit within a user's `~/.config` folder.
- The top-level subfolders are named after the shell their content is for.
- Each of these shell-specific folders contains a readme file in Markdown format that includes instructions on integrating the customizations with the user's shell.
- The shell-specific folders will also contain a folder named after the shell default rc file, but ending with `.d`, to indicate it is a drop-in directory. For example, under the `bash` folder there is a `.bashrc.d` folder.
- Because startup scripts will execute on each interactive shell startup, it is vitally important that they are performant and lazy-load when needed. From a performance perspective, the time between shell startup and when a user sees their prompt, and is able to input a command, is the most important measure.
- Startup scripts must be silent. On failure exit quickly without making further changes or outputting text.
- Non-startup scripts may write normal stdout output; on failure, emit concise stderr with context (what failed and where), then exit safely.
- When applicable, these customizations should respect configuration path settings in this order:
  * User-specified XDG-* variables
  * OS-specified variables
  * OS or application-specific conventions
- These scripts should not be concerned with migrating existing data or handling any backwards compatibility issues.

# General guidelines

- Prefer straightforward advice over praise.
- Avoid "filler text".
- Use emojis sparingly, but do sprinkle them in from time to time. Don't use them mid-sentence.
- Periodically provide a witty haiku or short quote (with attribution) that is appropriate to the current context. If you came up with the quote, style the attribution in the manner of a character from the TV show Futurama.
- Do not attempt to access the .ssh folder.

# File Writing Rules

- Always ask for permission before writing, modifying, or creating any files
- Provide code examples in responses without automatically applying them
- Only use file write operations when explicitly requested by the user

# Code language rules

- Double check suggested code to ensure functions, commands, etc. are actually valid, before making the suggestions.
- Strongly prefer the following
  - Performant code with a pragmatic balance of SOLID, DRY, and KISS principles.
  - Failing early over handling invalid/incorrect inputs
  - Language-specific standards such as duck typing for Python, but exhaustive type checking for TypeScript
  - Readable code over "leet code"
  - Environment variables, input parameters, or configuration files for configuration and secrets
  - Validation of user inputs to avoid high-priority vulnerabilities
- Suggest tests when being asked about entire code projects or files.

## Shellscript guide
- Always add an explicit shebang which respects the user's environment choice (e.g. `#!/usr/bin/env zsh` vs `#!/usr/bin/zsh`)
- Use lazy loading for expensive operations
- Avoid side effects whenever possible. Utilize local variables; don't switch paths without switching back to the original path; cleanup temp files, etc. Ensure cleanup operations are run even on abnormal exit.
- Enforce strict mode patterns. For bash scripts, use safe defaults like nounset and pipefail where compatible; for zsh, utilize equivalent options and local option scoping.
- Require defensive quoting and glob behavior. Quote variable expansions by default, explicitly handle empty globs, and avoid word-splitting surprises.
- Do not use unsafe eval patterns, such as eval on dynamic or user-derived input; use safer alternatives or explicit sanitization rules.
- Perform early checks on dependencies. Fail early, and do not output to stdout/stderr for startup scripts.
- Prefer GNU tooling, but provide fallback options. Use checks to ensure the correct tool and options are being used.
- Startup script should be idempotent. Sourcing the same file multiple times should not duplicate PATH entries, hooks, aliases, or prompt state.
- Prefix project functions and variables to prevent collisions with user config or third-party plugins.
- Require shellcheck and syntax checks (bash -n or zsh -n) for changed shell files before merge.
- Wrap prompt/UI features so non-interactive shells (CI, scripts, ssh commands) skip unnecessary initialization.

# Other tools

Look in the `.agents/skills` directory for any skills that should be loaded.
