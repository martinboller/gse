#! /bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin@bollers.dk                                   #
#                                                                   #
# Changes:      configure alerta api keys for                       #
#               alerta heartbeats and elastalert                    #
#                                                                   #
#####################################################################


install_alerta() {
    echo -e "\e[36m- install_alerta()\e[0m"
    /usr/bin/logger 'install_alerta()' -t "$CLUSTER_NAME";
    id alerta || (groupadd alerta && useradd -g alerta alerta) > /dev/null 2>&1;
    cd /opt > /dev/null 2>&1;
    python3 -m venv alerta > /dev/null 2>&1;
    source alerta/bin/activate > /dev/null 2>&1;
    /opt/alerta/bin/pip install --upgrade pip wheel > /dev/null 2>&1;
    /opt/alerta/bin/pip install alerta > /dev/null 2>&1;
    alerta_py_ver=$(ls /opt/alerta/lib/);
    mkdir /etc/alerta/ > /dev/null 2>&1;
    mkdir /run/alerta/ > /dev/null 2>&1;
    cat /tmp/configfiles/certs/ca/$CLUSTER_NAME-root-ca.crt | tee -a /opt/alerta/lib/$alerta_py_ver/site-packages/certifi/cacert.pem > /dev/null 2>&1;
    deactivate;
    chown -R alerta:alerta /etc/alerta/ > /dev/null 2>&1;
    chown -R alerta:alerta /run/alerta/ > /dev/null 2>&1;
    echo -e "\e[36m- install_alerta() finished\e[0m"
}


configure_alerta_heartbeat() {
    echo -e "\e[36m- configure_alerta_heartbeat()\e[0m"
    /usr/bin/logger 'configure_alerta_heartbeat()' -t "$CLUSTER_NAME";
    echo "Configure Heartbeat Alerts on Alerta Server";
    export DEBIAN_FRONTEND=noninteractive;
    id alerta || (groupadd alerta && useradd -g alerta alerta) > /dev/null 2>&1;
    mkdir /etc/alerta/ > /dev/null 2>&1;
    mkdir /run/alerta/ > /dev/null 2>&1;
    chown -R alerta:alerta /etc/alerta/ > /dev/null 2>&1;
    chown -R alerta:alerta /run/alerta/ > /dev/null 2>&1;
    # Wrapper conf file
    sh -c "cat << EOF > /etc/alerta/alerta-wrap.conf
--config-file=/etc/alerta/alerta-cli.conf
heartbeat
--timeout=120
--tag=role:vulnerability_scanner
EOF";

    if [ $HOSTNAME == $GREENBONE_MASTER ];
    then
    sh -c "cat << EOF >> /etc/alerta/alerta-wrap.conf
--tag=role:master
EOF";
    else
    sh -c "cat << EOF >> /etc/alerta/alerta-wrap.conf
--tag=role:sensor
EOF";
    fi

    # Create Alerta configuration file
    sh -c "cat << EOF > /etc/alerta/alerta-cli.conf
[DEFAULT]
endpoint = https://$FORM_NODE.$CLUSTER_DNS_DOMAIN/api

EOF";

    # Create  Service
    sh -c "cat << EOF > /lib/systemd/system/alerta-heartbeat.service
[Unit]
Description=Alerta Heartbeat service
Documentation=https://http://docs.alerta.io/en/latest/deployment.html#house-keeping
Wants=network-online.target

[Service]
User=alerta
Group=alerta
ExecStart=/usr/bin/wrapper /opt/alerta/bin/alerta /etc/alerta/alerta-wrap.conf
#ExecStart=-/opt/alerta/bin/alerta --config-file /etc/alerta/alerta-cli.conf heartbeat --timeout 120
WorkingDirectory=/run/alerta/

[Install]
WantedBy=multi-user.target
EOF";

   sh -c "cat << EOF  >  /lib/systemd/system/alerta-heartbeat.timer
[Unit]
Description=sends heartbeats to alerta every 60 seconds
Documentation=https://http://docs.alerta.io/en/latest/deployment.html#house-keeping
Wants=network-online.target

[Timer]
OnUnitActiveSec=60s
Unit=alerta-heartbeat.service

[Install]
WantedBy=multi-user.target
EOF";
    sync;
    systemctl daemon-reload > /dev/null 2>&1;
    systemctl enable alerta-heartbeat.timer > /dev/null 2>&1;
    systemctl enable alerta-heartbeat.service > /dev/null 2>&1;
    systemctl start alerta-heartbeat.timer > /dev/null 2>&1;
    systemctl start alerta-heartbeat.service > /dev/null 2>&1;
    /usr/bin/logger 'configure_alerta_heartbeat() finished' -t "$CLUSTER_NAME";
    echo -e "\e[36m- configure_alerta_heartbeat() finished\e[0m"
}


configure_alerta_apikey() {
    echo -e "\e[33m- configure_alerta_apikey()\e[0m";
    /usr/bin/logger 'configure_alerta_apikey() started' -t "$CLUSTER_NAME-Post-2";
    echo "key = $alerta_api_key" | tee -a /etc/alerta/alerta-cli.conf;
    echo 'configure_alerta_apikey() finished';
    /usr/bin/logger 'configure_alerta_apikey() finished' -t "$CLUSTER_NAME-Post-2";
    echo -e "\e[33m- configure_alerta_apikey() finished\e[0m";
}


create_wrapper() {
    echo -e "\e[1;32mcreate_wrapper()\e[0m";
    /usr/bin/logger 'create_wrapper' -t 'gce-2024-06-29';
    cat << __EOF__ > /usr/bin/wrapper
#!/usr/bin/env python3

import argparse
import os

def read_config_file(config):
    parameters = []
    if not config:
        return parameters
    if not os.path.exists(config):
        return parameters
    with open(config, "r") as configfile:
        for line in configfile:
            line = line.strip()
            if line.startswith("#") or not line:
                continue
            parameters.append(line)
    return parameters

def run_command(command, parameters, prefix=[]):
    command_line = prefix + [command] + parameters
    os.execv(command_line[0], command_line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("command", help="Path to executable")
    parser.add_argument(
        "config",
        help="Path to configuration file"
    )
    parser.add_argument(
        "--prefix",
        help="Path to configuration file containing the prefix"
    )
    args = parser.parse_args()
    prefix = read_config_file(args.prefix)
    parameters = read_config_file(args.config)
    run_command(args.command, parameters, prefix)
__EOF__
    sync;
    chmod 755 /usr/bin/wrapper > /dev/null 2>&1;
    echo -e "\e[1;32mcreate_wrapper() finished\e[0m";
    /usr/bin/logger 'create_wrapper finished' -t 'gce-2024-06-29';
}


configure_rootca_trust()  {
    echo -e "\e[36m- configure_rootca_trust()\e[0m"
    /usr/bin/logger 'configure_rootca_trust()' -t "$CLUSTER_NAME";
    # Alerta Python cacerts
    openssl s_client -showcerts -connect $FORM_NODE.$CLUSTER_DNS_DOMAIN:443 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> /opt/alerta/lib/python3.11/site-packages/certifi/cacert.pem

    mkdir /usr/local/share/ca-certificates/$CLUSTER_NAME/
    openssl s_client -showcerts -connect $FORM_NODE.$CLUSTER_DNS_DOMAIN:443 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> /usr/local/share/ca-certificates/$CLUSTER_NAME/$CLUSTER_NAME-root-ca.crt
    update-ca-certificates > /dev/null 2>&1;
    /usr/bin/logger 'configure_rootca_trust() finished' -t "$CLUSTER_NAME";
    echo -e "\e[36m- configure_rootca_trust() finished\e[0m"
}


##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    # Shared variables
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" & > /dev/null && pwd )"
    export ENV_DIR=$HOME;
     # Configure environment from .env file
    set -a; source $ENV_DIR/.env;
    iso_date=$(date +"%Y-%m-%dT%H:%M:%S%z");
    echo -e
    echo -e "\e[1;36m---------------------------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36m....env file version $ENV_VERSION used\e[0m"
    echo -e "\e[1;36m....Forensics Node: $FORM_NODE\e[0m"
    echo -e "\e[1;36m---------------------------------------------------------------------------------------------------------------------\e[0m"

    install_alerta;
    configure_rootca_trust;
    configure_alerta_heartbeat;

    read -p "Enter Alerta API key for alerta heartbeats: " alerta_api_key;
    echo -e "\e[0m"
    configure_alerta_apikey;

    /usr/bin/logger 'alerta-api-keys configuration complete' -t "$CLUSTER_NAME-Post-2";
    echo -e "\e[33m- apikeys configured on $HOSTNAME\e[0m";
}

main;