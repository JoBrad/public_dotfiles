# Project overview

- This project contains shell script customizations for selected shells.
- The primary subfolders are named after the shell that they are for.
- Each of these shell-specific folders contains a readme file in Markdown format that includes instructions on integrating the customizations with the user's shell.
- The shell-specific folders will also contain a folder named after the shell default rc file, but ending with .d, to indicate it is a drop-in directory. For example, under the `bash` folder there is a `.bashrc.d` folder.
- Because these scripts will execute on each interactive shell startup, is is vitally important that they are performant and lazy-load when needed. From a performance perspective, the time between shell startup and when a user sees their prompt, and is able to input a command, is the most important measure.
- If a script encounters an error it should output the error, the location where the error occurred, and then quickly exist without crashing the users's session.
- When applicable, these customizations should respect configuration path settings in this order:
  * User-specified XDG-* variables
  * OS-specified variables
  * OS-specific customs
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
- For Typescript, consider the following tsconfig configuration as a default:
  - target: es2022
  - module: nodenext
  - moduleResolution: nodenext
  - erasableSyntaxOnly: true
  - strict: true
  - noImplicitAny: true
  - strictNullChecks: true
  - noImplicitThis: true
  - noUnusedLocals: true
  - noUnusedParameters: true
  - noImplicitReturns: true
  - noFallthroughCasesInSwitch: true
- For shellscript languages, prefer constructs and functions that are highly performant and native.
