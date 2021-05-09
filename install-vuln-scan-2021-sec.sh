#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-05-07                                                  #
# Version:      1.50                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#               2021-05-07 Update to 21.4.0 (1.50)                          #
#                                                                           #
# Info:         https://sadsloth.net/post/install-gvm-20_08-src-on-debian/  #
#                                                                           #
#                                                                           #
# Instruction:  Run this script as root on a fully updated                  #
#               Debian 10 (Buster)                                          #
#                                                                           #
#############################################################################


install_prerequisites() {
    /usr/bin/logger 'install_prerequisites' -t 'gse';
    export DEBIAN_FRONTEND=noninteractive;
    # Install prerequisites
    apt-get update;
    # Install some basic tools on a Debian net install
    apt-get -y install --fix-policy;
    apt-get -y install adduser wget whois build-essential devscripts git unzip apt-transport-https ca-certificates curl gnupg2 software-properties-common \
        sudo dnsutils dirmngr --install-recommends;
    # Install pre-requisites for gvmd
    apt-get -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all postgresql-server-dev-11 \
        pkg-config libical-dev xsltproc doxygen;
    # For development
    #apt-get -y install libcgreen1;
    # Install pre-requisites for openvas
    apt-get -y install gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev redis-server;
    # Install pre-requisites for gsad
    apt-get -y install libmicrohttpd-dev libxml2-dev;
    # Other pre-requisites for GSE
    apt-get -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
        bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
        sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
        xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
        python3-defusedxml python3-pip python3-psutil virtualenv texlive-latex-extra texlive-fonts-recommended python-impacket;
    # Install my preferences
    apt-get -y install bash-completion;
    apt-get update;
    apt-get -y full-upgrade;
    apt-get -y auto-remove --purge -y;
    # Python pip packages
    #python3 -m pip install setuptools wrapt psutil packaging;
    mkdir -p /usr/local/var/lib/gvm/private/CA;
    mkdir -p /usr/local/var/lib/gvm/CA;
    mkdir -p /usr/local/var/lib/openvas/plugins;
    mkdir -p /usr/local/var/lib/gvm/private/CA;
    mkdir -p /usr/local/var/log/ospd/;
    mkdir -p /usr/local/var/log/gvm/;
    mkdir -p /usr/local/var/run/;
    /usr/bin/logger 'install_prerequisites finished' -t 'gse';
}

prepare_nix_users() {
    /usr/sbin/useradd --system --create-home -c "ospd-openvas User" --shell /bin/bash ospd;
    sudo sh -c "cat << EOF > /etc/sudoers.d/50-ospd
ospd	ALL = NOPASSWD: /usr/local/sbin/openvas
EOF"        
}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'gse';
    mkdir -p /usr/local/src/greenbone
    chown -R gvm:gvm /usr/local/src/greenbone;
    cd /usr/local/src/greenbone;

    # Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
    wget -O gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v21.4.0.tar.gz;
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v21.4.0.tar.gz;
    wget -O openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v21.4.0.tar.gz;
    wget -O gvmd.tar.gz https://github.com/greenbone/gvmd/archive/refs/tags/v21.4.0.tar.gz;
    wget -O gsa.tar.gz https://github.com/greenbone/gsa/archive/refs/tags/v21.4.0.tar.gz;
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v21.4.0.tar.gz;
    wget -O ospd.tar.gz https://github.com/greenbone/ospd/archive/refs/tags/v21.4.0.tar.gz;
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v21.4.0.tar.gz;
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v21.4.0.tar.gz;
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v21.1.0.tar.gz;
    
    # open and extract the tarballs
    find *.gz | xargs -n1 tar zxvfp;
    sync;

    # Naming of directories w/o version
    mv /usr/local/src/greenbone/gvm-libs-21.4.0 /usr/local/src/greenbone/gvm-libs;
    mv /usr/local/src/greenbone/ospd-openvas-21.4.0 /usr/local/src/greenbone/ospd-openvas;
    mv /usr/local/src/greenbone/openvas-scanner-21.4.0 /usr/local/src/greenbone/openvas;
    mv /usr/local/src/greenbone/gvmd-21.4.0 /usr/local/src/greenbone/gvmd;
    mv /usr/local/src/greenbone/gsa-21.4.0 /usr/local/src/greenbone/gsa;
    mv /usr/local/src/greenbone/openvas-smb-21.4.0 /usr/local/src/greenbone/openvas-smb;
    mv /usr/local/src/greenbone/ospd-21.4.0 /usr/local/src/greenbone/ospd;
    mv /usr/local/src/greenbone/ospd-openvas-21.4.0 /usr/local/src/greenbone/ospd-openvas;
    mv /usr/local/src/greenbone/python-gvm-21.4.0 /usr/local/src/greenbone/python-gvm;
    mv /usr/local/src/greenbone/gvm-tools-21.1.0 /usr/local/src/greenbone/gvm-tools;
    sync;
    chown -R gvm:gvm /usr/local/src/greenbone;
    /usr/bin/logger 'prepare_source finished' -t 'gse';
}

install_poetry() {
    /usr/bin/logger 'install_poetry' -t 'gse';
    export POETRY_HOME=/usr/poetry;
    # https://python-poetry.org/docs/
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -;
    /usr/bin/logger 'install_poetry finished' -t 'gse';
}

install_gvm_libs() {
    /usr/bin/logger 'install_gvmlibs' -t 'gse';
    cd /usr/local/src/greenbone/;
    cd gvm-libs/;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install;
    sync;
    ldconfig;
    /usr/bin/logger 'install_gvmlibs finished' -t 'gse';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'gse';
    cd /usr/local/src/greenbone;
    #config and build openvas-smb
    cd openvas-smb;
    cmake .;
    make                # build the libraries
    make install;
    sync;
    ldconfig;
    /usr/bin/logger 'install_openvas_smb finished' -t 'gse';
}

install_ospd() {
    /usr/bin/logger 'install_ospd' -t 'gse';
    # Install from repo
    #/usr/bin/python3 -m pip install ospd;
    # Uncomment below for install from source
    cd /usr/local/src/greenbone
    # Configure and build scanner
    cd ospd;
    /usr/bin/python3 -m pip install .
    # The poetry install part will fail if poetry is not installed
    # so left here for use when testing (just comment uncomment install_poetry in "main")
    /usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_ospd finished' -t 'gse';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'gse';
    # Install from repo
    #/usr/bin/python3 -m pip install ospd-openvas
    cd /usr/local/src/greenbone;
    # Configure and build scanner
    # Uncomment below for install from source
    cd ospd-openvas;
    /usr/bin/python3 -m pip install .
    # The poetry install part will fail if poetry is not installed
    # so left here for use when testing (just comment uncomment poetry install in "main")
    /usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_ospd_openvas finished' -t 'gse';
}

install_openvas() {
    /usr/bin/logger 'install_openvas' -t 'gse';
    cd /usr/local/src/greenbone;
    # Configure and build scanner
    cd openvas;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install        # install the build
    sync;
    # Reload all modules
    ldconfig;
    /usr/bin/logger 'install_openvas finished' -t 'gse';
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gse';
    # copy scan data from 2020-12-29 to prestage athe ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /tmp/configfiles/;
    tar -xzf /tmp/configfiles/scandata.tar.gz; 
    /bin/cp -r /tmp/configfiles/GVM/openvas/plugins/* /usr/local/var/lib/openvas/plugins/;
    /usr/bin/logger 'prestage_scan_data finished' -t 'gse';
}

update_scan_data() {
    /usr/bin/logger 'update_scan_data' -t 'gse';
    ## This relies on the configure_greenbone_updates
    /usr/local/var/lib/gse-updater/gse-updater.sh;
    /usr/bin/logger 'update_scan_data finished' -t 'gse';
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gse';
    # Create dir for ospd run files
    mkdir /run/ospd;
    chown -R ospd:ospd /run/ospd;
    # Ensure it is recreated after reboot
    sudo sh -c 'cat << EOF > /etc/tmpfiles.d/ospd-openvas.conf
d /run/ospd 1777 ospd ospd
EOF'
    sudo sh -c 'cat << EOF > /lib/systemd/system/ospd-openvas.service
[Unit]
Description=OSPD OpenVAS
After=network.target networking.service redis-server.service systemd-tmpfiles.service
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
User=ospd
Group=ospd
# Change log-level to info before production
ExecStart=/usr/local/bin/ospd-openvas --port=9390 --bind-address=0.0.0.0 --pid-file=/run/ospd/ospd-openvas.pid --lock-file-dir=/run/ospd/ --key-file=/usr/local/var/lib/gvm/private/CA/secondarykey.pem --cert-file=/usr/local/var/lib/gvm/CA/secondarycert.pem --ca-file=/usr/local/var/lib/gvm/CA/cacert.pem --log-file=/usr/local/var/log/ospd/ospd-openvas.log --log-level=info
# log level can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
Alias=ospd-openvas.service
EOF'
    sync;
    /usr/bin/logger 'configure_openvas finished' -t 'gse';
}

configure_greenbone_updates() {
/usr/bin/logger 'configure_greenbone_updates' -t 'gse';
    # Configure daily greenbone-nvt-syn updates timer and service
    mkdir -p /usr/local/var/lib/gse-updater;
    # Timer
    sudo sh -c 'cat << EOF > /lib/systemd/system/gse-update.timer
[Unit]
Description=Daily job to update nvt feed

[Timer]
# Do not run for the first 57 minutes after boot
OnBootSec=57min
# Run Daily
OnCalendar=daily
# Specify service
Unit=gse-update.service

[Install]
WantedBy=multi-user.target
EOF'  

    ## Create gse-update.service
    sudo sh -c 'cat << EOF > /lib/systemd/system/gse-update.service
[Unit]
Description=gse updater
After=network.target networking.service
Documentation=man:gvmd(8)

[Service]
ExecStart=/usr/local/var/lib/gse-updater/gse-updater.sh
TimeoutSec=900

[Install]
WantedBy=multi-user.target
EOF'    

    # Create script for gse-update.service
    sudo sh -c 'cat << EOF  > /usr/local/var/lib/gse-updater/gse-updater.sh;
#! /bin/bash
# updates feeds for Greenbone Vulnerability Manager

# NVT data
# Directly from Greenbone
su ospd -c "/usr/local/bin/greenbone-nvt-sync";
# From internal primary (change hostname brutalis to actual primary) also requires a user gseupdater with membership of group gvm on primary
#/usr/bin/rsync -ratlz --rsh="/usr/bin/sshpass -p test ssh -o StrictHostKeyChecking=no -l gseupdater" brutalis:/usr/local/var/lib/openvas/plugins/ /usr/local/var/lib/openvas/plugins/
sleep 30;
/usr/bin/logger ''nvt data Feed Version \$(su ospd -c "greenbone-nvt-sync --feedversion")'' -t gse;
exit 0
EOF'
sync;
chmod +x /usr/local/var/lib/gse-updater/gse-updater.sh;
/usr/bin/logger 'configure_greenbone_updates finished' -t 'gse';
}

start_services() {
    /usr/bin/logger 'start_services' -t 'gse';
    # Load new/changed systemd-unitfiles
    systemctl daemon-reload;
    # Restart Redis with new config
    systemctl restart redis;
    # Enable GSE units
    systemctl enable ospd-openvas;
    # Start GSE units
    systemctl restart ospd-openvas;
    # Enable gse-update timer and service
    systemctl enable gse-update.timer;
    systemctl enable gse-update.service;
    systemctl start gse-update.timer;
    # Check status of critical services
    # ospd-openvas.service
    if systemctl is-active --quiet ospd-openvas.service;
    then
        /usr/bin/logger 'ospd-openvas.service started successfully' -t 'gse';
    else
        /usr/bin/logger 'ospd-openvas.service FAILED!' -t 'gse';
    fi
    if systemctl is-active --quiet gse-update.timer;
    then
        /usr/bin/logger 'gse-update.timer started successfully' -t 'gse';
    else
        /usr/bin/logger 'gse-update.timer FAILED! Updates will not be automated' -t 'gse';
    fi
    /usr/bin/logger 'start_services finished' -t 'gse';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gse';
        sudo sh -c 'cat << EOF > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
EOF'
    mkdir -p /run/redis;
    chown -R redis:redis /run/redis;
    sudo sh -c 'cat << EOF  > /etc/redis/redis.conf
daemonize yes
pidfile /run/redis/redis-server.pid
port 0
tcp-backlog 511
unixsocket /run/redis/redis.sock
unixsocketperm 766
timeout 0
tcp-keepalive 0
loglevel notice
syslog-enabled yes
databases 4097
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis
slave-serve-stale-data yes
slave-read-only yes
repl-disable-tcp-nodelay no
slave-priority 100
maxclients 20000
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-entries 512
list-max-ziplist-value 64
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
EOF'
    # Redis requirements - overcommit memory and TCP backlog setting > 511
    sysctl -w vm.overcommit_memory=1;
    sysctl -w net.core.somaxconn=1024;
    echo "vm.overcommit_memory=1" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=1024" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    # at every boot too
        sudo sh -c 'cat << EOF  > /etc/rc.local
#!/bin/bash
echo never > /sys/kernel/mm/transparent_hugepage/enabled
exit 0
EOF'
    chmod +x /etc/rc.local;
    sync;
    /usr/bin/logger 'configure_redis finished' -t 'gse';
}

configure_permissions() {
    chown -R ospd:ospd /usr/local/src/;
    chown -R ospd:ospd /usr/local/var/lib/gvm;
    chown -R ospd:ospd /usr/local/var/log/gvm;
    chown -R ospd:ospd /usr/local/var/run;
    # OpenVAS 
    chown -R ospd:ospd /usr/local/var/lib/openvas;
    chown -R ospd:ospd /run/ospd/;
    chown -R ospd:ospd /usr/local/var/log/ospd;
    # Home dirs
    chown -R ospd:ospd /home/ospd;
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    # Shared components
    install_prerequisites;
    prepare_nix_users;
    prepare_source;
    
    # Installation of specific components
    # Only install poetry when testing
    #install_poetry;
    install_gvm_libs;
    install_openvas_smb;
    install_openvas;
    install_ospd;
    install_ospd_openvas;
    # Configuration of installed components
    configure_openvas;
    configure_redis;

    # Prestage only works on the specific Vagrant lab where I've copied the scan-data to the Host. 
    # Update scan-data only from greenbone when used everywhere else 
    prestage_scan_data;
    configure_greenbone_updates;
    configure_permissions;
    update_scan_data;
    su ospd -c '/usr/local/sbin/openvas --update-vt-info';
    start_services;
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot' -t 'gse';
}

main;

exit 0;

######################################################################################################################################
# Post install 
# 
# The admin account is import feed owner: https://community.greenbone.net/t/gvm-20-08-missing-report-formats-and-scan-configs/6397/2
# gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value UUID of admin account 
# Get the uuid using gvmd --get-users --verbose
# The first OpenVas scanner is always this UUID gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73
#
# Admin user:   cat /usr/local/lib/adminuser.
#               You should change this: gvmd --user admin --new-password 'Your new password'
#
# Check the logs:
# tail -f /usr/local/var/log/ospd/ospd-openvas.log
# tail -f /usr/local/var/log/gvm/gvmd.log
# tail -f /usr/local/var/log/gvm/openvas-log < This is very useful when scanning
# tail -f /var/log/syslog | grep -i gse
#
# Creating a secondary sensor requires a backport for 20.08
# Create required certs for secondary on primary run gvm-manage-certs -e ./gsecert.cfg  -v -d -c
#
# Using ps or top, You'll notice that redis is being hammered by ospd-openvas.
#
# When running a - tail -f /usr/local/var/log/openvas.log - is useful in following on during the scanning.
#