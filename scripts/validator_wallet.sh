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
