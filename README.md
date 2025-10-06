# Dotfiles

My personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── nvim/          # Neovim config (all machines)
├── tmux/          # Tmux config (all machines)
└── sway/          # Sway window manager (work laptop only)
```

Each directory contains a `.config/` subdirectory that mirrors your home directory structure.

## Requirements

- Git
- GNU Stow

### Install Stow

**Ubuntu/Debian:**
```bash
sudo apt install stow
```

**Arch:**
```bash
sudo pacman -S stow
```

**macOS:**
```bash
brew install stow
```

## Setup on a New Machine

### 1. Clone this repository

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install configs with Stow

**Personal machine (nvim + tmux):**
```bash
stow nvim tmux
```

**Work laptop (nvim + tmux + sway):**
```bash
stow nvim tmux sway
```

**Individual packages:**
```bash
stow nvim      # Install nvim config only
stow tmux      # Install tmux config only
stow sway      # Install sway config only
```

This creates symlinks:
- `~/.config/nvim` → `~/dotfiles/nvim/.config/nvim`
- `~/.config/tmux` → `~/dotfiles/tmux/.config/tmux`
- `~/.config/sway` → `~/dotfiles/sway/.config/sway`

### 3. Verify installation

```bash
ls -la ~/.config/nvim
ls -la ~/.config/tmux
```

You should see symlinks pointing to your dotfiles repo.

## Making Changes

Since your configs are symlinked, any edits you make in `~/.config/nvim` or `~/.config/tmux` are actually editing files in `~/dotfiles/`.

**After making changes:**

```bash
cd ~/dotfiles
git add .
git commit -m "Update nvim config"
git push
```

## Uninstalling

To remove symlinks (configs stay in the repo):

```bash
cd ~/dotfiles
stow -D nvim      # Remove nvim symlinks
stow -D tmux      # Remove tmux symlinks
stow -D sway      # Remove sway symlinks
```

## Adding New Configs

To add a new application config (e.g., alacritty):

```bash
cd ~/dotfiles
mkdir -p alacritty/.config/alacritty
mv ~/.config/alacritty/* alacritty/.config/alacritty/
stow alacritty
git add alacritty
git commit -m "Add alacritty config"
```

## Troubleshooting

**"WARNING: in simulation mode; no filesystem changes made"**
- Stow is running in test mode. Add `--no` flag: `stow --no nvim`

**"WARNING: target is not owned by stow"**
- A file/directory already exists. Back it up first:
  ```bash
  mv ~/.config/nvim ~/.config/nvim.backup
  stow nvim
  ```

**Symlinks not working?**
- Make sure you run `stow` from `~/dotfiles` directory
- Use `stow -v nvim` for verbose output to debug

## How Stow Works

Stow creates symlinks from your home directory to files in the dotfiles repo.

**Example:**
```
~/dotfiles/nvim/.config/nvim/init.lua  ← actual file
              ↓
~/.config/nvim/init.lua  ← symlink
```

The directory structure inside each package (nvim/, tmux/, etc.) mirrors where files should be in your home directory.
