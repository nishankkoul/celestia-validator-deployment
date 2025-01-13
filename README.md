## Introduction

This project automates the deployment and management of a **Celestia Validator Node** on the **Mocha-4 testnet** using **Ansible**. Celestia is a modular blockchain focused on scalability and decentralization. By automating the setup, configuration, and monitoring of a Celestia validator node, this project simplifies the process of joining and running a validator on the testnet.

The solution involves using Ansible playbooks to ensure a smooth deployment process, secure storage of credentials, and comprehensive monitoring with **Grafana**. Additionally, the project provides robust error handling, logging, and rollback procedures to ensure the reliability of the deployment.

This README will guide you through the setup, configuration, and execution of the Ansible playbook, as well as how to interact with the deployed node, view logs, and monitor the node's health.

## Prerequisites

Before running the Ansible playbook, you'll need to create and configure an EC2 instance on AWS. Follow the steps below to set up the instance and ensure it's ready for deployment.

### Step 1: Launch an EC2 Instance

1. **Login to AWS Management Console**: Go to the [AWS EC2 Console](https://console.aws.amazon.com/ec2/v2/home) and click on "Launch Instance."

2. **Choose an Amazon Machine Image (AMI)**:
   - Select **Ubuntu 24.04 LTS** as the AMI.

3. **Select an Instance Type**:
   - Choose **t2.medium** as the instance type. This instance type provides 2 vCPUs and 4GB of memory, which is suitable for running the Celestia validator node.

4. **Configure Instance Details**:
   - Leave the default settings or configure according to your requirements (e.g., VPC, subnet, etc.).

5. **Add Storage**:
   - Attach a new volume with **50GB** of storage. This will be used to store the blockchain data and configuration files.

6. **Configure Security Group**:
   - Create a new security group or select an existing one.
   - Add the following **Inbound Rules** to allow traffic on the necessary ports for Celestia and monitoring:
     - **Port 26656** (for peer-to-peer communication)
     - **Port 26657** (for RPC communication)
     - **Port 26658** (for state sync)
     - **Port 8080** (for Prometheus)
     - **Port 3000** (for Grafana monitoring)

     Example:
     ```
     Type         Protocol  Port Range  Source
     ---------------------------------------------
     Custom TCP   TCP       26656       0.0.0.0/0
     Custom TCP   TCP       26657       0.0.0.0/0
     Custom TCP   TCP       26658       0.0.0.0/0
     Custom TCP   TCP       8080        0.0.0.0/0
     Custom TCP   TCP       3000        0.0.0.0/0
     ```

7. **Review and Launch**:
   - Review your settings and launch the instance.
   - Make sure to download the **.pem key pair** for SSH access to the instance.
  
  ![image](https://github.com/user-attachments/assets/9d5b4aed-3860-498d-9dcc-faddaab41dec)

### Step 2: SSH into the Instance

1. Use the `.pem` key file you downloaded earlier to SSH into the EC2 instance.
2. Run the following command to connect:

    ```bash
    ssh -i path/to/your-key.pem ubuntu@your-ec2-public-ip
    ```

Once the EC2 instance is up and running, proceed to the next steps in the playbook to automate the installation and setup of the Celestia validator node.

### Step 3: Switch to Root User

Once you've SSH'd into the EC2 instance, you need to switch to the root user to perform the necessary configurations for the Celestia validator node.

1. To switch to the root user, run the following command:

    ```bash
    sudo -i
    ```

2. This will elevate your privileges to the root user, allowing you to execute the commands required for the setup process. You can now proceed with the installation and configuration steps for the Celestia validator node.

After switching to the root user, you're ready to continue with the playbook execution or manually perform any required configurations.

## Execution

### Update and Upgrade the System

Before proceeding with the Celestia validator node installation, it's important to update and upgrade the system to ensure all the packages are up to date.

1. Run the following command to update the package list:

    ```bash
    sudo apt-get update -y
    ```

2. After the update completes, upgrade all the installed packages to their latest versions:

    ```bash
    sudo apt-get upgrade -y
    ```

These commands will ensure that your system is running the latest available software and security patches. Once the upgrade process is complete, your system will be ready for the Celestia validator node installation.

### Clone the Celestia Validator Deployment Repository

To begin the setup, we need to clone the repository that contains the Ansible playbook and related scripts for automating the Celestia validator node deployment.

1. Use the following command to clone the repository to your local machine:

    ```bash
    git clone https://github.com/nishankkoul/celestia-validator-deployment.git
    ```

2. Once the repository is cloned, navigate to the directory where the repository has been downloaded:

    ```bash
    cd celestia-validator-deployment
    ```

This repository contains all the necessary configurations, playbooks, and scripts required to deploy and manage the Celestia validator node. Proceed with the next steps to configure and deploy the node.

### Install Ansible

Now, we need to install Ansible, which will be used to automate the deployment and configuration of the Celestia validator node.

1. Install Ansible using the following command:

    ```bash
    sudo apt install ansible -y
    ```

2. After installation, verify that Ansible is installed successfully by checking its version:

    ```bash
    ansible --version
    ```

This will ensure that Ansible is set up correctly and ready for use in automating the deployment process. You can now proceed to run the Ansible playbook for the Celestia validator node.

### Configure Variables

Next, we'll navigate to the folder where the configuration variables are stored and edit the `main.yml` file to customize the deployment for your environment.

1. Change into the `celestia_validator/vars` directory:

    ```bash
    cd celestia_validator/vars
    ```

2. Open the `main.yml` file in the `vim` editor:

    ```bash
    vim main.yml
    ```

3. Edit the variables in this file as needed. You can adjust settings such as the Celestia validator's name, network configuration, and other parameters based on your setup.

    ```bash
    # vars/main.yml
    
    celestia_repo: "https://github.com/celestiaorg/celestia-app.git"
    celestia_version: "v3.2.0"
    celestia_chain_id: "mocha-4"
    celestia_wallet_name: "my-wallet"
    celestia_networks_repo: "https://github.com/celestiaorg/networks"
    celestia_genesis_file: "/root/networks/mocha-4/genesis.json"
    celestia_snap_url: "https://s3.imperator.co/testnets-snapshots/celestia/celestia_chain_4141707.tar.zst"
    celestia_service_name: "celestia-appd"
    celestia_service_exec: "/usr/local/bin/celestia-appd start"
    celestia_config_path: "/root/.celestia-app/config"
    celestia_priv_validator_file: "/root/.celestia-app/data/priv_validator_state.json"
    celestia_snap_name: "celestia_chain_4141707.tar.zst"
    ```
    Make sure to refer https://www.imperator.co/services/chain-services/testnets/celestia for the latest version of the snapshot and set the variables 'celestia_snap_url' and 'celestia_snap_name' accordingly.
 
4. After editing the file, save your changes and exit the editor:
    - Press `Esc` to exit insert mode.
    - Type `:wq` to write the changes and quit the editor.

This will ensure that the necessary variables are set up before executing the Ansible playbook to deploy the Celestia validator node.

### Execute the Ansible Playbook

Once the variables are configured, we are ready to execute the Ansible playbook to deploy the Celestia validator node.

1. Run the following command to execute the playbook:

    ```bash
    ansible-playbook deploy_celestia.yml -vvv
    ```

    - The `-vvv` flag provides detailed output, which is useful for debugging and monitoring the playbook execution.
    
2. The playbook will run through various tasks, such as installing necessary dependencies, configuring the node, applying the snapshot, generating the wallet, and more.

3. Wait for the playbook to complete. The output will show each task as it is executed, along with any relevant success or failure messages.

### Wallet Address Details

After successfully executing the Ansible playbook, the wallet address details are securely stored in the following location: **/etc/celestia/wallet_mnemonic.txt**

This file contains the mnemonic phrase generated for the wallet associated with the Celestia validator node. The wallet address is essential for interacting with the validator on the testnet.

#### Important Security Note:
- The file is stored with strict access control (`0600` permissions), meaning only the root user has access to it. This ensures the security of sensitive information like the mnemonic phrase, which is required to restore or manage the wallet in the future.
- The task for storing this wallet mnemonic is set with `no_log: true` to prevent it from being logged during playbook execution.

### Encrypt the Wallet Mnemonic File

To securely store the wallet mnemonic, we will encrypt the file using `ansible-vault` to prevent unauthorized access. This ensures that the sensitive information (such as the seed phrase) remains protected.

Run the following command to encrypt the `wallet_mnemonic.txt` file:

```bash
ansible-vault encrypt /etc/celestia/wallet_mnemonic.txt
```

You will be prompted to enter a password. This password will be used to decrypt the file later, so make sure to store it securely.

**Decrypting the File (If Needed)**

To decrypt the file and view its contents, use the following command:

```bash
ansible-vault decrypt /etc/celestia/wallet_mnemonic.txt.vault
```

### Check the Status of the Celestia Validator Service

After setting up the validator node, it's important to verify that the `celestia-appd` service is running properly.

#### Check the Service Status

To check the status of the Celestia application service, run the following command:

```bash
systemctl status celestia-appd
```

![image](https://github.com/user-attachments/assets/41437845-2124-4273-a7d7-d6f69034764e)

### Check Daemon Logs in Real-Time

To ensure that the Celestia validator node is operating correctly, you can check the logs of the `celestia-appd` service in real-time. This helps you monitor its activities and troubleshoot any potential issues as they occur.

#### View Logs in Real-Time

To view the real-time logs of the Celestia daemon, run the following command:

```bash
sudo journalctl -u celestia-appd.service -f
```

### Check if Your Node is in Sync Before Going Forward

To verify if your Celestia validator node is successfully synced with the testnet, you can check the synchronization status by comparing the block height of your node with the latest block height on the explorer. Once they match, it means your node is fully synced.

#### Check Node Sync Status

To check the current sync status of your node, run the following command:

```bash
curl -s localhost:26657/status | jq .result | jq .sync_info
```

**NOTE:** DO NOT PROCEED FORWARD TILL THE NODE IS IN SYNC COMPLETELY!

You can stay aware of the latest block height of the betwork gere: https://mocha.celenium.io/

![image](https://github.com/user-attachments/assets/32ec94a2-027e-436f-9d34-2a87f949d567)

### Claim Test Tokens from the Celestia Faucet

To participate in the Celestia testnet, you need test tokens for your validator. You can claim these test tokens from the official Celestia Mocha-4 testnet faucet.

#### How to Get Test Tokens

1. **Join the Celestia Discord**: To access the faucet, you must first join the Celestia Discord server. You can do so by visiting the following link:
   [Celestia Discord](https://discord.gg/JeRdw5veKu)

2. **Request Test Tokens**: Once you're in the Discord server, navigate to the `mocha-faucet` channel. In this channel, you can request test tokens for your wallet.

3. **Use the Command to Request Tokens**: In the `mocha-faucet` channel, use the following command to request test tokens:

   ```bash
   $request <celestia-wallet-address>
   ```

![image](https://github.com/user-attachments/assets/7b471a8b-a73f-4557-b3e1-ffb2b579e9d3)

### Check Wallet Balance

Once you have successfully claimed test tokens and your wallet is set up, you can check the balance of your Celestia wallet using the following command:

```bash
celestia-appd q bank balances <your-wallet-address>
```

Replace <your-wallet-address> with the actual wallet address you created earlier. 

This command queries the Celestia blockchain and displays the balance of your specified wallet address. It will show the amount of tokens currently held in your wallet, which is crucial before proceeding with the validator registration process.

### Exeucte the `validator_wallet.sh` Script and Lock the File Using Ansible Vault

Follow the steps below to edit the `validator_wallet.sh` script, make it executable, execute it, and lock the file containing the `valoper_address` using Ansible Vault. Firstly, 'cd' into the scripts directory.

#### Step 1: Edit the `validator_wallet.sh` Script

Open the script 'validator_wallet.sh' using the vim/nano editor and then replace the <WALLET-NAME> with the actual name of your celestia wallet.

```bash
#!/bin/bash

export CELESTIA_WALLET=<WALLET-NAME>

if [ -z "$CELESTIA_WALLET" ]; then
  echo "Error: CELESTIA_WALLET environment variable is not set."
  echo "Please set it using 'export CELESTIA_WALLET=<your_wallet_name>' and rerun this script."
  exit 1
fi

# Fetch the validator address and store it in a variable
CELESTIA_VALOPER=$(celestia-appd keys show $CELESTIA_WALLET --bech val -a)

# Write the actual validator address to a file in /etc/celestia/
echo $CELESTIA_VALOPER > /etc/celestia/valoper_address.txt

# Add the CELESTIA_VALOPER environment variable to .bash_profile
echo "Exporting CELESTIA_VALOPER to .bash_profile..."
echo "export CELESTIA_VALOPER=${CELESTIA_VALOPER}" >> $HOME/.bash_profile

# Reload .bash_profile to make the variable available in the current session
source $HOME/.bash_profile

# Confirm the export
echo "CELESTIA_VALOPER environment variable has been set."
```

Save the script and exit the editor.

#### Step 2: Make the Script Executable

Change the permissions of the script to make it executable:

```bash
chmod +x validator_wallet.sh
```

#### Step 3: Execute the Script

Run the script to create the validator wallet and generate the valoper_address:

```bash
./validator_wallet.sh
```

The valoper_address.txt file will be created at /etc/celestia/valoper_address.txt.

#### Step 4: Encrypt the File with Ansible Vault

To secure the valoper_address.txt file, we will encrypt it using Ansible Vault.

```bash
ansible-vault encrypt /etc/celestia/valoper_address.txt
```

You will be prompted to enter a password for encryption. After entering the password, the file will be encrypted, and the content will be securely stored.

