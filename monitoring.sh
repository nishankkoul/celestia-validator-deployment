#!/bin/bash

sudo apt install prometheus

prometheus --config.file=/root/.celestia-app/config/prometheus.yml --web.listen-address="0.0.0.0:8000" &

sudo apt-get update -y
sudo apt-get upgrade -y 

sudo apt-get install -y grafana

sudo systemctl start grafana-server
sudo systemctl enable grafana-server