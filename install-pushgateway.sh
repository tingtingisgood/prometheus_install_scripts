#!/bin/bash 
PUSHGATEWAY_VERSION="0.7.0" 
wget https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz
tar -xzvf pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz 
cd pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64 

# if you just want to start prometheus as root 
# ./prometheus --config.file=prometheus.yml  

# create user 
useradd --no-create-home --shell /bin/false pushgateway  

# create directories 
mkdir -p /var/lib/pushgateway  

# set ownership 
chown pushgateway:pushgateway /var/lib/pushgateway  

# copy binaries   
cp pushgateway /usr/local/bin  
chown pushgateway:pushgateway  /usr/local/bin/pushgateway 

# setup systemd 
echo '[Unit]
Description=Pushgateway
Wants=network-online.target
After=network-online.target

[Service]
User=pushgateway 
Group=pushgateway 
Type=simple
ExecStart=/usr/local/bin/pushgateway \ 
	--web.listen-address=":9091" \
	--web.telemetry-path="/metrics" \ 
	--persistence.file="/var/lib/pushgateway/" \
    --persistence.interval=5m


[Install]
WantedBy=multi-user.target' > /etc/systemd/system/pushgateway.service

systemctl daemon-reload
systemctl enable pushgateway
systemctl start pushgateway 





