# tmux-mru plugin - Working version
set-environment -g MRU_DATA_DIR "/Users/noroom113/tmux-mru-plugin/data"
set-environment -g MRU_SCRIPTS_DIR "/Users/noroom113/tmux-mru-plugin/scripts"

# Create data directory
run-shell "mkdir -p /Users/noroom113/tmux-mru-plugin/data"

# Key binding - Prefix + W
bind-key W run-shell "/Users/noroom113/tmux-mru-plugin/scripts/mru-switcher"

# MRU tracking hooks  
set-hook -g after-select-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"
set-hook -g after-new-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"