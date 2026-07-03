---
status: open
created: 2026-07-03
---

# Consolidate the azp installer into the azp script

Source: `@TODO` comment at
[zsh/.zshrc.d/30-azure.zsh:7](../../zsh/.zshrc.d/30-azure.zsh#L7).

## Goal

`_install_azp()` in [30-azure.zsh](../../zsh/.zshrc.d/30-azure.zsh#L33-L47)
symlinks `assets/azure/azure-profile-manager.sh` into `~/.local/bin` and
`chmod +x`s it, and this runs on every interactive shell startup (guarded by
`[[ ! -f "${target_file}" ]]`, so it's cheap after the first run, but the
install logic still lives in the startup path rather than in the script it's
installing). Move that installer logic into
`assets/azure/azure-profile-manager.sh` itself (e.g. a self-install/bootstrap
check the script runs once), so `30-azure.zsh` only has to source/alias it,
not manage its installation.

## Context / constraints

- Per [AGENTS.md](../../AGENTS.md): startup scripts must be silent, fail
  fast, and idempotent — whatever replaces `_install_azp()` in the startup
  path must preserve that (currently it does via the file-existence guard).
- `_get_az_profiles_dir()` and the `_azure_profile_manager` completion
  function in the same file are unrelated to the installer and should stay
  in `30-azure.zsh`.
- Check whether `install.sh` (repo root) already handles asset deployment
  generally — if so, the "right" fix might be there instead of inside
  `azure-profile-manager.sh`.

## Next steps

- [ ] Read `install.sh` to see how it currently deploys `assets/` content, if
      at all, and whether azp should just be folded into that flow.
- [ ] Decide: self-install on first invocation of
      `azure-profile-manager.sh`, vs. handled entirely by `install.sh`.
- [ ] Remove `_install_azp()` and its call site from `30-azure.zsh` once the
      logic has a new home.
- [ ] Update `zsh/README.md` / root `README.md` if the install story changes
      for users.
