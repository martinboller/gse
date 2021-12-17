#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-12-17                                                  #
# Version:      2.10                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#               2021-05-07 Update to 21.4.0 (1.50)                          #
#               2021-09-13 Updated to run on Debian 10 and 11               #
#               2021-10-23 Latest GSE release                               #
#               2021-10-25 Correct ospd-openvas.sock                        #
#               2021-12-17 Create secondary cert w hostname not *           #
#                                                                           #
# Info:         https://sadsloth.net/post/install-gvm-20_08-src-on-debian/  #
#                                                                           #
#                                                                           #
# Instruction:  Run this script as root on a fully updated                  #
#               Debian 10 (Buster) or Debian 11 (Bullseye)                  #
#                                                                           #
#############################################################################


install_prerequisites() {
    /usr/bin/logger 'install_prerequisites' -t 'gse-21.4';
    export DEBIAN_FRONTEND=noninteractive;
    # OS Version
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    /usr/bin/logger "Operating System: $OS Version: $VER" -t 'gse-21.4';
    # Install prerequisites
    apt-get update;
    # Install some basic tools on a Debian net install
    /usr/bin/logger '..Install some basic tools on a Debian net install' -t 'gse-21.4';
    apt-get -y install --fix-policy;
    apt-get -y install adduser wget whois build-essential devscripts git unzip apt-transport-https ca-certificates curl gnupg2 software-properties-common dnsutils dirmngr --install-recommends;
    # Set correct locale
    locale-gen;
    update-locale;
    # For development
    #apt-get -y install libcgreen1;
    # Install pre-requisites for openvas
    /usr/bin/logger '..Tools for Development' -t 'gse-21.4';
    apt-get -y install gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev redis-server libunistring-dev libxml2-dev;
    # Install pre-requisites for gsad
    #/usr/bin/logger '..Prerequisites for GSAD' -t 'gse-21.4';
    #apt-get -y install libmicrohttpd-dev;
    
    # Other pre-requisites for GSE
    if [ $VER -eq "11" ] 
        then
            /usr/bin/logger '..install_prerequisites_debian_11_bullseye' -t 'gse-21.4';
            # Install pre-requisites for gvmd on bullseye (debian 11)
            apt-get -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all postgresql-server-dev-13 \
            pkg-config libical-dev xsltproc doxygen;        
            
            # Other pre-requisites for GSE - Bullseye / Debian 11
            /usr/bin/logger '....Other prerequisites for GSE on Debian 11' -t 'gse-21.4';
            apt-get -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
            bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
            sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
            xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
            python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy;
        
    elif [ $VER -eq "10" ]
        then
            /usr/bin/logger '..install_prerequisites_debian_10_buster' -t 'gse-21.4';
            # Install pre-requisites for gvmd on buster (debian 10)
            apt-get -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all postgresql-server-dev-11 \
            pkg-config libical-dev xsltproc doxygen;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            /usr/bin/logger '....Other prerequisites for GSE on Debian 10' -t 'gse-21.4';
            apt-get -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy;
        
        else
            /usr/bin/logger "Operating System: $OS Version: $VER" -t 'gse-21.4';
            # Untested but let's try like it is buster (debian 10)

            apt-get -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all postgresql-server-dev-11 \
            pkg-config libical-dev xsltproc doxygen;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            /usr/bin/logger '....Other prerequisites for GSE on unknown OS' -t 'gse-21.4';
            apt-get -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy;
        fi

    # Required for PDF report generation
    # /usr/bin/logger '....Prerequisites for PDF report generation' -t 'gse-21.4';
    # apt-get -y install texlive-latex-extra --no-install-recommends;
    # apt-get -y install texlive-fonts-recommended;
    # Install other preferences and cleanup APT
    /usr/bin/logger '....Install preferences on Debian' -t 'gse-21.4';
    apt-get -y install bash-completion;
    # Install SUDO
    apt-get -y install sudo;
    # A little apt cleanup
    apt-get update;
    apt-get -y full-upgrade;
    apt-get -y autoremove --purge;
    apt-get -y autoclean;
    apt-get -y clean;    
    # Python pip packages
    apt-get -y install python3-pip;
    python3 -m pip install --upgrade pip
    # Prepare folders for scan data
    mkdir -p /var/lib/gvm/private/CA;
    mkdir -p /var/lib/gvm/CA;
    mkdir -p /var/lib/openvas/plugins;
    # logging
    mkdir -p /var/log/gvm/;
    chown -R gvm:gvm /var/log/gvm/;
    /usr/bin/logger 'install_prerequisites finished' -t 'gse-21.4';
}

prepare_nix() {
    # set desired locale
    localectl set-locale en_US.UTF-8;
    # Create gvm user
    /usr/sbin/useradd --system --create-home --home-dir /opt/gvm/ -c "gvm User" --shell /bin/bash gvm;
    mkdir /opt/gvm;
    chown -R gvm:gvm /opt/gvm/;
    # Update the PATH environment variable
    echo "PATH=\$PATH:/opt/gvm/bin:/opt/gvm/sbin" > /etc/profile.d/gvm.sh;
    # Add GVM library path to /etc/ld.so.conf.d
    cat << __EOF__ > /etc/ld.so.conf.d/greenbone.conf;
# Greenbone libraries
/opt/gvm/lib
/opt/gvm/include
__EOF__
    cat << __EOF__ > /etc/sudoers.d/greenbone
gvm     ALL = NOPASSWD: /opt/gvm/sbin/gsad, /opt/gvm/sbin/gvmd, /opt/gvm/sbin/openvas

Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gvm/sbin"
__EOF__
    cat << __EOF__ > /etc/tmpfiles.d/greenbone.conf
d /run/gvm 1775 gvm gvm
d /run/gvm/gse 1775 root
d /run/ospd 1775 gvm gvm
d /run/ospd/gse 1775 root
d /var/log/gvm 1775 gvm gvm
__EOF__
    # start systemd-tmpfiles to create directories
    systemd-tmpfiles --create;
}

prepare_source_secondary() {    
    /usr/bin/logger 'prepare_source_secondary' -t 'gse-21.4';
    mkdir -p /opt/gvm/src/greenbone
    chown -R gvm:gvm /opt/gvm/src/greenbone;
    cd /opt/gvm/src/greenbone;

    #Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
    /usr/bin/logger '..gvm libraries' -t 'gse-21.4';
    wget -O gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v21.4.3.tar.gz;
    /usr/bin/logger '..ospd-openvas' -t 'gse-21.4';
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v21.4.3.tar.gz;
    /usr/bin/logger '..openvas-scanner' -t 'gse-21.4';
    wget -O openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v21.4.3.tar.gz;
    /usr/bin/logger '..openvas-smb' -t 'gse-21.4';
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v21.4.0.tar.gz;
    /usr/bin/logger '..ospd' -t 'gse-21.4';
    wget -O ospd.tar.gz https://github.com/greenbone/ospd/archive/refs/tags/v21.4.4.tar.gz;
    /usr/bin/logger '..python-gvm' -t 'gse-21.4';
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v21.10.0.tar.gz;
    /usr/bin/logger '..gvm-tools' -t 'gse-21.4';
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v21.6.1.tar.gz;
  
    # open and extract the tarballs
    find *.gz | xargs -n1 tar zxvfp;
    sync;

    # Naming of directories w/o version
    /usr/bin/logger '..re-naming directories' -t 'gse-21.4';
    mv /opt/gvm/src/greenbone/gvm-libs-21.4.3 /opt/gvm/src/greenbone/gvm-libs;
    mv /opt/gvm/src/greenbone/ospd-openvas-21.4.3 /opt/gvm/src/greenbone/ospd-openvas;
    mv /opt/gvm/src/greenbone/openvas-scanner-21.4.3 /opt/gvm/src/greenbone/openvas;
    mv /opt/gvm/src/greenbone/openvas-smb-21.4.0 /opt/gvm/src/greenbone/openvas-smb;
    mv /opt/gvm/src/greenbone/ospd-21.4.4 /opt/gvm/src/greenbone/ospd;
    mv /opt/gvm/src/greenbone/python-gvm-21.10.0 /opt/gvm/src/greenbone/python-gvm;
    mv /opt/gvm/src/greenbone/gvm-tools-21.6.1 /opt/gvm/src/greenbone/gvm-tools;
    sync;
    chown -R gvm:gvm /opt/gvm/src/greenbone;
    /usr/bin/logger 'prepare_source_secondary finished' -t 'gse-21.4';
}

install_poetry() {
    /usr/bin/logger 'install_poetry' -t 'gse-21.4';
    export POETRY_HOME=/usr/poetry;
    # https://python-poetry.org/docs/
    curl    -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -;
    /usr/bin/logger 'install_poetry finished' -t 'gse-21.4';
}

install_gvm_libs() {
    /usr/bin/logger 'install_gvmlibs' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone/;
    cd gvm-libs/;
    chown -R gvm:gvm /opt/gvm/
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .
    /usr/bin/logger '..make gvm libraries' -t 'gse-21.4';
    make;
    /usr/bin/logger '..make gvm libraries Documentation' -t 'gse-21.4';
    make doc-full;
    /usr/bin/logger '..make install gvm libraries' -t 'gse-21.4';
    make install;
    sync;
    ldconfig;
    /usr/bin/logger 'install_gvmlibs finished' -t 'gse-21.4';
}

install_python_gvm() {
    /usr/bin/logger 'install_python_gvm' -t 'gse-21.4';
    # Installing from repo
    #/usr/bin/python3 -m pip install python-gvm;
    cd /opt/gvm/src/greenbone/;
    cd python-gvm/;
    /usr/bin/python3 -m pip install .;
    #/usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_python_gvm finished' -t 'gse-21.4';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone;
    #config and build openvas-smb
    cd openvas-smb;
    /usr/bin/logger '..cmake OpenVAS SMB' -t 'gse-21.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .;
    /usr/bin/logger '..make OpenVAS SMB' -t 'gse-21.4';
    make;                
    /usr/bin/logger '..make install OpenVAS SMB' -t 'gse-21.4';
    make install;
    sync;
    ldconfig;
    /usr/bin/logger 'install_openvas_smb finished' -t 'gse-21.4';
}

install_ospd() {
    /usr/bin/logger 'install_ospd' -t 'gse-21.4';
    # Install from repo
    #/usr/bin/python3 -m pip install ospd;
    # Uncomment below for install from source
    cd /opt/gvm/src/greenbone;
    # Configure and build scanner
    cd ospd;
    /usr/bin/python3 -m pip install . 
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_ospd finished' -t 'gse-21.4';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'gse-21.4';
    # Install from repo
    #/usr/bin/python3 -m pip install ospd-openvas
    cd /opt/gvm/src/greenbone;
    # Configure and build scanner
    # install from source
    cd ospd-openvas;
    /usr/bin/python3 -m pip install . 
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_ospd_openvas finished' -t 'gse-21.4';
}

install_openvas() {
    /usr/bin/logger 'install_openvas' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone;
    # Configure and build scanner
    cd openvas;
    chown -R gvm:gvm /opt/gvm;
    /usr/bin/logger '..cmake OpenVAS Scanner' -t 'gse-21.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .;
    /usr/bin/logger '..make OpenVAS Scanner' -t 'gse-21.4';
    make;                # build the libraries
    #make doc-full;       # build more developer-oriented documentation
    /usr/bin/logger '..make install OpenVAS Scanner' -t 'gse-21.4';
    make install;        # install the build
    /usr/bin/logger '..Rebuild make cache, OpenVAS Scanner' -t 'gse-21.4';
    make rebuild_cache;
    sync;
    ldconfig;
    /usr/bin/logger 'install_openvas finished' -t 'gse-21.4';
}

install_nmap() {
    /usr/bin/logger 'install_nmap' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone;
    # Install NMAP
    apt-get -y install ./nmap.deb --fix-missing;
    sync;
    /usr/bin/logger 'install_nmap finished' -t 'gse-21.4';
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gse-21.4';
    # copy scan data from 2020-12-29 to prestage athe ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /tmp/configfiles/;
    /usr/bin/logger '..opening TAR Ball' -t 'gse-21.4';
    tar -xzf /tmp/configfiles/scandata.tar.gz; 
    /usr/bin/logger '..copy feed data to /gvm/lib/gvm and openvas' -t 'gse-21.4';
    /bin/cp -r /tmp/configfiles/GVM/openvas/plugins/* /var/lib/openvas/plugins/;
    chown -R gvm:gvm /opt/gvm;
    /usr/bin/logger 'prestage_scan_data finished' -t 'gse-21.4';
}

update_scan_data() {
    /usr/bin/logger 'update_scan_data' -t 'gse-21.4';
    ## This relies on the configure_greenbone_updates
    /usr/bin/logger '..Running feed sync. This will take a while' -t 'gse-21.4';
    /opt/gvm/gse-updater/gse-updater.sh;
    /usr/bin/logger 'update_scan_data finished' -t 'gse-21.4';
}

install_gvm_tools() {
    /usr/bin/logger 'install_gvm_tools' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone
    # Install gvm-tools
    cd gvm-tools/;
    chown -R gvm:gvm /opt/gvm;
    python3 -m pip install .;
    /usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_gvm_tools finished' -t 'gse-21.4';
}

install_impacket() {
    /usr/bin/logger 'install_impacket' -t 'gse-21.4';
    # Install impacket
    python3 -m pip install impacket;
    /usr/bin/logger 'install_impacket finished' -t 'gse-21.4';
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gse-21.4';
    # Create openvas configuration file
    cat << __EOF__ > /etc/openvas/openvas.conf
cgi_path = /cgi-bin:/scripts
checks_read_timeout = 5
nasl_no_signature_check = yes
max_checks = 10
time_between_request = 0
safe_checks = yes
optimize_test = yes
allow_simultaneous_ips = yes
unscanned_closed = yes
debug_tls = 0
test_empty_vhost = no
open_sock_max_attempts = 10
plugins_timeout = 320
scanner_plugins_timeout = 36000
timeout_retry = 3
vendor_version = 
plugins_folder = /var/lib/openvas/plugins
config_file = /etc/openvas/openvas.conf
max_hosts = 30
db_address = /run/redis/redis.sock
report_host_details = yes
expand_vhosts = yes
log_plugins_name_at_load = no
log_whole_attack = no
include_folders = /var/lib/openvas/plugins
auto_enable_dependencies = yes
drop_privileges = no
test_alive_hosts_only = yes
unscanned_closed_udp = yes
non_simult_ports = 139, 445, 3389, Services/irc
__EOF__

    # Create OSPD Openvas service
    cat << __EOF__ > /lib/systemd/system/ospd-openvas.service
[Unit]
Description=OSPD OpenVAS
After=network.target networking.service redis-server.service systemd-tmpfiles.service
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
Environment="PATH=/opt/gvm/sbin:/opt/gvm/bin:/usr/sbin:/usr/bin:/sbin:/bin"
User=gvm
Group=gvm
# Change log-level to info before production
ExecStart=/usr/local/bin/ospd-openvas --port=9390 --bind-address=0.0.0.0 --pid-file=/run/gvm/ospd-openvas.pid --lock-file-dir=/run/gvm/ --key-file=/var/lib/gvm/private/CA/secondary-key.pem --cert-file=/var/lib/gvm/CA/secondary-cert.pem --ca-file=/var/lib/gvm/CA/cacert.pem --log-file=/var/log/gvm/ospd-openvas.log
# --log-level in ospd-openvas.conf can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
__EOF__

    ## Configure ospd
    # Directory for ospd-openvas configuration file
    mkdir -p /etc/ospd;
    cat << __EOF__ > /etc/ospd/ospd-openvas.conf
[OSPD - openvas]
log_level = INFO
socket_mode = 0o766
unix_socket = /run/ospd/ospd-openvas.sock
pid_file = /run/ospd/ospd-openvas.pid
; default = /run/ospd
lock_file_dir = /run/gvm

; max_scans, is the number of scan/task to be started before start to queuing.
max_scans = 0

; The minimal available memory before the GSM starts to queue scans.
min_free_mem_scan_queue = 1500

; max_queued_scans is the maximum amount of queued scans before starting to reject the new task (will not be queued) and send an error message to gvmd
; This options are disabled with the value 0 (zero), all arriving tasks will be started without queuing.
max_queued_scans = 0
__EOF__
    sync;
    /usr/bin/logger 'configure_openvas finished' -t 'gse-21.4';
}

configure_greenbone_updates() {
/usr/bin/logger 'configure_greenbone_updates' -t 'gse-21.4';
    # Configure daily GVM updates timer and service
    mkdir -p /opt/gvm/gse-updater;
    # Timer
    cat << __EOF__ > /lib/systemd/system/gse-update.timer
[Unit]
Description=Daily job to update nvt feed

[Timer]
# Do not run for the first 37 minutes after boot
OnBootSec=37min
# Run at 18:00 with a random delay of up-to 2 hours before nightly scans  
OnCalendar=*-*-* 18:00:00
RandomizedDelaySec=7200
# Specify service
Unit=gse-update.service

[Install]
WantedBy=multi-user.target
__EOF__  

    ## Create gse-update.service
    cat << __EOF__ > /lib/systemd/system/gse-update.service
[Unit]
Description=gse updater
After=network.target networking.service
Documentation=man:gvmd(8)

[Service]
ExecStart=/opt/gvm/gse-updater/gse-updater.sh
TimeoutSec=300

[Install]
WantedBy=multi-user.target
__EOF__    

    # Create script for gse-update.service
    cat << __EOF__  > /opt/gvm/gse-updater/gse-updater.sh;
#! /bin/bash
# updates feeds for openvas on secondary server
# NVT data
su gvm -c "/opt/gvm/bin/greenbone-nvt-sync";
/usr/bin/logger ''nvt data Feed Version \$(su gvm -c "/opt/gvm/bin/greenbone-nvt-sync --feedversion")'' -t gse;
__EOF__
sync;
chmod +x /opt/gvm/gse-updater/gse-updater.sh;
/usr/bin/logger 'configure_greenbone_updates finished' -t 'gse-21.4';
}   

start_services() {
    /usr/bin/logger 'start_services' -t 'gse-21.4';
    # Load new/changed systemd-unitfiles
    systemctl daemon-reload;
    # Restart Redis with new config
    systemctl restart redis;
    # Enable GSE units
    systemctl enable ospd-openvas.service;
    # Start ospd-openvas
    systemctl restart ospd-openvas.service;
    # Enable gse-update timer and service
    systemctl enable gse-update.timer;
    systemctl enable gse-update.service;
    # Will start after next reboot - may disturb the initial update
    systemctl start gse-update.timer;
    # Check status of critical service ospd-openvas.service and gse-update
    echo -e
    echo 'Checking core daemons.....';
    if systemctl is-active --quiet gse-update.timer;
    then
        echo 'gse-update.timer started successfully';
        /usr/bin/logger 'gse-update.timer started successfully' -t 'gse-21.4';
    else
        echo 'gse-update.timer FAILED! Updates will not be automated';
        /usr/bin/logger 'gse-update.timer FAILED! Updates will not be automated' -t 'gse-21.4';
    fi
    /usr/bin/logger 'start_services finished' -t 'gse-21.4';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gse-21.4';
        cat << __EOF__ > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
__EOF__
    # start systemd-tmpfiles to create directories
    systemd-tmpfiles --create;
    cat << __EOF__  > /etc/redis/redis.conf
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
__EOF__
    # Redis requirements - overcommit memory and TCP backlog setting > 511
    sysctl -w vm.overcommit_memory=1;
    sysctl -w net.core.somaxconn=1024;
    echo "vm.overcommit_memory=1" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=1024" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    cat << __EOF__  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by redis
GRUB_CMDLINE_LINUX_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT transparent_hugepage=never"
__EOF__
update-grub;
    sync;
    /usr/bin/logger 'configure_redis finished' -t 'gse-21.4';
}

configure_permissions() {
    /usr/bin/logger 'configure_permissions' -t 'gse-21.4';
    /usr/bin/logger '..Setting correct ownership of files for user gvm' -t 'gse-21.4';
    # Once more to ensure that GVM owns all files in /opt/gvm
    chown -R gvm:gvm /opt/gvm/;
    # GSE log files
    chown -R gvm:gvm /var/log/gvm/;
    # Openvas feed
    chown -R gvm:gvm /var/lib/openvas;
    # GVM Feed
    chown -R gvm:gvm /var/lib/gvm;
    # OSPD Configuration file
    chown -R gvm:gvm /etc/ospd/;
    /usr/bin/logger 'configure_permissions finished' -t 'gse-21.4';
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'gse-21.4';
    mkdir /opt/gvm/scripts;
    chown -R gvm:gvm /opt/gvm/scripts/;
    cat << __EOF__  > /opt/gvm/scripts/gvm-tasks.py
from gvm.connections import UnixSocketConnection
from gvm.protocols.gmp import Gmp
from gvm.transforms import EtreeTransform
from gvm.xml import pretty_print

connection = UnixSocketConnection(path = '/run/gvm/gvmd.sock')
transform = EtreeTransform()

with Gmp(connection, transform=transform) as gmp:
    # Retrieve GMP version supported by the remote daemon
    version = gmp.get_version()

    # Prints the XML in beautiful form
    pretty_print(version)

    # Login
    gmp.authenticate('admin', 'password')

    # Retrieve all tasks
    tasks = gmp.get_tasks()

    # Get names of tasks
    task_names = tasks.xpath('task/name/text()')
    pretty_print(task_names)
__EOF__
    sync;
    /usr/bin/logger 'create_gvm_python_script finished' -t 'gse-21.4';
}

configure_cmake() {
    /usr/bin/logger 'configure_cmake' -t 'gse-21.4';
    # Temporary workaround until CMAKE recognizes Postgresql 13
    sed -ie '1 s/^/set(PostgreSQL_ADDITIONAL_VERSIONS "13")\n/' /usr/share/cmake-3.18/Modules/FindPostgreSQL.cmake
    # Temporary workaround until CMAKE recognizes Postgresql 13
   /usr/bin/logger 'configure_cmake finished' -t 'gse-21.4';
}

update_openvas_feed () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info';
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gse';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
   # Shared components
    install_prerequisites;
    prepare_nix;
    prepare_source_secondary;
    
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
    # Prestage only works on the specific Vagrant lab where a scan-data tar-ball is copied to the Host. 
    # Update scan-data only from greenbone when used everywhere else 
    prestage_scan_data;
    configure_greenbone_updates;
    configure_permissions;
    update_scan_data;
    update_openvas_feed;
    start_services;
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------------------\e[0m";
    echo -e;
    echo '\e[1;31mCopy the required certificates from the primary server (/root/sec_certs) and run install-vuln-secondary-certs.sh\e[0m';
    echo -e;
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------------------\e[0m";
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of Openvas feed data into Redis, then reboot' -t 'gse-21.4';
}

main;

exit 0;


######################################################################################################################################
# Post install 
#
# The feedowner/admin account is created as part of the script.
# The admin account is import feed owner: https://community.greenbone.net/t/gvm-20-08-missing-report-formats-and-scan-configs/6397/2
# /opt/gvm/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value UUID of admin account 
# Get the uuid using /opt/gvm/sbin/gvmd --get-users --verbose
# The first OpenVas scanner is always this UUID gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73
#
# Admin user:   cat /var/lib/gvm/adminuser.
#               You should change this: /opt/gvm/sbin/gvmd --user admin --new-password 'Your new password'
#
# Check the logs:
# tail -f /var/log/gvm/ospd-openvas.log
# tail -f /var/log/gvm/gvmd.log
# tail -f /var/log/gvm/openvas-log < This is very useful when scanning
# tail -f /var/log/syslog | grep -i gse
#
# Create required certs for secondary on primary run /opt/gvm/sbin/gvm-manage-certs -e ./gsecert.cfg  -v -d -c
#
# Using ps or top, You'll notice that redis is being hammered by ospd-openvas.
#
# When running a - tail -f /var/log/gvm/openvas.log - is useful in following progress during scanning.
#