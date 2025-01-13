#!/bin/bash

# Directories
DATA_DIR="$HOME/.celestia-app/data"
SNAPSHOT_FILE="$HOME/celestia_chain_4057159.tar.zst"
VALIDATOR_STATE="$HOME/.celestia-app/priv_validator_state.json"

# Stop the Celestia node service
stop_node() {
    echo "Stopping the Celestia node service..."
    sudo systemctl stop celestia-appd
    if [ $? -eq 0 ]; then
        echo "Node service stopped successfully."
    else
        echo "Failed to stop the node service. Please check the service status."
        exit 1
    fi
}

# Clean the data directory
clean_data() {
    echo "Cleaning up the data directory..."
    rm -rf "$DATA_DIR"/*
    if [ $? -eq 0 ]; then
        echo "Data directory cleaned successfully."
    else
        echo "Failed to clean the data directory."
        exit 1
    fi
}

# Reapply the snapshot
reapply_snapshot() {
    echo "Reapplying the snapshot..."
    if [ -f "$SNAPSHOT_FILE" ]; then
        zstd -d --stdout "$SNAPSHOT_FILE" | tar xf - -C "$DATA_DIR"
        echo "Snapshot reapplied successfully."
    else
        echo "Error: Snapshot file $SNAPSHOT_FILE not found."
        exit 1
    fi

    # Restore validator state
    if [ -f "$VALIDATOR_STATE" ]; then
        cp "$VALIDATOR_STATE" "$DATA_DIR/priv_validator_state.json"
        echo "Validator state restored successfully."
    else
        echo "Error: Validator state file $VALIDATOR_STATE not found."
        exit 1
    fi
}

# Start the Celestia node service
start_node() {
    echo "Starting the Celestia node service..."
    sudo systemctl start celestia-appd
    if [ $? -eq 0 ]; then
        echo "Node service started successfully."
    else
        echo "Failed to start the node service. Please check the logs."
        exit 1
    fi
}

# Main execution flow
echo "Initiating rollback procedure..."
stop_node
clean_data
reapply_snapshot
start_node
echo "Rollback procedure completed."

