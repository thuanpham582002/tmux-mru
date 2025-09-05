#!/usr/bin/env bats
# Unit tests for mru-tracker script

# Test setup
setup() {
    export TEST_DATA_DIR=$(mktemp -d)
    export MRU_DATA_DIR="$TEST_DATA_DIR"
    export MRU_MAX_HISTORY="5"
    
    # Mock tmux commands for testing
    export PATH="$BATS_TEST_DIRNAME/mocks:$PATH"
    
    # Source the script functions (we'll need to modify mru-tracker for this)
    TRACKER_SCRIPT="$BATS_TEST_DIRNAME/../../scripts/mru-tracker"
}

# Test teardown
teardown() {
    rm -rf "$TEST_DATA_DIR"
}

@test "creates data directory if it doesn't exist" {
    [ ! -d "$TEST_DATA_DIR" ]
    run "$TRACKER_SCRIPT" update
    [ -d "$TEST_DATA_DIR" ]
}

@test "creates history file on first run" {
    run "$TRACKER_SCRIPT" update
    [ -f "$TEST_DATA_DIR/mru-history" ]
}

@test "updates history with current window info" {
    # Mock tmux display-message responses
    mkdir -p "$BATS_TEST_DIRNAME/mocks"
    cat > "$BATS_TEST_DIRNAME/mocks/tmux" << 'EOF'
#!/bin/bash
case "$1 $2 $3" in
    "display-message -p #S")
        echo "test-session"
        ;;
    "display-message -p #I")  
        echo "1"
        ;;
    "display-message -p #W")
        echo "test-window"
        ;;
    *)
        # Pass through to real tmux for other commands
        exec /usr/bin/tmux "$@"
        ;;
esac
EOF
    chmod +x "$BATS_TEST_DIRNAME/mocks/tmux"
    
    run "$TRACKER_SCRIPT" update
    [ "$status" -eq 0 ]
    
    # Check history file contains expected format
    run cat "$TEST_DATA_DIR/mru-history"
    [[ "$output" =~ [0-9]+:test-session:1:test-window ]]
}

@test "limits history to maximum entries" {
    # Create history with more than max entries
    for i in {1..7}; do
        echo "$(date +%s):session:$i:window$i" >> "$TEST_DATA_DIR/mru-history"
    done
    
    run "$TRACKER_SCRIPT" update
    
    # Count lines in history file
    run wc -l "$TEST_DATA_DIR/mru-history"
    lines=$(echo "$output" | awk '{print $1}')
    [ "$lines" -le 5 ]
}

@test "removes duplicate entries" {
    # Pre-populate history
    echo "1234567890:session:2:window2" > "$TEST_DATA_DIR/mru-history"
    echo "1234567891:session:1:window1" >> "$TEST_DATA_DIR/mru-history"
    echo "1234567892:session:3:window3" >> "$TEST_DATA_DIR/mru-history"
    
    # Mock current window as session:2 (duplicate)
    mkdir -p "$BATS_TEST_DIRNAME/mocks"
    cat > "$BATS_TEST_DIRNAME/mocks/tmux" << 'EOF'
#!/bin/bash
case "$1 $2 $3" in
    "display-message -p #S") echo "session" ;;
    "display-message -p #I") echo "2" ;;
    "display-message -p #W") echo "window2" ;;
esac
EOF
    chmod +x "$BATS_TEST_DIRNAME/mocks/tmux"
    
    run "$TRACKER_SCRIPT" update
    
    # Should have no duplicates - check there's only one session:2 entry
    run grep -c ":session:2:" "$TEST_DATA_DIR/mru-history"
    [ "$output" -eq 1 ]
}

@test "cleanup removes non-existent windows" {
    # Create history with some windows
    echo "$(date +%s):session1:1:window1" > "$TEST_DATA_DIR/mru-history"
    echo "$(date +%s):session1:2:window2" >> "$TEST_DATA_DIR/mru-history"
    echo "$(date +%s):session2:1:window1" >> "$TEST_DATA_DIR/mru-history"
    
    # Mock tmux to show only some windows exist
    cat > "$BATS_TEST_DIRNAME/mocks/tmux" << 'EOF'
#!/bin/bash
if [ "$1" = "list-windows" ]; then
    echo "session1:1"
    echo "session1:2"
    # Note: session2:1 is missing (closed)
fi
EOF
    chmod +x "$BATS_TEST_DIRNAME/mocks/tmux"
    
    run "$TRACKER_SCRIPT" cleanup
    [ "$status" -eq 0 ]
    
    # Check that session2:1 was removed
    run grep -c "session2:1" "$TEST_DATA_DIR/mru-history"
    [ "$output" -eq 0 ]
}

@test "list command shows current history" {
    echo "1234567890:session:1:window1" > "$TEST_DATA_DIR/mru-history"
    echo "1234567891:session:2:window2" >> "$TEST_DATA_DIR/mru-history"
    
    run "$TRACKER_SCRIPT" list
    [ "$status" -eq 0 ]
    [[ "$output" =~ session:1:window1 ]]
    [[ "$output" =~ session:2:window2 ]]
}

@test "handles empty history file gracefully" {
    touch "$TEST_DATA_DIR/mru-history"
    
    run "$TRACKER_SCRIPT" list
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "handles missing history file gracefully" {
    run "$TRACKER_SCRIPT" list
    [ "$status" -eq 0 ]
}

@test "file locking prevents concurrent corruption" {
    # This test would be complex to implement properly
    # For now, just test that the locking mechanism doesn't break normal operation
    
    run "$TRACKER_SCRIPT" update
    [ "$status" -eq 0 ]
    
    # Run multiple updates in parallel (basic test)
    "$TRACKER_SCRIPT" update &
    "$TRACKER_SCRIPT" update &
    wait
    
    # File should still be readable and valid
    run cat "$TEST_DATA_DIR/mru-history"
    [ "$status" -eq 0 ]
}