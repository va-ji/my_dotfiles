alias nv='nvim'
alias gp='git pull'
alias gpu='git push'
alias gpuwl='git push --force-with-lease'
alias sourceme='. ~/.config/zsh/.zshrc'

# ── Config editing ───────────────────────────────────────────
# Convention: <tool>conf opens that tool's config in $EDITOR.
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

# shell
alias zconf='${EDITOR:-nvim} $CONF/zsh/.zshrc'
alias aconf='${EDITOR:-nvim} $CONF/zsh/alias.sh && . $CONF/zsh/alias.sh'   # edit + reload aliases
alias zenv='${EDITOR:-nvim} ~/.zshenv'

# editor (cd in so telescope/file pickers see the whole config)
alias nvconf='cd $CONF/nvim && ${EDITOR:-nvim} init.lua'

# terminal / multiplexer
alias alconf='${EDITOR:-nvim} $CONF/alacritty/alacritty.toml'
alias tconf='${EDITOR:-nvim} $CONF/tmux/tmux.conf'

# desktop (sway + friends)
alias swconf='${EDITOR:-nvim} $CONF/sway/config'
alias wbconf='${EDITOR:-nvim} $CONF/waybar/config'
alias wbcss='${EDITOR:-nvim} $CONF/waybar/style.css'
alias woconf='${EDITOR:-nvim} $CONF/wofi/config'
alias mkconf='${EDITOR:-nvim} $CONF/mako/config'

# git
alias gconf='${EDITOR:-nvim} ~/.gitconfig'
alias gignore='${EDITOR:-nvim} $CONF/git/ignore'

# jump to the config dir itself
alias cdconf='cd $CONF'
