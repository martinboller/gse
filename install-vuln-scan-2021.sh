#! /bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin                                              #
# Last Update:  2021-01-02                                          #
# Version:      1.00                                                #
#                                                                   #
# Changes:      Initial Version (1.00)                              #
#                                                                   #
#                                                                   #
# Info:        https://sadsloth.net/post/install-gvm11-src_part1/   #
#                                                                   #
#                                                                   #
# Instruction:  Run this script as root on a fully updated          #
#               Debian 10 (Buster)                                  #
#                                                                   #
#####################################################################


install_prerequisites() {
    /usr/bin/logger 'install_prerequisites' -t 'gse';
    export DEBIAN_FRONTEND=noninteractive;
    # Install prerequisites
    apt-get update;
    apt-get -y install software-properties-common cmake pkg-config libglib2.0-dev libgpgme11-dev uuid-dev libssh-gcrypt-dev libhiredis-dev gcc libgnutls28-dev libpcap-dev \
        libgpgme-dev bison libksba-dev libsnmp-dev libgcrypt20-dev redis-server libsqlite3-dev libical-dev gnutls-bin doxygen nmap libmicrohttpd-dev libxml2-dev \
        apt-transport-https curl xmltoman xsltproc gcc-mingw-w64 perl-base heimdal-dev libpopt-dev graphviz nodejs rpm nsis wget sshpass socat snmp gettext python3-polib \
        git libgpgme-dev libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev libssh-gcrypt-dev bison libmicrohttpd-dev postgresql postgresql-contrib \
        postgresql-server-dev-all xml-twig-tools python3-psutil build-essential fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
        python3-defusedxml python3-pip python3-psutil virtualenv texlive-latex-extra texlive-fonts-recommended python-impacket;
    /usr/bin/logger 'install_prerequisites finished' -t 'gse';
}

prepare_nix_users() {
    # Create gvm user
    useradd --system --create-home -c "GVM User" --shell /bin/bash gvm;
    useradd --system --create-home -c "ospd User" --shell /bin/bash ospd;
    sudo sh -c 'cat << EOF > /etc/sudoers.d/50-ospd
ospd	ALL = NOPASSWD: /usr/local/sbin/*
EOF'        
}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'gse';
    mkdir -p /usr/local/src/greenbone
    chown -R gvm:gvm /usr/local/src/greenbone;
    cd /usr/local/src/greenbone;

    # Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
    wget -O gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/v20.8.0.tar.gz;
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/v20.8.0.tar.gz;
    wget -O openvas.tar.gz https://github.com/greenbone/openvas/archive/v20.8.0.tar.gz;
    wget -O gvmd.tar.gz https://github.com/greenbone/gvmd/archive/v20.8.0.tar.gz;
    wget -O gsa.tar.gz https://github.com/greenbone/gsa/archive/v20.8.0.tar.gz;
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz;
    wget -O ospd.tar.gz https://github.com/greenbone/ospd/archive/v20.8.1.tar.gz;
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/v20.8.0.tar.gz;
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/v20.12.1.tar.gz;
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/v1.4.0.tar.gz;
   
    # open the tarballs
    find *.gz | xargs -n1 tar zxvfp;
    sync;

    # Naming of directories w/o version
    mv gvm-libs-20.8.0 gvm-libs;
    mv ospd-openvas-20.8.0 ospd-openvas;
    mv openvas-20.8.0 openvas;
    mv gvmd-20.8.0 gvmd;
    mv gsa-20.8.0 gsa;
    mv openvas-smb-1.0.5 openvas-smb;
    mv ospd-20.8.1 ospd;
    mv ospd-openvas-20.8.0 ospd-openvas;
    mv python-gvm-20.8.0 python-gvm;
    mv gvm-tools-1.4.0 gvm-tools;
    sync;
    chown -R gvm:gvm /usr/local/src/greenbone;
    /usr/bin/logger 'prepare_source finished' -t 'gse';
}

prepare_source_latest() {    
    /usr/bin/logger 'prepare_source_latest' -t 'gse';
    mkdir -p /usr/local/src/greenbone
    chown -R gvm:gvm /usr/local/src/greenbone;
    cd /usr/local/src/greenbone;
    ## If you want to experiment with the latest builds
    ## Warning: It WILL liekly break, so don't :)
    git clone https://github.com/greenbone/gvmd.git;
    git clone https://github.com/greenbone/gsa.git;
    git clone https://github.com/greenbone/openvas.git;
    git clone https://github.com/greenbone/gvm-libs.git;
    git clone https://github.com/greenbone/openvas-smb.git;
    git clone https://github.com/greenbone/ospd-openvas.git;
    git clone https://github.com/greenbone/ospd.git;
    git clone https://github.com/greenbone/python-gvm.git;
    git clone https://github.com/greenbone/gvm-tools.git;
    sync;
    chown -R gvm:gvm /usr/local/src/greenbone;
    /usr/bin/logger 'prepare_source_latest EXPERIMENTAL finished' -t 'gse';
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

install_python_gvm() {
    /usr/bin/logger 'install_python_gvm' -t 'gse';
    cd /usr/local/src/greenbone/;
    cd python-gvm/;
    /usr/bin/python3 -m pip install .;
    /usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_python_gvm finished' -t 'gse';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'gse';
    cd /usr/local/src/greenbone;
    #config and build openvas-smb
    cd openvas-smb;
#    export PKG_CONFIG_PATH=/opt/greenbone;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install;
    sync;
    /usr/bin/logger 'install_openvas_smb finished' -t 'gse';
}

install_ospd() {
    /usr/bin/logger 'install_ospd' -t 'gse';
    cd /usr/local/src/greenbone
    # Configure and build scanner
    cd ospd;
    /usr/bin/python3 -m pip install .
    # The poetry install part will fail if poetry is not installed
    # so left here for use when testing (just comment uncomment poetry install in "main")
    /usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_ospd finished' -t 'gse';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'gse';
    cd /usr/local/src/greenbone;
    # Configure and build scanner
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
    #export PKG_CONFIG_PATH=/opt/greenbone;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install        # install the build
    sync;
     # Reload all modules
    ldconfig;
    /usr/bin/logger 'install_openvas finished' -t 'gse';
}

install_gvm() {
    /usr/bin/logger 'install_gvm' -t 'gse';
    cd /usr/local/src/greenbone;
    # Build Manager
    cd gvmd/;
#    export PKG_CONFIG_PATH=/opt/greenbone;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install        # install the build
    sync;
    /usr/bin/logger 'install_gvm finished' -t 'gse';
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gse';
    # copy scan data from 2020-12-29 to prestage athe ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /tmp/configfiles/;
    tar -xzf /tmp/configfiles/scandata.tar.gz; 
    /bin/cp -r /tmp/configfiles/GVM/lib/openvas/plugins/* /usr/local/var/lib/openvas/plugins/;
    /bin/cp -r /tmp/configfiles/GVM/lib/gvm/* /usr/local/var/lib/gvm/;
    /usr/bin/logger 'prestage_scan_data finished' -t 'gse';
}

update_scan_data() {
    /usr/bin/logger 'update_scan_data' -t 'gse';
    ## This relies on the configure_greenbone_updates
    /usr/local/var/lib/gse-updater/gse-updater.sh;
    /usr/bin/logger 'update_scan_data finished' -t 'gse';
}

install_gsa() {
    /usr/bin/logger 'install_gsa' -t 'gse';
    ## Install GSA
    cd /usr/local/src/greenbone
    # GSA prerequisites
    curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -;
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
    sudo apt-get update;
    sudo apt-get -y install yarn;

    # GSA Install
    cd gsa/;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install        # install the build
    sync;
    /usr/bin/logger 'install_gsa finished' -t 'gse';
}

install_gvm_tools() {
    /usr/bin/logger 'install_gvm_tools' -t 'gse';
    cd /usr/local/src/greenbone
    # Install gvm-tools
    cd gvm-tools/;
    python3 -m pip install .;
    /usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_gvm_tools finished' -t 'gse';
}

install_impacket() {
    /usr/bin/logger 'install_impacket' -t 'gse';
    # Install impacket
    python3 -m pip install impacket;
    /usr/bin/logger 'install_impacket finished' -t 'gse';
}

prepare_postgresql() {
    /usr/bin/logger 'prepare_postgresql' -t 'gse';
    #sudo -Hiu postgres
    su postgres -c 'createuser -DRS gvm;'
    su postgres -c 'createuser -DRS root;'
    su postgres -c 'createdb -O gvm gvmd;'
    # Setup permissions.
    su postgres -c "psql gvmd -c 'create role dba with superuser noinherit;'"
    su postgres -c "psql gvmd -c 'grant dba to gvm;'"
    su postgres -c "psql gvmd -c 'grant dba to root;'"
    #   Create DB extensions (also necessary when the database got dropped).
    su postgres -c 'psql gvmd -c "create extension \"uuid-ossp\";"'
    su postgres -c 'psql gvmd -c "create extension "pgcrypto";"'
    /usr/bin/logger 'prepare_postgresql finished' -t 'gse';
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gse';
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/ospd-openvas.service
[Unit]
Description=OSPD OpenVAS
After=network.target networking.service redis-server.service systemd-tmpfiles.service
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
User=root
Group=gvm
# Change log-level to info before production
ExecStart=/usr/local/bin/ospd-openvas --config=/etc/ospd/ospd.conf --log-file=/usr/local/var/log/gvm/ospd-openvas.log --log-level=info
# log level can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
Alias=ospd-openvas.service
EOF'

## Configure ospd
    mkdir -p /etc/ospd;
    sudo sh -c 'cat << EOF > /etc/ospd/ospd.conf
[OSPD - openvas]
log_level = INFO
socket_mode = 0o777
unix_socket = /var/run/ospd/ospd.sock
pid_file = /usr/local/var/run/ospd-openvas.pid
; Use lock_file_dir to set the path for the feed_update.lock and the scan queue saved in a file.
; Keep in mind that this path then needs to be shared with gvmd and feed sync.
; default = /var/run/ospd
lock_file_dir = /usr/local/var/run/

; max_scans, is the number of scan/task to be started before start to queuing.
; This depends on the capacity of the GSM. (needs to be a setting, IMO)
max_scans = 0

; The minimal available memory before the GSM starts to queue scans.
min_free_mem_scan_queue = 1100

; max_queued_scans is the maximum amount of queued scans before starting to reject the new task (will not be queued) and send an error message to gvmd
; This options are disabled with the value 0 (zero), all arriving tasks will be started without queuing.
max_queued_scans = 0
EOF'        
    sync;
   /usr/bin/logger 'configure_openvas finished' -t 'gse';
}

configure_gvm() {
    /usr/bin/logger 'configure_gvm' -t 'gse';
    # Create Certificates
    export GVM_CERTIFICATE_LIFETIME=3650;
    /usr/local/bin/gvm-manage-certs -a;
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/gvmd.service
[Unit]
Description=Greenbone Vulnerability Manager daemon (gvmd)
After=network.target networking.service postgresql.service 
#ospd-openvas.service
Wants=postgresql.service 
#ospd-openvas.service
Documentation=man:gvmd(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
User=gvm
Group=gvm
PIDFile=/usr/local/var/run/gvmd.pid
EnvironmentFile=/usr/local/etc/default/gvmd
#ExecStart=-/usr/local/sbin/gvmd --unix-socket=/usr/local/var/run/gvmd.sock --listen-group=gvm --client-watch-interval=0 --osp-vt-update=/var/run/ospd.sock
ExecStart=-/usr/local/sbin/gvmd --unix-socket=/usr/local/var/run/gvmd.sock --listen-group=gvm --client-watch-interval=0
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF'    
    sync;
    /usr/bin/logger 'configure_gvm finished' -t 'gse';
}

configure_gsa() {
    /usr/bin/logger 'configure_gsa' -t 'gse';
    # Configure GSA daemon
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/gsad.service
[Unit]
Description=Greenbone Security Assistant daemon (gsad)
After=network.target networking.service gvmd.service
Documentation=man:gsad(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
User=gvm
Group=gvm
PIDFile=/usr/local/var/run/gsad.pid
EnvironmentFile=/usr/local/etc/default/gsad
ExecStart=/usr/local/sbin/gsad --port=8443 --gnutls-priorities=SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2 --no-redirect --secure-cookie --http-sts
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF'    
    sync;
   /usr/bin/logger 'configure_gsa finished' -t 'gse';
}

configure_feed_owner() {
    /usr/bin/logger 'configure_feed_owner' -t 'gse';
    echo "User admin for GVM $HOSTNAME " >> /usr/local/var/lib/adminuser;
    su gvm -c '/usr/local/sbin/gvmd --create-user=admin' >> /usr/local/var/lib/adminuser;
    su gvm -c 'gvmd --get-users --verbose' > /usr/local/var/lib/feedowner;
    awk -F " " {'print $2'} /usr/local/var/lib/feedowner > /usr/local/var/lib/uuid;
    # Ensure strOwnerUUID is available in user gvm context
    su gvm -c 'cat /usr/local/var/lib/uuid | xargs gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $1'
    /usr/bin/logger 'configure_feed_owner finished' -t 'gse';
}

configure_greenbone_updates() {
   /usr/bin/logger 'configure_greenbone_updates' -t 'gse';
    # Configure daily GVM updates timer and service
    mkdir -p /usr/local/var/lib/gse-updater;
    # Timer
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/gse-update.timer
[Unit]
Description=Daily job to update all Greenbone feeds

[Timer]
# Do not run for the first 37 minutes after boot
OnBootSec=37min
# Run Daily
OnCalendar=daily
# Specify service
Unit=gse-update.service

[Install]
WantedBy=multi-user.target
EOF'  

## Service
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/gse-update.service
[Unit]
Description=gse updater
After=network.target networking.service
Documentation=man:gvmd(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
#PIDFile=/usr/local/var/run/gse-update.pid
ExecStart=/usr/local/var/lib/gse-updater/gse-updater.sh

[Install]
WantedBy=multi-user.target
EOF'    
    # Create shell script
    sudo sh -c 'cat << EOF  > /usr/local/var/lib/gse-updater/gse-updater.sh;
#! /bin/bash
# updates feeds for Greenbone Vulnerability Manager

# NVT data
su gvm -c "/usr/local/bin/greenbone-nvt-sync";
sleep 2;
/usr/bin/logger ''nvt data Feed Version \$(su gvm -c "greenbone-nvt-sync --feedversion")'' -t gse;
sleep 10;

# CERT data
su gvm -c "/usr/local/sbin/greenbone-feed-sync --type cert";
sleep 2;
/usr/bin/logger ''Certdata Feed Version \$(su gvm -c "greenbone-feed-sync --type cert --feedversion")'' -t gse;
sleep 10;

# SCAP data
su gvm -c "/usr/local/sbin/greenbone-feed-sync --type scap";
sleep 2;
/usr/bin/logger ''Scapdata Feed Version \$(su gvm -c "greenbone-feed-sync --type scap --feedversion")'' -t gse;
sleep 10;

# GVMD data
su gvm -c "/usr/local/sbin/greenbone-feed-sync --type gvmd_data";
sleep 2;
/usr/bin/logger ''gvmd data Feed Version \$(su gvm -c "greenbone-feed-sync --type gvmd_data --feedversion")'' -t gse;
exit 0
EOF'
   sync;
   chmod +x /usr/local/var/lib/gse-updater/gse-updater.sh;
   /usr/bin/logger 'configure_greenbone_updates finished' -t 'gse';
}

start_services() {
    /usr/bin/logger 'start_services' -t 'gse';
    # GVMD
    systemctl daemon-reload;
    systemctl restart redis;
    systemctl enable ospd-openvas;
    systemctl enable gvmd.service;
    systemctl enable gsad.service;
    systemctl restart ospd-openvas;
    systemctl restart gvmd.service;
    systemctl restart gsad.service;
    systemctl enable gse-update.timer;
    systemctl enable gse-update.service;
    # Will start after next reboot - may disturb the initial update
    #systemctl start gse-update.timer;
    /usr/bin/logger 'start_services finished' -t 'gse';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gse';
    mkdir -p /var/run/redis;
    chown -R redis:redis /var/run/redis;
    sudo sh -c 'cat << EOF  > /etc/redis/redis.conf
daemonize yes
pidfile /var/run/redis/redis-server.pid
port 0
tcp-backlog 511
unixsocket /var/run/redis/redis.sock
unixsocketperm 760
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
    sync;
    /usr/bin/logger 'configure_redis finished' -t 'gse';
}

configure_permissions() {
    chown -R gvm:gvm /usr/local/src/;
    chown -R gvm:gvm /usr/local/var/lib/gvm;
    chown -R gvm:gvm /usr/local/var/log/gvm;
    chown -R gvm:gvm /usr/local/var/run;
    # OpenVAS 
    #chown -R ospd:ospd /etc/ospd/
    #chown -R ospd:ospd /var/run/ospd/
    chown -R gvm:gvm /usr/local/var/lib/openvas;
}

configure_report_cleanup() {
    /usr/bin/logger 'configure_report_cleanup' -t 'gse';
# Cron job to cleanup 1 day old csv files pulled from vuln scanner
    sudo sh -c "cat << EOF  > /etc/cron.daily/cleanupvulndata
#! /bin/bash
## Cleanup scan data csv files older than 1 day
find /opt/VulnWhisperer/data/nessus/*/*.csv -mtime +1 -exec rm {} \
EOF"
    sync;
    chmod +x /etc/cron.daily/cleanupvulndata;
    /usr/bin/logger 'configure_report_cleanup finished' -t 'gse';
}



##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
        # Shared components
        install_prerequisites;
        prepare_nix_users;
        prepare_source;
        # For latest builds use prepare_source_latest instead of prepare_source
        # It is likely to break, so Don't.
        #prepare_source_latest;
        
        # Installation of specific components
        # This is the master server so install GSAD
        #install_poetry;
        install_gvm_libs;
        install_gvm;
        install_ospd;
        install_ospd_openvas;
        install_openvas_smb;
        install_openvas;
        install_gvm_tools;
        install_gsa;        
        install_python_gvm;

        # Configuration of installed components
        prepare_postgresql;
        configure_gvm;
        configure_openvas;
        configure_gsa;
        configure_redis;

        # Prestage only works on the specific Vagrant lab where I've copied the scan-data to the Host. 
        # Update scan-data only from greenbone when used everywhere else 
        prestage_scan_data;
        configure_greenbone_updates;
        configure_permissions;
        update_scan_data;
        start_services;
        configure_feed_owner;
        echo $HOSTNAME: $(date) | sudo tee -a /mnt/backup/servers;
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
# tail -f /usr/local/var/log/gvm/ospd-openvas.log
# tail -f /usr/local/var/log/gvm/gvmd.log
# tail -f /var/log/syslog | grep -i gse
#
# Using ps or top, You'll notice that postgres is being hammered by gvmd and that redis are
# too, but by ospd-openvas.
#
# When running a scan tail -f /usr/local/var/log/openvas.log is useful in following on during the scanning.
#