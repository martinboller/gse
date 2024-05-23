#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Instruction:  Run this script as root on a fully updated                  #
#               Debian 11 (Bullseye) or Debian 12 (Bookworm)                #
#                                                                           #
#############################################################################

configure_updates() {
    /usr/bin/logger 'configure_update_server' -t 'gce-2024-04-14';
    echo -e "\e[1;32mconfigure_update_server() \e[0m";
    # Create openvas configuration file
    echo -e "\e[1;36m...create rsyncd configuration file\e[0m";
    mkdir /etc/rsync/
    cat << __EOF__ > /etc/rsync/rsyncd.conf
pid file = /run/rsyncd.pid
lock file = /run/rsync.lock
log file = /var/log/rsync.log
port = 873

[updates]
path = /var/feedupdate/community/
comment = 'Vulnerability Scanner Updates'
read only = true
timeout = 300
__EOF__

    # Create update timer
    echo -e "\e[1;36m...creating update timer\e[0m";
    cat << __EOF__ > /lib/systemd/system/feed-update.timer
[Unit]
Description=Daily job to update nvt feed

[Timer]
# Do not run for the first 7 minutes after boot
OnBootSec=7min
OnUnitActiveSec=3h
RandomizedDelaySec=1800
# Specify service
Unit=feed-update.service

[Install]
WantedBy=multi-user.target
__EOF__

    # Create update service
    mkdir -p /var/feedupdate/;
    echo -e "\e[1;36m...creating update service\e[0m";
    cat << __EOF__ > /lib/systemd/system/feed-update.service
[Unit]
Description=Feed update
After=network.target networking.service
ConditionKernelCommandLine=!recovery

[Service]
Type=simple
User=root
Group=root
ExecStart=rsync -rz rsync://feed.community.greenbone.net/community/ /var/feedupdate/community/
Restart=on-failure
RestartSec=60

[Install]
WantedBy=multi-user.target
__EOF__
systemctl daemon-reload;
systemctl enable feed-update.timer;
systemctl enable feed-update.service;
systemctl start feed-update.timer;
systemctl start feed-update.service;
sync
    echo -e "\e[1;32mconfigure_update_server() finished\e[0m";
    /usr/bin/logger 'configure_update_server finished' -t 'gce-2024-04-14';
}

create_rsync_service() {
    /usr/bin/logger 'create_rsync_service()' -t 'gce-2024-04-14';
    echo -e "\e[1;32mcreate_rsync_service() \e[0m";

    # Create rsync service
    echo -e "\e[1;36m...creating rsync service\e[0m";
    cat << __EOF__ > /lib/systemd/system/rsyncd@.service
[Unit]
Description=Rsync Server
After=local-fs.target
ConditionPathExists=/etc/rsync/rsyncd.conf

[Service]
ExecStart=/usr/bin/rsync --daemon
StandardInput=socket
__EOF__

sync;
    # Create rsync socket
    echo -e "\e[1;36m...creating rsync service\e[0m";
    cat << __EOF__ > /lib/systemd/system/rsyncd.socket
[[Unit]
Description=Rsync Server Activation Socket
ConditionPathExists=/etc/rsync/rsyncd.conf

[Socket]
ListenStream=873
Accept=true

[Install]
WantedBy=sockets.target
__EOF__
sync;
    echo -e "\e[1;36m...reload new and changed systemd unit files\e[0m";
    systemctl daemon-reload > /dev/null 2>&1;
    systemctl enable rsyncd.socket;
    # Restart rsync as daemon with new config
    echo -e "\e[1;36m...restarting rsync socket\e[0m";
    systemctl restart rsyncd.socket > /dev/null 2>&1;

    /usr/bin/logger 'create_rsync_service() finished' -t 'gce-2024-04-14';
    echo -e "\e[1;32mcreate_rsync_service() finished\e[0m";
}

check_services() {
    /usr/bin/logger 'check_services' -t 'gce-2024-04-14';
    echo -e "\e[1;32mcheck_services()\e[0m";
    # Load new/changed systemd-unitfiles
    # Check status of services
    # rsyncd.socket
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking rsync socket......\e[0m";
    if systemctl is-active --quiet rsync.socket;
    then
        echo -e "\e[1;32mrsyncd.socket started successfully";
        /usr/bin/logger 'rsync.socket started successfully' -t 'gce-2024-04-14';
    else
        echo -e "\e[1;31mrsyncd.socket FAILED!\e[0m";
        /usr/bin/logger 'rsyncd.socket FAILED' -t 'gce-2024-04-14';
    fi
    # 
    if systemctl is-active --quiet feed-update.service;
    then
        echo -e "\e[1;32mfeed-update.service started successfully\e[0m";
        /usr/bin/logger 'feed-update.service started successfully' -t 'gce-2024-04-14';
    else
        echo -e "\e[1;31mfeed-update.service FAILED!";
        /usr/bin/logger 'feed-update.service FAILED!\e[0m' -t 'gce-2024-04-14';
    fi

    echo -e "\e[1;32mcheck_services() finished\e[0m";
    /usr/bin/logger 'check_services finished' -t 'gce-2024-04-14';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32mFeed update Server Install main()\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36m...Starting installation of Feed Update Server \e[0m"
    echo -e "\e[1;36m...$HOSTNAME\e[0m"
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    # Shared variables
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
        # Configure environment from .env file
    set -a; source $SCRIPT_DIR/.env;
    echo -e "\e[1;36m....env file version $ENV_VERSION used\e[0m"
    create_rsync_service;
    configure_updates;
    check_services;
}

main;

exit 0;
