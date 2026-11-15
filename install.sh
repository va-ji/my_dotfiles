#!/usr/bin/env bash
# Set up the dev environment on a fresh Fedora machine.
#   git clone https://github.com/va-ji/my_dotfiles.git ~/my_dotfiles && ~/my_dotfiles/install.sh
# Safe to re-run: every step skips work that is already done.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim tmux sway wofi waybar mako alacritty)

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

if ! command -v dnf >/dev/null; then
  echo "This script targets Fedora (dnf). Install packages manually on other distros." >&2
  exit 1
fi

log "Installing system packages"
sudo dnf install -y \
  git stow curl unzip make gcc cmake \
  neovim ripgrep fd-find fzf nodejs-npm python3 \
  tmux wl-clipboard \
  sway swaylock-effects swayidle waybar wofi foot grim slurp mako \
  alacritty sway-screenshot pavucontrol network-manager-applet

log "Seeding a sway config if the repo has none"
if [[ ! -e "$DOTFILES/sway/.config/sway/config" ]]; then
  mkdir -p "$DOTFILES/sway/.config/sway"
  cp /etc/sway/config "$DOTFILES/sway/.config/sway/config"
  echo "Copied Fedora's default sway config into the repo. Customise and commit it."
fi

log "Linking configs with stow"
for pkg in "${PACKAGES[@]}"; do
  # Move pre-existing real files/dirs out of the way so stow doesn't refuse.
  for item in "$DOTFILES/$pkg/.config"/*; do
    target="$HOME/.config/$(basename "$item")"
    if [[ -e "$target" && ! -L "$target" ]]; then
      backup="$target.bak.$(date +%Y%m%d%H%M%S)"
      echo "Backing up $target -> $backup"
      mv "$target" "$backup"
    fi
  done
  mkdir -p "$HOME/.config"
  stow -d "$DOTFILES" -t "$HOME" --restow "$pkg"
  echo "linked $pkg"
done

log "Installing tmux plugins"
mkdir -p "$HOME/lib/external"
clone() { [[ -d "$2" ]] || git clone --depth 1 "$1" "$2"; }
clone https://github.com/laktak/extrakto "$HOME/lib/external/extrakto"
clone https://github.com/wfxr/tmux-fzf-url "$HOME/lib/external/tmux-fzf-url"

log "Installing Hack Nerd Font (icons in nvim)"
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
if ! fc-list | grep -qi "Hack Nerd Font"; then
  mkdir -p "$FONT_DIR"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz \
    | tar -xJ -C "$FONT_DIR"
  fc-cache -f "$FONT_DIR"
else
  echo "already installed"
fi

log "Installing Claude Code"
if ! command -v claude >/dev/null && [[ ! -x "$HOME/.local/bin/claude" ]]; then
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "already installed"
fi

log "Installing Neovim plugins (lazy.nvim, headless)"
nvim --headless "+Lazy! restore" +qa || echo "Plugin sync had errors; open nvim and run :Lazy"

log "Done"
cat <<'EOF'
Next steps:
  * Log out, pick "Sway" in the login screen's gear menu, log back in.
  * Run `claude` once to sign in.
  * Open nvim and run :checkhealth to confirm everything is found.
EOF
