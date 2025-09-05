#!/usr/bin/env bash
# tmux-mru: Most Recently Used window switcher with popup preview
# Version: 1.0.0
# Author: tmux-mru-plugin

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MRU_DIR="$CURRENT_DIR"
DATA_DIR="$MRU_DIR/data"
SCRIPTS_DIR="$MRU_DIR/scripts"

# Default configuration
default_key_binding="W"
default_popup_width="70%"
default_popup_height="50%"
default_max_history="20"
default_preview_lines="5"

# Get user configurations
get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value="$(tmux show-option -gqv "$option")"
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

# Configuration variables
key_binding=$(get_tmux_option "@mru-key-binding" "$default_key_binding")
popup_width=$(get_tmux_option "@mru-popup-width" "$default_popup_width")
popup_height=$(get_tmux_option "@mru-popup-height" "$default_popup_height")
max_history=$(get_tmux_option "@mru-max-history" "$default_max_history")
preview_lines=$(get_tmux_option "@mru-preview-lines" "$default_preview_lines")

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Set up key binding
tmux bind-key "$key_binding" run-shell "$SCRIPTS_DIR/mru-switcher"

# Set up hooks for MRU tracking
tmux set-hook -g window-active-changed "run-shell '$SCRIPTS_DIR/mru-tracker update'"
tmux set-hook -g session-changed "run-shell '$SCRIPTS_DIR/mru-tracker update'"
tmux set-hook -g window-closed "run-shell '$SCRIPTS_DIR/mru-tracker cleanup'"

# Export configuration for scripts
tmux set-environment -g MRU_DATA_DIR "$DATA_DIR"
tmux set-environment -g MRU_SCRIPTS_DIR "$SCRIPTS_DIR"
tmux set-environment -g MRU_POPUP_WIDTH "$popup_width"
tmux set-environment -g MRU_POPUP_HEIGHT "$popup_height"
tmux set-environment -g MRU_MAX_HISTORY "$max_history"
tmux set-environment -g MRU_PREVIEW_LINES "$preview_lines"