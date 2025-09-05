#!/usr/bin/env bash
# Test popup script for tmux-mru functionality
# This script demonstrates the core MRU window switching with popup and preview

# Test script for MRU window switching with popup preview
test_mru_popup() {
    echo "🧪 Testing MRU Popup Window Switcher"
    echo "======================================"
    
    # Check if we're in tmux
    if [ -z "$TMUX" ]; then
        echo "❌ This script must be run inside tmux"
        echo "   Start tmux first: tmux new-session"
        exit 1
    fi
    
    # Check dependencies
    if ! command -v fzf >/dev/null 2>&1; then
        echo "❌ fzf not found. Install with:"
        echo "   brew install fzf  # macOS"
        echo "   apt install fzf   # Ubuntu"
        exit 1
    fi
    
    # Check tmux version
    tmux_version=$(tmux -V | cut -d' ' -f2 | tr -d 'v')
    major_version=$(echo "$tmux_version" | cut -d'.' -f1)
    minor_version=$(echo "$tmux_version" | cut -d'.' -f2)
    
    echo "📋 Environment Check:"
    echo "   tmux version: $tmux_version"
    echo "   fzf: $(which fzf)"
    echo ""
    
    # Test 1: Basic window listing (without MRU)
    echo "🔍 Test 1: Basic window list"
    current_session=$(tmux display-message -p '#S')
    echo "   Current session: $current_session"
    
    # List windows excluding current
    window_list=$(tmux list-windows -F "#I:#W" | grep -v "^$(tmux display-message -p '#I'):")
    if [ -z "$window_list" ]; then
        echo "   ⚠️  Only one window detected. Create more windows to test properly:"
        echo "      Ctrl+B c  (create new window)"
        echo "      Ctrl+B ,  (rename window)"
    else
        echo "   Available windows:"
        echo "$window_list" | sed 's/^/      /'
    fi
    echo ""
    
    # Test 2: MRU History Check
    echo "🔍 Test 2: MRU history check"
    mru_history_file="$HOME/.tmux/plugins/tmux-mru/data/mru-history"
    if [ -f "$mru_history_file" ]; then
        echo "   ✅ MRU history found:"
        head -5 "$mru_history_file" | sed 's/^/      /'
    else
        echo "   📝 No MRU history (plugin not used yet)"
        echo "   Creating sample MRU data..."
        mkdir -p "$(dirname "$mru_history_file")"
        tmux list-windows -a -F "$(date +%s):#{session_name}:#{window_index}:#{window_name}" | head -5 > "$mru_history_file"
        echo "      Sample data created"
    fi
    echo ""
    
    # Test 3: Simple popup test
    echo "🔍 Test 3: Simple popup test"
    if [ "$major_version" -lt 3 ] || ([ "$major_version" -eq 3 ] && [ "$minor_version" -lt 2 ]); then
        echo "   ⚠️  tmux version too old for display-popup (need 3.2+)"
        echo "   Falling back to display-menu test..."
        
        # Create simple menu
        menu_items=""
        counter=1
        while IFS=: read -r window_id window_name; do
            if [ $counter -le 5 ]; then
                menu_items="$menu_items \"$counter. $window_id - $window_name\" \"\" \"\""
            fi
            counter=$((counter + 1))
        done <<< "$window_list"
        
        if [ -n "$menu_items" ]; then
            echo "   Testing display-menu..."
            eval "tmux display-menu -T \"Test Windows\" $menu_items"
        fi
    else
        echo "   ✅ Popup support available"
        echo "   Testing basic popup..."
        tmux display-popup -w 50% -h 10 -E "echo 'Popup test successful!'; sleep 2"
    fi
    echo ""
}

# Advanced popup test with preview
test_advanced_popup() {
    echo "🚀 Test 4: Advanced MRU popup with preview"
    
    # Create the popup command similar to your request
    popup_command='
    current_session=$(tmux display-message -p "#S")
    current_window=$(tmux display-message -p "#I")
    
    # Get MRU history or fallback to all windows
    mru_file="$HOME/.tmux/plugins/tmux-mru/data/mru-history"
    
    if [ -f "$mru_file" ]; then
        # Use MRU order
        while IFS=: read -r timestamp session window name; do
            session_window="$session:$window"
            if [ "$session:$window" != "$current_session:$current_window" ]; then
                # Verify window still exists
                if tmux list-windows -a -F "#{session_name}:#{window_index}" | grep -q "^$session_window$"; then
                    echo "$session_window - $name"
                fi
            fi
        done < "$mru_file"
    else
        # Fallback to all windows except current
        tmux list-windows -a -F "#{session_name}:#{window_index} - #{window_name}" | \
            grep -v "^$current_session:$current_window "
    fi | \
    fzf --reverse \
        --height=40% \
        --border \
        --header="🔄 MRU Windows (Enter: switch, Esc: cancel)" \
        --preview="echo {} | cut -d\" \" -f1 | xargs -I {} tmux capture-pane -t {} -p | tail -5" \
        --preview-window="right:50%:wrap" | \
    cut -d" " -f1 | \
    xargs -I {} tmux select-window -t {}
    '
    
    # Check if we can run the popup
    if tmux display-popup -h 1 -w 1 echo "test" >/dev/null 2>&1; then
        echo "   🎯 Running advanced MRU popup..."
        tmux display-popup -w 80% -h 60% -E "$popup_command"
        echo "   ✅ Popup executed (check if window switched)"
    else
        echo "   ❌ display-popup failed, trying alternative..."
        eval "$popup_command"
    fi
    echo ""
}

# Performance test
test_performance() {
    echo "⚡ Test 5: Performance benchmark"
    
    # Create test history with many windows
    test_history_file="/tmp/test-mru-history"
    for i in {1..20}; do
        echo "$(($(date +%s) - i)):session$((i % 3 + 1)):$((i % 5 + 1)):window$i" >> "$test_history_file"
    done
    
    echo "   Created test history with $(wc -l < "$test_history_file") entries"
    
    # Time the window list generation
    echo "   Timing window list generation..."
    time_start=$(date +%s%3N)
    
    # Simulate the core listing operation
    current_session="main"
    current_window="1"
    while IFS=: read -r timestamp session window name; do
        session_window="$session:$window"
        if [ "$session:$window" != "$current_session:$current_window" ]; then
            echo "$session_window - $name" >/dev/null
        fi
    done < "$test_history_file" >/dev/null
    
    time_end=$(date +%s%3N)
    duration=$((time_end - time_start))
    
    echo "   Duration: ${duration}ms"
    if [ "$duration" -lt 200 ]; then
        echo "   ✅ Performance target met (<200ms)"
    else
        echo "   ⚠️  Performance target missed (${duration}ms > 200ms)"
    fi
    
    rm -f "$test_history_file"
    echo ""
}

# Your requested one-liner test
test_oneliner() {
    echo "🎯 Test 6: Your requested one-liner popup"
    echo "display-popup -E \"tmux list-windows | grep -v \\\"^\\$(tmux display-message -p '#S')\\$\\\" | fzf --reverse --preview 'tmux capture-pane -t {}' | cut -d ':' -f 1 | xargs tmux select-window -t\""
    echo ""
    
    if tmux display-popup -h 1 -w 1 echo "test" >/dev/null 2>&1; then
        echo "   Executing your one-liner..."
        tmux display-popup -E "tmux list-windows | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse --preview 'tmux capture-pane -t {}' | cut -d ':' -f 1 | xargs tmux select-window -t"
        echo "   ✅ One-liner executed"
    else
        echo "   ❌ display-popup not available"
    fi
    echo ""
}

# Main execution
main() {
    clear
    echo "🔬 TMUX MRU Plugin - Test Suite"
    echo "================================"
    echo ""
    
    test_mru_popup
    test_advanced_popup
    test_performance
    test_oneliner
    
    echo "🎉 Test suite completed!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Create more tmux windows: Ctrl+B c"
    echo "   2. Switch between windows to build MRU history"
    echo "   3. Test the plugin: Ctrl+B W"
    echo "   4. Run this script again to see MRU in action"
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi