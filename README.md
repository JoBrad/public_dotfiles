# Dotfiles

This is my personal "dotfiles" configuration, which sets up my shortcuts and other shell customization options. It is designed to provide a similar experience between ZSH and Bash.

Tests were done on

- ZSH version 5.9
- Bash version 5.3.3(1)

Feel free to copy or contribute if you find them useful. Input is welcome!

# Installation

A rudimentary install script is in the root of this repo.

```sh
./install.sh zsh
```


# Features

## General Features

- Guided install script that deploys dotfiles for bash or zsh, copies script directories to XDG-aligned config paths, and appends a managed startup block to the appropriate shell rc file.
- XDG Base Directory compliance: all tools respect `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, and `XDG_STATE_HOME`.
- Privacy-focused defaults: command history is not written to disk after the session ends; terminal window title is set to `user@hostname` and cleared on exit.
- Navigation shortcuts: `..`, `...`, and `....` for quick parent directory traversal.
- Directory listing aliases: `ll`, `la`, `l`, `lsd`, and `lw` with color output and sensible defaults.
- File safety defaults: backup-on-overwrite for `cp` and `mv`; `rm --preserve-root` guard enabled.
- Archive shortcuts: `tarc` to create a compressed archive, `tarx` to extract one.
- Enhanced `diff`: defaults to case-insensitive, whitespace-ignoring, side-by-side output.
- `psgrep <pattern>` to search running processes by name.
- `cls` to reload the shell configuration and clear the screen.
- `fuck` to re-run the previous command with elevated privileges.
- Two-line prompt showing username (color-coded for root) and current directory. (bash only)

## Tool-Specific Features

<table>
  <thead>
    <tr>
      <th>Tool</th>
      <th>Public Features</th>
      <th>Shell support</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>AWS CLI</td>
      <td>
        <ul>
          <li>Profile management helpers to list profiles, get region, and set active profile and region.</li>
          <li>Convenience aliases for profile commands and caller identity checks.</li>
          <li>Shell completion for profile-oriented commands in bash and zsh.</li>
          <li>Auto-initiates AWS SSO login when switching to a profile that requires authentication.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Azure CLI</td>
      <td>
        <ul>
          <li>Azure profile manager bootstrap in zsh with local helper script installation.</li>
          <li>Alias entrypoint for profile manager usage.</li>
          <li>Command completion for Azure profile management actions.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>OpenTofu and Terraform</td>
      <td>
        <ul>
          <li>Comprehensive tf alias suite for init, plan, apply, state, and workspace operations.</li>
          <li><code>tfpnc</code> alias for plan output without color codes, useful when redirecting to a file.</li>
          <li>Prompt workspace context helpers for tofu and terraform directories.</li>
          <li>Mode-switch helpers between tofu and terraform, with optional tfswitch config linking in zsh.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Docker Compose</td>
      <td>
        <ul>
          <li>Short aliases for common compose up, down, and run workflows.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Git</td>
      <td>
        <ul>
          <li>Alias set for frequent git workflows such as add, checkout, fetch, merge, and pull.</li>
          <li>Helpers for checkout-and-pull, clone-and-open, and batch fetch and pull across repo directories.</li>
          <li>Optional directory shortcuts for configured git workspace roots.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>PowerShell</td>
      <td>
        <ul>
          <li>Upgrade helper to refresh PowerShell and install WSMan dependencies.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>direnv</td>
      <td>
        <ul>
          <li>Startup hook integration for bash and zsh.</li>
          <li>Asset bootstrap into direnv lib for shared environment helper scripts.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Node and npm</td>
      <td>
        <ul>
          <li>XDG-aligned node and npm path configuration in zsh.</li>
          <li>Automatic npmrc initialization when missing.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>grep</td>
      <td>
        <ul>
          <li>Colorized grep, egrep, and fgrep defaults with common VCS and tooling directories excluded.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>GNU utilities</td>
      <td>
        <ul>
          <li>Preferred GNU command aliases when available, with fallback behavior when not present.</li>
          <li>Installer scripts to provision core GNU packages through Homebrew.</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>bash</li>
          <li>zsh</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>


# Notable changes

### 1.0

- Initial commit

### 1.1

- Added `tfswitch` config for both terraform and tofu
- Added `tfpnc` alias -> `tf plan -no-color -concise` (useful when redirecting a plan to a text file)
- Added Azure Profile Manager helper (by Austin Maddox)

### 1.2

- AWS profile manager: added support for an optional region to be passed when setting the current profile.
- Tf: Added `tfpnc` alias for plan output without color codes, useful when redirecting to a file.
