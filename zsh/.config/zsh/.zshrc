# ~/.config/zsh/.zshrc — interactive shell config
#
# Oh My Zsh handles the basics (completion menu, key bindings, history options,
# auto_cd, prompt). Extra plugins come from Fedora packages / install.sh.
# Order matters: settings -> Oh My Zsh -> fzf -> fzf-tab-completion ->
# autosuggestions -> syntax-highlighting (always last).

# --- PATH -------------------------------------------------------------------
# Same as Fedora's default .bashrc: user binaries (e.g. claude) come first.
typeset -U path                      # -U = drop duplicate entries automatically
path=("$HOME/.local/bin" "$HOME/bin" $path)
export PATH

export EDITOR=nvim
export VISUAL=nvim

# --- History (set before Oh My Zsh so it keeps these) -----------------------
HISTFILE="$ZDOTDIR/.zsh_history"     # ignored by git (see .gitignore)
HISTSIZE=50000
SAVEHIST=50000

# --- Oh My Zsh --------------------------------------------------------------
# Cloned by install.sh (not the official installer, which would overwrite this file).
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode disabled   # update when you choose: `omz update`
plugins=(
  git                                # gst, gco, gp, glog ... (`alias | grep git` lists them)
  dnf                                # dnfi = install, dnfu = upgrade, dnfs = search ...
  colored-man-pages                  # easier-to-read man pages
)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# --- My overrides (after Oh My Zsh so these win) ----------------------------
setopt HIST_IGNORE_ALL_DUPS          # keep only the newest copy of a repeated command
setopt INTERACTIVE_COMMENTS          # allow # comments on the command line, like bash
alias ll='ls -lah'
alias vim='nvim'

# --- fzf --------------------------------------------------------------------
# Ctrl-R fuzzy history, Ctrl-T fuzzy file picker, Alt-C fuzzy cd, `**<Tab>`.
command -v fzf >/dev/null && source <(fzf --zsh)

# Inside tmux, open every fzf picker (incl. Tab completion below) as a centered
# tmux popup instead of inline. Outside tmux fzf ignores --tmux.
# Uses fzf's built-in --tmux rather than FZF_TMUX_OPTS: that variable makes
# fzf hand out the command "fzf-tmux -p ... --", which fzf-tab-completion runs
# as one quoted word ("$fzf") -> "command not found: fzf-tmux -p 80%,60% --".
unset FZF_TMUX_OPTS                  # in case an old tmux server still passes it on
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--tmux center,80%,60%"

# fzf-tab-completion — setup from its README
# (repo: github.com/lincheney/fzf-tab-completion, cloned to ~/repos by install.sh)
source ~/repos/fzf-tab-completion/zsh/fzf-zsh-completion.sh
bindkey '^I' fzf_completion

# --- Fedora-packaged plugins ------------------------------------------------
# Grey suggestion from history as you type; press → (Right arrow) to accept
[[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Must be sourced last: colours commands green (valid) / red (not found)
[[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Machine-specific extras that shouldn't be in git (work aliases, tokens...)
[[ -r "$ZDOTDIR/local.zsh" ]] && source "$ZDOTDIR/local.zsh"
