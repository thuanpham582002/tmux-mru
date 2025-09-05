# tmux-mru plugin - Complete version with Window + Session MRU
set-environment -g MRU_DATA_DIR "/Users/noroom113/tmux-mru-plugin/data"
set-environment -g MRU_SCRIPTS_DIR "/Users/noroom113/tmux-mru-plugin/scripts"
set-environment -g MRU_POPUP_WIDTH "70%"
set-environment -g MRU_POPUP_HEIGHT "50%"
set-environment -g MRU_MAX_HISTORY "20"
set-environment -g MRU_PREVIEW_LINES "5"

# Create data directory
run-shell "mkdir -p /Users/noroom113/tmux-mru-plugin/data"

# Key bindings
bind-key W run-shell "/Users/noroom113/tmux-mru-plugin/scripts/mru-switcher"           # Window MRU
bind-key S run-shell "/Users/noroom113/tmux-mru-plugin/scripts/mru-session-switcher"  # Session MRU

# Window MRU tracking hooks
set-hook -g after-select-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"
set-hook -g after-new-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"

# Session MRU tracking hooks  
set-hook -g client-session-changed "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update-session'"
set-hook -g session-created "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update-session'"