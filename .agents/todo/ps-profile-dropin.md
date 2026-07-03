---
status: open
created: 2026-07-03
---

# Add a function to Windows PowerShell + PowerShell Core without editing $profile

## Goal

Right now, [powershell/README.md](../../powershell/README.md) tells the user to
manually copy functions (e.g. `awslogin` in
[Microsoft.PowerShell_profile.ps1](../../powershell/Microsoft.PowerShell_profile.ps1))
into their `$profile`. Every other shell in this repo (bash, zsh) uses a
drop-in directory convention instead — see [AGENTS.md](../../AGENTS.md):
a `.bashrc.d` / `.zshrc.d` folder that's sourced once from the rc file, after
which new function files just get dropped in.

Want the equivalent for PowerShell: add a function once to a drop-in folder,
have it picked up by both Windows PowerShell (`powershell.exe`, uses
`Microsoft.PowerShell_profile.ps1`) and PowerShell Core (`pwsh`, uses
`Microsoft.PowerShell_profile.ps1` under a different `$PROFILE` path) — without
re-editing `$profile` for each new function.

## Context / constraints

- There's an empty top-level `pwsh/` folder already — likely intended as the
  PowerShell Core counterpart to `powershell/`, mirroring the bash/zsh split.
- `$PROFILE` differs between Windows PowerShell and PowerShell Core (different
  default paths), but both still just execute a `.ps1` file — the same
  "source a `.d` folder from inside that file" pattern used for bash/zsh
  should translate directly.
- Per AGENTS.md: startup scripts must be silent, fail fast, and safe to source
  multiple times (idempotent — no duplicate `PATH` entries, hooks, etc.).
- Should ideally share one drop-in folder between both editions rather than
  maintaining two copies, since PowerShell function syntax is the same across
  editions (only some cmdlets/host behavior differs).

## Next steps

- [ ] Decide on drop-in folder name/location (e.g. `powershell/.config.d` or
      reuse `pwsh/` as the shared drop-in target).
- [ ] Write the loader snippet for `$profile` (one-time manual edit, same as
      bash/zsh's rc snippet) that sources every `*.ps1` in the drop-in folder.
- [ ] Confirm the loader works from both `Microsoft.PowerShell_profile.ps1`
      locations (Windows PowerShell and PowerShell Core).
- [ ] Update `powershell/README.md` (and add `pwsh/README.md` if needed) to
      document the new install step, matching the style of
      [bash/README.md](../../bash/README.md).
