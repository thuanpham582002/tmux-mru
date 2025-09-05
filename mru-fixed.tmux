# tmux-mru plugin configuration - Fixed version
# Set plugin directory  
set-environment -g MRU_PLUGIN_DIR "/Users/noroom113/tmux-mru-plugin"
set-environment -g MRU_DATA_DIR "/Users/noroom113/tmux-mru-plugin/data"
set-environment -g MRU_SCRIPTS_DIR "/Users/noroom113/tmux-mru-plugin/scripts"
set-environment -g MRU_POPUP_WIDTH "70%"
set-environment -g MRU_POPUP_HEIGHT "50%"
set-environment -g MRU_MAX_HISTORY "20"
set-environment -g MRU_PREVIEW_LINES "5"

# Create data directory
run-shell "mkdir -p /Users/noroom113/tmux-mru-plugin/data"

# Set up key binding - Prefix + W
bind-key W run-shell "/Users/noroom113/tmux-mru-plugin/scripts/mru-switcher"

# Set up hooks for MRU tracking using correct hook names
set-hook -g after-select-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"
set-hook -g after-new-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"
set-hook -g after-kill-window "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker cleanup'"