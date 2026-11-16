#!/usr/bin/env bash
# Set up the dev environment on a fresh Fedora machine.
#   git clone https://github.com/va-ji/my_dotfiles.git ~/my_dotfiles && ~/my_dotfiles/install.sh
# Safe to re-run: every step skips work that is already done.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim tmux sway wofi waybar mako alacritty zsh)

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

if ! command -v dnf >/dev/null; then
  echo "This script targets Fedora (dnf). Install packages manually on other distros." >&2
  exit 1
fi

log "Enabling COPR repos"
# swaylock-effects (blur/clock/screenshot lock screen) is not in Fedora's main repos.
# vrumger's COPR packages the maintained jirutka fork (v1.7.0.0):
#   https://github.com/jirutka/swaylock-effects
sudo dnf copr enable -y vrumger/swaylock-effects

log "Installing system packages"
sudo dnf install -y \
  git stow curl unzip make gcc cmake \
  neovim ripgrep fd-find fzf nodejs-npm python3 \
  tmux wl-clipboard \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  sway swayidle waybar wofi foot grim slurp mako \
  alacritty pavucontrol network-manager-applet \
  blueman brightnessctl playerctl \
  grimshot libnotify   # screenshots (grimshot is sway's official helper)

log "Installing swaylock-effects"
# It ships /usr/bin/swaylock too, so it must replace Fedora's plain swaylock.
if rpm -q swaylock >/dev/null 2>&1; then
  sudo dnf swap -y swaylock swaylock-effects
else
  sudo dnf install -y swaylock-effects
fi

log "Seeding a sway config if the repo has none"
if [[ ! -e "$DOTFILES/sway/.config/sway/config" ]]; then
  mkdir -p "$DOTFILES/sway/.config/sway"
  cp /etc/sway/config "$DOTFILES/sway/.config/sway/config"
  echo "Copied Fedora's default sway config into the repo. Customise and commit it."
fi

log "Linking configs with stow"
# Move a pre-existing real file/dir out of the way so stow doesn't refuse.
backup_if_real() {
  if [[ -e "$1" && ! -L "$1" ]]; then
    local backup="$1.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up $1 -> $backup"
    mv "$1" "$backup"
  fi
}
shopt -s nullglob  # globs that match nothing expand to nothing
for pkg in "${PACKAGES[@]}"; do
  # Things under ~/.config (most packages)
  for item in "$DOTFILES/$pkg/.config"/*; do
    backup_if_real "$HOME/.config/$(basename "$item")"
  done
  # Dotfiles that live directly in $HOME (e.g. zsh/.zshenv)
  for item in "$DOTFILES/$pkg"/.[!.]*; do
    [[ "$(basename "$item")" == .config ]] && continue
    backup_if_real "$HOME/$(basename "$item")"
  done
  mkdir -p "$HOME/.config"
  stow -d "$DOTFILES" -t "$HOME" --restow "$pkg"
  echo "linked $pkg"
done

log "Making zsh the default shell"
ZSH_PATH="$(command -v zsh)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
  sudo usermod --shell "$ZSH_PATH" "$USER"
  echo "Default shell set to $ZSH_PATH (takes effect at next login)"
else
  echo "already zsh"
fi

log "Installing tmux plugins"
mkdir -p "$HOME/lib/external"
clone() { [[ -d "$2" ]] || git clone --depth 1 "$1" "$2"; }
clone https://github.com/laktak/extrakto "$HOME/lib/external/extrakto"
clone https://github.com/wfxr/tmux-fzf-url "$HOME/lib/external/tmux-fzf-url"

log "Installing Oh My Zsh"
# Plain clone instead of the official installer: that one overwrites ~/.zshrc
# and changes the shell itself, which this script and zsh/.config/zsh already do.
clone https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh"

log "Installing fzf-tab-completion (fzf on every Tab in zsh)"
clone https://github.com/lincheney/fzf-tab-completion "$HOME/repos/fzf-tab-completion"

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
  * Log out, pick "Sway" in the login screen's gear menu, log back in
    (this also switches your terminals to zsh).
  * Run `claude` once to sign in.
  * Open nvim and run :checkhealth to confirm everything is found.
EOF
