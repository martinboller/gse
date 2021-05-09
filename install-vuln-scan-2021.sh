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
    /usr/bin/logger 'install_prerequisites finished' -t 'gse';
}

prepare_nix_users() {
    # Create gvm user
    /usr/sbin/useradd --system --create-home -c "gvm User" --shell /bin/bash gvm;
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

prepare_source_latest() {    
    /usr/bin/logger 'prepare_source_latest' -t 'gse';
    mkdir -p /usr/local/src/greenbone
    chown -R gvm:gvm /usr/local/src/greenbone;
    cd /usr/local/src/greenbone;
    ## If you want to experiment with the latest builds
    ## Warning: It WILL likely break, so don't :)
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
    # Installing from repo
    #/usr/bin/python3 -m pip install python-gvm;
    cd /usr/local/src/greenbone/;
    cd python-gvm/;
    /usr/bin/python3 -m pip install .;
    #/usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_python_gvm finished' -t 'gse';
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

install_gvm() {
    /usr/bin/logger 'install_gvm' -t 'gse';
    cd /usr/local/src/greenbone;
    # Build Manager
    cd gvmd/;
    cmake .;
    make                # build the libraries
    make doc-full       # build more developer-oriented documentation
    make install        # install the build
    sync;
    ldconfig;
    /usr/bin/logger 'install_gvm finished' -t 'gse';
}

install_nmap() {
    /usr/bin/logger 'install_nmap' -t 'gse';
    cd /usr/local/src/greenbone;
    # Install NMAP
    apt-get -y install ./nmap.deb --fix-missing;
    sync;
    /usr/bin/logger 'install_nmap finished' -t 'gse';
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gse';
    # copy scan data from 2020-12-29 to prestage athe ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /tmp/configfiles/;
    tar -xzf /tmp/configfiles/scandata.tar.gz; 
    /bin/cp -r /tmp/configfiles/GVM/openvas/plugins/* /usr/local/var/lib/openvas/plugins/;
    /bin/cp -r /tmp/configfiles/GVM/gvm/* /usr/local/var/lib/gvm/;
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
    sudo apt-get -y install --no-install-recommends yarn;

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
    # Create dir for ospd run files
    mkdir /run/ospd;
    chown -R ospd:gvm /run/ospd;
    # Ensure it is recreated after reboot
    sudo sh -c 'cat << EOF > /etc/tmpfiles.d/ospd-openvas.conf
d /run/ospd 1774 ospd gvm
EOF'
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/ospd-openvas.service
[Unit]
Description=OSPD OpenVAS
After=network.target networking.service redis-server.service systemd-tmpfiles.service
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
User=ospd
Group=gvm
# Change log-level to info before production
ExecStart=/usr/local/bin/ospd-openvas --config=/etc/ospd/ospd.conf --log-file=/usr/local/var/log/ospd/ospd-openvas.log --log-level=info
# log level can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
Alias=ospd-openvas.service
EOF'

    ## Configure ospd
    # Directory for ospd configuration file
    mkdir -p /etc/ospd;
    # Directory for ospd pid file
    mkdir -p /run/ospd;
    # Directory for ospd configuration file
    mkdir -p /usr/local/var/log/ospd;
    sudo sh -c 'cat << EOF > /etc/ospd/ospd.conf
[OSPD - openvas]
log_level = INFO
socket_mode = 0o766
unix_socket = /run/ospd/ospd.sock
pid_file = /run/ospd/ospd-openvas.pid
; default = /run/ospd
lock_file_dir = /run/ospd

; max_scans, is the number of scan/task to be started before start to queuing.
max_scans = 0

; The minimal available memory before the GSM starts to queue scans.
min_free_mem_scan_queue = 1500

; max_queued_scans is the maximum amount of queued scans before starting to reject the new task (will not be queued) and send an error message to gvmd
; This options are disabled with the value 0 (zero), all arriving tasks will be started without queuing.
max_queued_scans = 0
EOF'
    sync;
    /usr/bin/logger 'configure_openvas finished' -t 'gse';
}

configure_gvm() {
    /usr/bin/logger 'configure_gvm' -t 'gse';
    # Prepare sock file for gvmd
    mkdir /run/gvmd;
    touch /run/gvmd/gvmd.sock;
    chown -R gvm:gvm /run/gvmd;
    # Ensure it is recreated after reboot
    sudo sh -c 'cat << EOF > /etc/tmpfiles.d/gvmd.conf
d /run/gvmd 1774 gvm ospd
EOF'
    # Create Certificates
    # Certificate options
    # Lifetime in days
    export GVM_CERTIFICATE_LIFETIME=3650
    # Country
    export GVM_CERTIFICATE_COUNTRY="DK"
    # Locality
    export GVM_CERTIFICATE_LOCALITY="Denmark"
    # Organization
    export GVM_CERTIFICATE_ORG="bsecure.dk"
    # (Organization unit)
    export GVM_CERTIFICATE_ORG_UNIT="Security"
    GVM_CERTIFICATE_SECPARAM="high"
    GVM_CERTIFICATE_SIGNALG="SHA512"

    /usr/local/bin/gvm-manage-certs -a;
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/gvmd.service
[Unit]
Description=Greenbone Vulnerability Manager daemon (gvmd)
After=network.target networking.service postgresql.service ospd-openvas.service
Wants=postgresql.service ospd-openvas.service
Documentation=man:gvmd(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
User=gvm
Group=gvm
PIDFile=/usr/local/var/run/gvmd.pid
EnvironmentFile=/usr/local/etc/default/gvmd
# feed-update lock must be shared between ospd, gvmd, and greenbone-nvt-sync/greenbone-feed-sync
ExecStart=-/usr/local/sbin/gvmd --unix-socket=/run/gvmd/gvmd.sock --feed-lock-path=/run/ospd/feed-update.lock --listen-group=gvm --client-watch-interval=0 --osp-vt-update=/run/ospd/ospd.sock
Restart=always
TimeoutStopSec=20

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
Environment=HOSTNAME=$HOSTNAME
Type=forking
User=gvm
Group=ospd
PIDFile=/usr/local/var/run/gsad.pid
ExecStart=/usr/local/sbin/gsad --port=8443 --munix-socket=/run/gvmd/gvmd.sock --gnutls-priorities=SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2 --no-redirect --secure-cookie --http-sts --timeout=60 --http-cors="https://%H:8443/"
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
    if systemctl is-active --quiet gvmd.service;
    then
        su gvm -c '/usr/local/sbin/gvmd --create-user=admin' >> /usr/local/var/lib/adminuser;
        su gvm -c 'gvmd --get-users --verbose' > /usr/local/var/lib/feedowner;
        awk -F " " {'print $2'} /usr/local/var/lib/feedowner > /usr/local/var/lib/uuid;
        # Ensure UUID is available in user gvm context
        su gvm -c 'cat /usr/local/var/lib/uuid | xargs gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $1'
        /usr/bin/logger 'configure_feed_owner User creation success' -t 'gse';
    else
        echo "User admin for GVM $HOSTNAME could NOT be created - FAIL!" >> /usr/local/var/lib/adminuser;
        /usr/bin/logger 'configure_feed_owner User creation FAILED!' -t 'gse';
    fi
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
# Do not run for the first 57 minutes after boot
OnBootSec=57min
# Run Daily
OnUnitActiveSec=12h
# Specify service
Unit=gse-update.service

[Install]
WantedBy=multi-user.target
EOF'  

    ## Create gse-update.service
    sudo sh -c 'cat << EOF > /usr/local/lib/systemd/system/gse-update.service
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
# Using the Community feed require some good sleep, as only one session at a time is allowed
# NVT data
su gvm -c "/usr/local/bin/greenbone-nvt-sync --rsync";
/usr/bin/logger ''nvt data Feed Version \$(su gvm -c "greenbone-nvt-sync --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 67;

# CERT data
su gvm -c "/usr/local/sbin/greenbone-feed-sync --type cert";
/usr/bin/logger ''Certdata Feed Version \$(su gvm -c "greenbone-feed-sync --type cert --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 67;

# SCAP data
su gvm -c "/usr/local/sbin/greenbone-feed-sync --type scap";
/usr/bin/logger ''Scapdata Feed Version \$(su gvm -c "greenbone-feed-sync --type scap --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 67;

# GVMD data
su gvm -c "/usr/local/sbin/greenbone-feed-sync --type gvmd_data";
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
    # Load new/changed systemd-unitfiles
    systemctl daemon-reload;
    # Restart Redis with new config
    systemctl restart redis;
    # Enable GSE units
    systemctl enable ospd-openvas;
    systemctl enable gvmd.service;
    systemctl enable gsad.service;
    # Start GSE units
    systemctl restart ospd-openvas;
    systemctl restart gvmd.service;
    systemctl restart gsad.service;
    # Enable gse-update timer and service
    systemctl enable gse-update.timer;
    systemctl enable gse-update.service;
    # Will start after next reboot - may disturb the initial update
    systemctl start gse-update.timer;
    # Check status of critical services
    # gvmd.service
    if systemctl is-active --quiet gvmd.service;
    then
        /usr/bin/logger 'gvmd.service started successfully' -t 'gse';
    else
        /usr/bin/logger 'gvmd.service FAILED!' -t 'gse';
    fi
    # gsad.service
    if systemctl is-active --quiet gsad.service;
    then
        /usr/bin/logger 'gsad.service started successfully' -t 'gse';
    else
        /usr/bin/logger 'gsad.service FAILED!' -t 'gse';
    fi
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
        sudo sh -c 'cat << EOF  >> /etc/rc.local
#!/bin/bash
echo never > /sys/kernel/mm/transparent_hugepage/enabled
exit 0
EOF'
    chmod +x /etc/rc.local;
    sync;
    /usr/bin/logger 'configure_redis finished' -t 'gse';
}

configure_permissions() {
    chown -R gvm:gvm /usr/local/src/;
    chown -R gvm:gvm /usr/local/var/lib/gvm;
    chown -R gvm:gvm /usr/local/var/log/gvm;
    chown -R gvm:gvm /usr/local/var/run;
    # OpenVAS 
    chown -R gvm:gvm /usr/local/var/run;
    chown -R gvm:ospd /usr/local/var/lib/openvas;
    chown -R ospd:gvm /run/ospd/;
    # configure broader permissions as defined by tmpfiles.d/ to avoid a rebootsudo 
    chmod -R 1777 /run/ospd/;
    chown -R ospd:ospd /etc/ospd/;
    chown -R gvm:ospd /run/gvmd/;
    # configure broader permissions as defined by tmpfiles.d/ to avoid a reboot
    chmod -R 1777 /run/gvmd/;
    chown -R ospd:ospd /usr/local/var/log/ospd;
    chmod -R 1777 /usr/local/var/log/ospd;
    touch /usr/local/var/log/gvm/openvas.log;
    chown -R ospd:gvm /usr/local/var/log/gvm/openvas.log;
    chmod -R 1777 /usr/local/var/log/gvm/openvas.log;
    # Home dirs
    chown -R gvm:gvm /home/gvm;
    chown -R ospd:ospd /home/ospd;
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'gse';
    sudo sh -c "cat << EOF  > /home/gvm/gvm-tasks.py
from gvm.connections import UnixSocketConnection
from gvm.protocols.gmp import Gmp
from gvm.transforms import EtreeTransform
from gvm.xml import pretty_print

connection = UnixSocketConnection(path = '/run/gvmd/gvmd.sock')
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
EOF"
    sync;
    /usr/bin/logger 'create_gvm_python_script finished' -t 'gse';
}

create_gsecerts() {
    /usr/bin/logger 'create_gsecerts' -t 'gse';
    cd /root/
    mkdir sec_certs;
    cd /root/sec_certs;
    #Set required variables
    export GVM_CERTIFICATE_LIFETIME=3650
    export GVM_CERTIFICATE_COUNTRY="DK"
    export GVM_CERTIFICATE_LOCALITY="Denmark"
    export GVM_CERTIFICATE_ORG="bsecure.dk"
    export GVM_CERTIFICATE_ORG_UNIT="Security"
    export GVM_CERTIFICATE_HOSTNAME=*  
    export GVM_CA_CERTIFICATE_LIFETIME=3652
    export GVM_CA_CERTIFICATE_COUNTRY="$GVM_CERTIFICATE_COUNTRY"
    export GVM_CA_CERTIFICATE_STATE="$GVM_CERTIFICATE_STATE"
    export GVM_CA_CERTIFICATE_LOCALITY="$GVM_CERTIFICATE_LOCALITY"
    export GVM_CA_CERTIFICATE_ORG="$GVM_CERTIFICATE_ORG"
    export GVM_CA_CERTIFICATE_ORG_UNIT="Certificate Authority for $GVM_CERTIFICATE_HOSTNAME"
    export GVM_CERTIFICATE_SECPARAM="high"
    export GVM_CERTIFICATE_SIGNALG="SHA512"
    export GVM_KEY_LOCATION="/usr/local/var/lib/gvm/private/CA"
    export GVM_CERT_LOCATION="/usr/local/var/lib/gvm/CA"
    export GVM_CERT_PREFIX="secondary"
    export GVM_CERT_DIR="/root/sec_certs"
    export GVM_KEY_FILENAME="$GVM_CERT_DIR/${GVM_CERT_PREFIX}key.pem"
    export GVM_CERT_FILENAME="$GVM_CERT_DIR/${GVM_CERT_PREFIX}cert.pem"
    export GVM_CERT_REQUEST_FILENAME="$GVM_CERT_DIR/${GVM_CERT_PREFIX}request.pem"
    export GVM_CERT_TEMPLATE_FILENAME="gsecert-finished.cfg"
    export GVM_SIGNING_CA_KEY_FILENAME="$GVM_KEY_LOCATION/cakey.pem"
    export GVM_SIGNING_CA_CERT_FILENAME="$GVM_CERT_LOCATION/cacert.pem"
    # Create Certs
    /usr/bin/logger 'Creating certificates for secondary' -t 'gse';
    gvm-manage-certs -v -d -c;
    cp /usr/local/var/lib/gvm/CA/cacert.pem ./;
    sync;
    # Check certificate creation
    if test -f $GVM_CERT_FILENAME; then
        /usr/bin/logger 'certificates for secondary created' -t 'gse';
        echo "$GVM_CERT_FILENAME available"
        chown gvm:gvm *.pem;
    else
        /usr/bin/logger 'Certificates for secondary not created' -t 'gse';
        echo "$GVM_CERT_FILENAME not found, certificates not created"
    fi;
    /usr/bin/logger 'create_gsecerts finished' -t 'gse';
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
    # Only install poetry when testing
    #install_poetry;
    #install_nmap;
    install_gvm_libs;
    install_gvm;
    install_gsa;
    install_openvas_smb;
    install_openvas;
    install_ospd;
    install_ospd_openvas;
    install_gvm_tools;        
    install_python_gvm;
    # Configuration of installed components
    prepare_postgresql;
    configure_gvm;
    configure_openvas;
    configure_gsa;
    configure_redis;
    #configure_openvas_smb;
    create_gsecerts;
    create_gvm_python_script;

    # Prestage only works on the specific Vagrant lab where I've copied the scan-data to the Host. 
    # Update scan-data only from greenbone when used everywhere else 
    prestage_scan_data;
    configure_greenbone_updates;
    configure_permissions;
    update_scan_data;
    su gvm -c '/usr/local/sbin/openvas --update-vt-info';
    start_services;
    configure_feed_owner;
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
# Create required certs for secondary
# # cd /root/sec_certs
# gvm-manage-certs -e ./gsecert.cfg -v -d -c
# copy secondarycert.pem, secondarykey.pem, and /usr/local/var/lib/gvm/CA/cacert.pem to the remote system to the correct locations. 
# Then create the scanner in GVMD
# chown gvm:gvm *
# su gvm -c 'gvmd --create-scanner="OSP Scanner secondary hostname" --scanner-host=hostname --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/usr/local/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondarycert.pem --scanner-key-priv=./secondarykey.pem'
# Example:
#   su gvm -c 'gvmd --create-scanner="OSP Scanner aboleth" --scanner-host=aboleth --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/usr/local/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondarycert.pem --scanner-key-priv=./secondarykey.pem'
#       Scanner created.
# 
# Don't forget to install the certs on the secondary as discussed further down, then return and do these verification steps on the primary:
#   
#   su gvm -c 'gvmd --get-scanners'
#       08b69003-5fc2-4037-a479-93b440211c73  OpenVAS  /var/run/ospd/ospd.sock  0  OpenVAS Default
#       6acd0832-df90-11e4-b9d5-28d24461215b  CVE    0  CVE
#       3e2232e3-b819-41bc-b5be-db52bfb06588  OpenVAS  mysecondary  9390  OSP Scanner mysecondary
#
#   su gvm -c 'gvmd --verify-scanner=3e2232e3-b819-41bc-b5be-db52bfb06588'
#       Scanner version: OpenVAS 20.8.0.
#
#
#The gsecert.cfg file supplied creates a wildcard cert, so can be used on all the secondaries you wish. 
# 
# On Secondary:
# copy certificate files to correct locations. When copied locally use the script install-vuln-secondary-certs.sh
# The script also restarts the unit.
#
# Using ps or top, You'll notice that postgres is being hammered by gvmd and that redis are
# too, but by ospd-openvas.
#
# When running a - tail -f /usr/local/var/log/openvas.log - is useful in following on during the scanning.
#/usr/local/var/lib/gvm/private/CA/