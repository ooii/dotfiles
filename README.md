# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io).
Includes zsh + zinit + starship + atuin + tmux, with an **automatic
per-machine color identity** (same hostname always gets the same color, across
prompt and tmux).

## What's in the box

| Tool                  | Purpose                                                |
| --------------------- | ------------------------------------------------------ |
| **zsh + zinit**       | Shell + plugin manager (turbo lazy loading)            |
| **starship**          | Prompt with git / venv / cwd truncation / per-host color |
| **atuin**             | History with directory-scoped Ctrl-R (+ optional sync) |
| **fzf-tab**           | Fuzzy tab completion with preview                      |
| **zsh-autosuggestions / fast-syntax-highlighting** | Quality-of-life       |
| **zoxide**            | `cd` with frecency (`cd foo` jumps to foo)             |
| **direnv**            | Per-directory env vars (auto venv, AWS profile, etc.)  |
| **mise**              | Per-project Node/Python/Go versions                    |
| **tmux** + plugins    | resurrect, continuum, yank, vim-tmux-navigator         |
| **eza / bat / delta / ripgrep / fd / lazygit** | Modern CLI replacements  |

---

## Quick start: test in Docker (iterate on a fresh Ubuntu)

From the repo root:

```bash
chmod +x test/run.sh .chezmoiscripts/*.sh
./test/run.sh proliant       # simulate a machine called "proliant"
```

Inside the container:

```bash
curl -fsSL https://get.chezmoi.io | sh -s -- -b $HOME/.local/bin
export PATH=$HOME/.local/bin:$PATH
chezmoi init --source=$HOME/dotfiles --apply
exec zsh
```

The container's filesystem is thrown away on exit — re-run `./test/run.sh` to
start fresh. To preview how different machines will look:

```bash
for h in mbp-farid proliant optiplex-01 optiplex-02 nas-syno hopcast-dev; do
  ./test/run.sh "$h"
done
```

Each hostname gets a stable color derived from a sha1 hash, so your Mac always
shows the same color, `proliant` always shows the same color, etc.

---

## Real deploy on a new machine

Once the dotfiles are pushed to `github.com/<you>/dotfiles`:

```bash
# One-liner on a fresh machine (Mac or Linux):
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-user>
```

This will:

1. Install `chezmoi` into `~/.local/bin`.
2. Clone your repo into `~/.local/share/chezmoi`.
3. Prompt for your name / email / optional hostname override
   (written to `~/.config/chezmoi/chezmoi.toml`).
4. Run `chezmoi apply`, which:
   - Executes `.chezmoiscripts/run_onchange_before_10-install-tools.sh` to
     install all the binaries (brew on Mac, apt + GitHub releases on Linux).
   - Writes `~/.zshrc`, `~/.tmux.conf`, `~/.config/starship.toml`, etc.
5. Tell you to `chsh -s $(which zsh)` if you're not already on zsh.

Open a new terminal, and you're done. First zsh launch takes ~10 s to clone
zinit and install plugins; subsequent launches are fast.

---

## Day-to-day workflow

```bash
chezmoi edit ~/.zshrc       # opens the source template in $EDITOR
chezmoi diff                # preview what would change
chezmoi apply               # apply locally
chezmoi cd && git add -A && git commit -m "…" && git push
# on other machines:
chezmoi update              # pull + apply
```

---

## How the auto-color works

In `.chezmoitemplates/machine-color`:

1. Take the effective hostname (override from `chezmoi.toml` wins, else
   system hostname).
2. `sha1sum` it, take the first byte (0–255).
3. Modulo the 18-color palette → stable color for this machine.
4. That color is written into `starship.toml` and `tmux.conf` at
   `chezmoi apply` time.

This means: no mapping to maintain, new machines get a color automatically,
and the color is *identical* in prompt and tmux.

Need to pin a specific machine to a specific color? Edit
`.chezmoidata/hosts.yaml`:

```yaml
hosts:
  mbp-farid:
    color: "bright-green"
```

---

## Directory-scoped history (atuin)

`~/.config/atuin/config.toml` sets `filter_mode = "directory"`, so when you
hit **Ctrl-R** inside a project, you only see commands you've run in that
directory. Press Ctrl-R again inside the search UI to cycle to global /
host / session filters.

Want cross-machine history sync? Self-host atuin on your homelab and set
`sync_address` in the config.

---

## Layout

```
.
├── .chezmoi.toml.tmpl            # questions asked on first init
├── .chezmoidata/
│   └── hosts.yaml                # optional per-host overrides
├── .chezmoitemplates/
│   └── machine-color             # shared auto-color logic
├── .chezmoiscripts/
│   ├── run_onchange_before_10-install-tools.sh.tmpl
│   └── run_once_after_20-bootstrap.sh
├── dot_zshrc.tmpl                # -> ~/.zshrc
├── dot_tmux.conf.tmpl            # -> ~/.tmux.conf
├── dot_config/
│   ├── starship.toml.tmpl        # -> ~/.config/starship.toml
│   └── atuin/config.toml         # -> ~/.config/atuin/config.toml
└── test/
    ├── Dockerfile.ubuntu
    └── run.sh
```

---

## First-time repo setup (for you, once)

```bash
cd /path/to/this/dotfiles
git init
git add -A
git commit -m "Initial chezmoi-managed dotfiles"
gh repo create dotfiles --private --source=. --push
```

Then on each of your machines, run the one-liner from the "Real deploy"
section above.
