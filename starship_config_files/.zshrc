# ~/.zshrc — root Doom config

# --- Basic zsh initialization ---
autoload -Uz compinit
compinit
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history

# --- Quality-of-life aliases ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gp='git pull'
alias gl='git log --oneline --graph --decorate'
alias pact='pacman -Syu'

# --- Visual flair ---
echo ""
figlet "DOOM CONSOLE" | lolcat
echo ""

# --- PATH setup (fixed with proper slashes) ---
export PATH="$PATH:/root/.duckdb/cli/latest"
export PATH="$PATH:/usr/bin/lua-5.4.8/src"
export PATH="$PATH:/usr/sbin"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# --- Doom FX (pulse + squirrel) ---
RED='\033[38;5;196m'
ORANGE='\033[38;5;208m'
YELLOW='\033[38;5;226m'
WHITE='\033[38;5;231m'
RESET='\033[0m'

doom_pulse() {
  local colors=("$RED" "$ORANGE" "$YELLOW" "$WHITE" "$YELLOW" "$ORANGE" "$RED")
  for c in "${colors[@]}"; do
    echo -ne "\r${c}⚡ SYSTEM ARMED ⚡${RESET}"
    sleep 0.04
  done
  echo -ne "\r                             \r"
}

doom_squirrel_guard() {
  local icons=("🐿" "💀" "⚙" "🔥" "🩸" "🐾")
  local i=$((RANDOM % ${#icons[@]}))
  echo -ne "${icons[$i]} "
}

doom_pretty() {
  doom_pulse
}

autoload -U add-zsh-hook
add-zsh-hook precmd doom_pretty

# --- Starship initialization ---
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(/usr/sbin/starship init zsh)"

