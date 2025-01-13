import os
import subprocess
import requests
import hashlib
import time

# Configuration
SNAPSHOT_FILE = "/root/celestia_chain_4057159.tar.zst"  # Path to your snapshot
EXPECTED_HASH = "7f88a3212905ea96a1eb68bbe8ba4d52aef091453f2e1dc307ce7c30a7cd814f"  # Update with the expected hash of the snapshot
NODE_RPC_URL = "http://localhost:26657"  # Celestia node RPC endpoint
SYNC_CHECK_INTERVAL = 30  # Seconds between sync checks
MAX_SYNC_TIME = 3600  # Maximum allowed sync time in seconds

def verify_snapshot_integrity(snapshot_file, expected_hash):
    print(f"Verifying snapshot integrity for {snapshot_file}...")
    if not os.path.exists(snapshot_file):
        print("Error: Snapshot file does not exist.")
        return False
    
    hash_sha256 = hashlib.sha256()
    with open(snapshot_file, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_sha256.update(chunk)
    calculated_hash = hash_sha256.hexdigest()
    
    if calculated_hash == expected_hash:
        print(calculated_hash)
        print(expected_hash)
        print("Snapshot integrity verified.")
        return True
    else:
        print(f"Snapshot integrity failed. Expected: {expected_hash}, Got: {calculated_hash}")
        return False

def main():
    # Step 1: Verify snapshot integrity
    if not verify_snapshot_integrity(SNAPSHOT_FILE, EXPECTED_HASH):
        return

if __name__ == "__main__":
    main()
