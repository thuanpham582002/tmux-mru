# tmux-mru simple configuration
# Set plugin directory
set-environment -g MRU_PLUGIN_DIR "/Users/noroom113/tmux-mru-plugin"
set-environment -g MRU_DATA_DIR "/Users/noroom113/tmux-mru-plugin/data"
set-environment -g MRU_SCRIPTS_DIR "/Users/noroom113/tmux-mru-plugin/scripts"
set-environment -g MRU_POPUP_WIDTH "70%"
set-environment -g MRU_POPUP_HEIGHT "50%"
set-environment -g MRU_MAX_HISTORY "20"
set-environment -g MRU_PREVIEW_LINES "5"

# Set up key binding
bind-key W run-shell "/Users/noroom113/tmux-mru-plugin/scripts/mru-switcher"

# Set up hooks for MRU tracking
set-hook -g window-active-changed "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"
set-hook -g session-changed "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker update'"
set-hook -g window-closed "run-shell '/Users/noroom113/tmux-mru-plugin/scripts/mru-tracker cleanup'"