# Shell Style Guide Summary (Local)

This document is adapted from the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) for local review workflows.

## When Shell scripts are appropriate

- Use shell scripts for small utilities and wrappers.
- Prefer another language when logic grows complex, data manipulation becomes heavy, or performance matters.
- A script that is growing past simple control flow should be considered for rewrite earlier, not later.

## File and Execution Rules

- Use clear interpreter invocation for executable scripts.
- Keep library-style files non-executable.
- Avoid privileged execution patterns like SUID/SGID shell scripts.
- Send normal output to stdout and errors to stderr.
- Functions which support option flags should support both short and long options (e.g. `-o` `--option`)
- Command-like public function should output help when provided the `-h` or `--help` switch.
- Function help documentation should adhere to POSIX Utility Syntax Guidelines
- If a script uses the `exit` keyword to stop execution and provide exit codes, it should never terminate the user's shell session. The example pattern below will properly handle this.

```
__is_sourced() {
  if [ -n "${BASH_VERSION-}" ]; then
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0
  elif [ -n "${ZSH_VERSION-}" ]; then
    # shellcheck disable=SC2296
    (( zsh_eval_context[(I)file] )) && return 0
  fi
  return 1
}

__terminate() {
  local exit_code="${1:-0}"
  if __is_sourced; then
    return "${exit_code}"
  else
    exit "${exit_code}"
  fi
}

main() {
  if [[ some_error_check ]]; then
    return 1
  fi
  return 0
}

main "$@"
__terminate "$?"

```


## Comments and Documentation

- Start files with a short top-level description, with the following format:

```
#+++++++++++++++++++++++++++++++++++++
# Short description
#+++++++++++++++++++++++++++++++++++++
```

- Add function headers for non-trivial or library functions.
- Explain tricky logic with focused implementation comments.
- Use searchable TODO comments with an owner/context tag.
- Include section headers where they will improve readability/scannability of the file

```
########################
# Section header
########################
```

## Formatting

- Use 2-space indentation and no tabs (except tab-indented heredoc cases where required).
- Prefer consistent line wrapping and readable multi-line pipelines.
- Keep control-flow formatting consistent (`if ...; then`, aligned `fi`, `do`, `done`).
- Keep case blocks readable and consistently indented.
- Prefer explicit, quoted parameter expansion.
- Keep the opening brace on the same line as the start of a function
- Closing braces for functions should be on their own line
- Maintain a blank line before and after a function
- Keep the `do` or `then` keyword for `for` or `while` statements on the same line as the start of the control flow.

```sh
for file in "${files[@]}"; do
  ...
done
```

## Safety and Correctness Practices

- Prefer `$(...)` over backticks.
- Prefer `[[ ... ]]` for tests, with care around pattern/regex behavior.
- Use explicit string tests (`-n`, `-z`) where clarity improves correctness.
- Avoid `eval` unless there is a tightly justified, reviewed need.
- Prefer arrays for argument lists to avoid word-splitting bugs.
- Avoid `cmd | while read ...` when loop state must persist in the current shell.
- Prefer shell arithmetic syntax (`(( ... ))`, `$(( ... ))`) over legacy alternatives.
- Avoid aliases in scripts; use functions.
- For files intended to be sourced, do not use top-level `exit`; use `return` for early termination so the user shell session is not terminated.

## Naming and Structure

- Use lowercase with underscores for functions and variables.
- Use uppercase for exported variables and constants.
- Prefer local variables inside functions.
- Do not combine local declaration with command substitution assignment when return status matters.
- Group function definitions clearly, and use a `main` entrypoint for larger scripts.

## Command Usage

- Check return values and emit actionable error messages.
- Use builtins/parameter expansion when practical to reduce subprocess overhead and quoting hazards.

## Consistency Rule

- Be consistent within a file and across the repository.
- Consistency supports maintainability, review speed, and automation.

## How Review-Shellscript Should Use This

Suggested review order:

1. Repository policy in [AGENTS.md](../../../AGENTS.md)
2. This summary

This keeps reviews fast, consistent, and aligned to actual project intent.
