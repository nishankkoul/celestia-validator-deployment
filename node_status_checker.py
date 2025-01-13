import requests

NODE_RPC_URL = "http://localhost:26657" 

def get_node_status():
    """Fetch and display the node's current status."""
    try:
        response = requests.get(f"{NODE_RPC_URL}/status")
        if response.status_code == 200:
            status = response.json().get("result", {})
            sync_info = status.get("sync_info", {})
            node_info = status.get("node_info", {})
            
            print("Celestia Node Status:")
            print(f"  Node ID: {node_info.get('id', 'N/A')}")
            print(f"  Network: {node_info.get('network', 'N/A')}")
            print(f"  Latest Block Height: {sync_info.get('latest_block_height', 'N/A')}")
            print(f"  Latest Block Time: {sync_info.get('latest_block_time', 'N/A')}")
            print(f"  Catching Up: {sync_info.get('catching_up', 'N/A')}")
        else:
            print(f"Error: Unable to fetch node status (HTTP {response.status_code})")
    except requests.RequestException as e:
        print(f"Error connecting to node RPC: {e}")

def get_net_info():
    """Fetch and display the node's peer connections."""
    try:
        response = requests.get(f"{NODE_RPC_URL}/net_info")
        if response.status_code == 200:
            net_info = response.json().get("result", {})
            peers = net_info.get("peers", [])
            
            print("\nPeer Connections:")
            print(f"  Total Peers: {len(peers)}")
            for peer in peers:
                print(f"    - {peer.get('node_info', {}).get('id', 'N/A')} ({peer.get('remote_ip', 'N/A')})")
        else:
            print(f"Error: Unable to fetch net info (HTTP {response.status_code})")
    except requests.RequestException as e:
        print(f"Error connecting to node RPC: {e}")

def main():
    print("Fetching Celestia Node Metrics...\n")
    get_node_status()
    get_net_info()

if __name__ == "__main__":
    main()
