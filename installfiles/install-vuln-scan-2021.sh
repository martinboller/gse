#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-12-17                                                  #
# Version:      2.00                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#               2021-05-07 Update to 21.4.0 (1.50)                          #
#               2021-09-13 Updated to run on Debian 10 and 11               #
#               2021-10-23 Latest GSE release                               #
#               2021-10-25 Correct ospd-openvas.sock path                   #
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
    echo -e "\e[1;32m--------------------------------------------\e[0m";
    echo -e "\e[1;32mInstalling Prerequisite packages\e[0m";
    export DEBIAN_FRONTEND=noninteractive;
    # OS Version
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    /usr/bin/logger "Operating System: $OS Version: $VER" -t 'gse-21.4';
    echo -e "\e[1;32mOperating System: $OS Version: $VER\e[0m";
     # Install prerequisites
    # Prepare package sources for NODEJS 14
    export VERSION=node_14.x
    export KEYRING=/usr/share/keyrings/nodesource.gpg
    export DISTRIBUTION="$(lsb_release -s -c)"
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee "$KEYRING" >/dev/null
    gpg --no-default-keyring --keyring "$KEYRING" --list-keys
    echo "deb [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRIBUTION main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    echo "deb-src [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRIBUTION main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
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
    # Install pre-requisites for 
    # libunistring is a new requirement from oct-13 updates
    /usr/bin/logger '..Tools for Development' -t 'gse-21.4';
    apt-get -y install gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev redis-server libunistring-dev libxml2-dev;
    # Install pre-requisites for gsad
    /usr/bin/logger '..Prerequisites for GSAD' -t 'gse-21.4';
    apt-get -y install libmicrohttpd-dev;
    
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
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy;
            npm install -g yarn --force;
    elif [ $VER -eq "10" ]
        then
            /usr/bin/logger '..install_prerequisites_debian_10_buster' -t 'gse-21.4';
            # Install pre-requisites for gvmd on buster (debian 10)
            apt-get -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all postgresql-server-dev-11 \
            pkg-config libical-dev xsltproc doxygen;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            /usr/bin/logger '....Other prerequisites for GSE on Debian 10' -t 'gse-21.4';
            apt-get -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy;
            npm install -g yarn --force;
        else
            /usr/bin/logger '..install_prerequisites_debian_Untested' -t 'gse-21.4';
            # Untested but let's try like it is buster (debian 10)
            apt-get -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all postgresql-server-dev-11 \
            pkg-config libical-dev xsltproc doxygen;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            /usr/bin/logger '....Other prerequisites for GSE on unknown OS' -t 'gse-21.4';
            apt-get -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy;
            npm install -g yarn --force;
        fi

    # Required for PDF report generation
    /usr/bin/logger '....Prerequisites for PDF report generation' -t 'gse-21.4';
    echo -e "\e[1;32mRequired for PDF report generation\e[0m";
    apt-get -y install texlive-full texlive-fonts-recommended;
    # Install other preferences and clean up APT
    /usr/bin/logger '....Install some preferences on Debian and clean up APT' -t 'gse-21.4';
    apt-get -y install bash-completion;
    # Install SUDO
    apt-get -y install sudo;
    # A little apt 
    apt-get -y install --fix-missing;
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
    /usr/bin/logger 'prepare_nix()' -t 'gse-21.4';
    echo -e "\e[1;32mCreating Users, configuring sudoers, and setting locale\e[0m";
    # set desired locale
    localectl set-locale en_US.UTF-8;
    # Create gvm user
    /usr/sbin/useradd --system --create-home --home-dir /opt/gvm/ -c "gvm User" --shell /bin/bash gvm;
    mkdir /opt/gvm;
    chown gvm:gvm /opt/gvm;
    # Update the PATH environment variable
    echo "PATH=\$PATH:/opt/gvm/bin:/opt/gvm/sbin" > /etc/profile.d/gvm.sh;
    # Add GVM library path to /etc/ld.so.conf.d

    sh -c 'cat << EOF > /etc/ld.so.conf.d/greenbone.conf;
# Greenbone libraries
/opt/gvm/lib
/opt/gvm/include
EOF'

# sudoers.d to run openvas as root
    sh -c 'cat << EOF > /etc/sudoers.d/greenbone
gvm     ALL = NOPASSWD: /opt/gvm/sbin/gsad, /opt/gvm/sbin/gvmd, /opt/gvm/sbin/openvas

Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gvm/sbin"
EOF'
    # It appears that GVMD sometimes delete /run/gvm so added a subfolder (/gse) to prevent this
    sh -c 'cat << EOF > /etc/tmpfiles.d/greenbone.conf
d /run/gvm 1775 gvm gvm
d /run/gvm/gse 1775 root root
d /run/ospd 1775 gvm gvm
d /run/ospd/gse 1775 root root
EOF'
    # start systemd-tmpfiles to create directories
    systemd-tmpfiles --create;
        /usr/bin/logger 'prepare_nix() finished' -t 'gse-21.4';

}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'gse-21.4';
    echo -e "\e[1;32mPreparing GSE Source files\e[0m";
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
    /usr/bin/logger '..gvm daemon' -t 'gse-21.4';
    wget -O gvmd.tar.gz https://github.com/greenbone/gvmd/archive/refs/tags/v21.4.4.tar.gz;
    /usr/bin/logger '..gsa daemon' -t 'gse-21.4';
    wget -O gsa.tar.gz https://github.com/greenbone/gsa/archive/refs/tags/v21.4.3.tar.gz;
    /usr/bin/logger '..openvas-smb' -t 'gse-21.4';
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v21.4.0.tar.gz;
    /usr/bin/logger '..ospd' -t 'gse-21.4';
    wget -O ospd.tar.gz https://github.com/greenbone/ospd/archive/refs/tags/v21.4.4.tar.gz;
    /usr/bin/logger '..python-gvm' -t 'gse-21.4';
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v21.10.0.tar.gz;
    /usr/bin/logger '..gvm-tools' -t 'gse-21.4';
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v21.6.1.tar.gz;
  
    # open and extract the tarballs
    /usr/bin/logger '..open and extract the tarballs' -t 'gse-21.4';
    find *.gz | xargs -n1 tar zxvfp;
    sync;

    # Naming of directories w/o version
    /usr/bin/logger '..rename directories' -t 'gse-21.4';    
    mv /opt/gvm/src/greenbone/gvm-libs-21.4.3 /opt/gvm/src/greenbone/gvm-libs;
    mv /opt/gvm/src/greenbone/ospd-openvas-21.4.3 /opt/gvm/src/greenbone/ospd-openvas;
    mv /opt/gvm/src/greenbone/openvas-scanner-21.4.3 /opt/gvm/src/greenbone/openvas;
    mv /opt/gvm/src/greenbone/gvmd-21.4.4 /opt/gvm/src/greenbone/gvmd;
    mv /opt/gvm/src/greenbone/gsa-21.4.3 /opt/gvm/src/greenbone/gsa;
    mv /opt/gvm/src/greenbone/openvas-smb-21.4.0 /opt/gvm/src/greenbone/openvas-smb;
    mv /opt/gvm/src/greenbone/ospd-21.4.4 /opt/gvm/src/greenbone/ospd;
    mv /opt/gvm/src/greenbone/python-gvm-21.10.0 /opt/gvm/src/greenbone/python-gvm;
    mv /opt/gvm/src/greenbone/gvm-tools-21.6.1 /opt/gvm/src/greenbone/gvm-tools;
    sync;
    chown -R gvm:gvm /opt/gvm;
    /usr/bin/logger 'prepare_source finished' -t 'gse-21.4';
}

prepare_source_latest() {    
    /usr/bin/logger 'prepare_source_latest' -t 'gse-21.4';
    echo -e "\e[1;32mPreparing GSE Source for latest versions\e[0m";
    mkdir -p /opt/gvm/src/greenbone
    chown -R gvm:gvm /opt/gvm/src/greenbone;
    cd /opt/gvm/src/greenbone;
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
    chown -R gvm:gvm /opt/gvm;
    /usr/bin/logger 'prepare_source_latest EXPERIMENTAL finished' -t 'gse-21.4';
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
    #/usr/bin/logger '..make gvm libraries Documentation' -t 'gse-21.4';
    #make doc-full;
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

install_gvm() {
    /usr/bin/logger 'install_gvm' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone;
    # Build Manager
    cd gvmd/;
    /usr/bin/logger '..cmake GVM Daemon' -t 'gse-21.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .;
    /usr/bin/logger '..make GVM Daemon' -t 'gse-21.4';
    make;
    #/usr/bin/logger '..make documentation for GVM Daemon' -t 'gse-21.4';
    #make doc-full;
    /usr/bin/logger '..make install GVM Daemon' -t 'gse-21.4';
    make install;
    sync;
    /usr/bin/logger 'install_gvm finished' -t 'gse-21.4';
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
    # copy scan data to prestage ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /tmp/configfiles/;
    /usr/bin/logger '..opening and extracting TAR Ball' -t 'gse-21.4';
    tar -xzf /tmp/configfiles/scandata.tar.gz; 
    /usr/bin/logger '..copy feed data to /gvm/lib/gvm and openvas' -t 'gse-21.4';
    /bin/cp -r /tmp/configfiles/GVM/openvas/plugins/* /var/lib/openvas/plugins/;
    /bin/cp -r /tmp/configfiles/GVM/gvm/* /var/lib/gvm/;
    chown -R gvm:gvm /opt/gvm;
    /usr/bin/logger 'prestage_scan_data finished' -t 'gse-21.4';
}

update_scan_data() {
    /usr/bin/logger 'update_scan_data' -t 'gse-21.4';
    ## This relies on the configure_greenbone_updates
    /opt/gvm/gse-updater/gse-updater.sh;
    /usr/bin/logger 'update_scan_data finished' -t 'gse-21.4';
}

install_gsa() {
    /usr/bin/logger 'install_gsa' -t 'gse-21.4';
    ## Install GSA
    cd /opt/gvm/src/greenbone
    chown -R gvm:gvm /opt/gvm;
    # GSA prerequisites
    /usr/bin/logger '..installing Yarn' -t 'gse-21.4';
    apt-get -y install yarnpkg;
    # GSA Install
    cd gsa/;
    /usr/bin/logger '..cmake GSA Daemon' -t 'gse-21.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm .;
    /usr/bin/logger '..make GSA Daemon' -t 'gse-21.4';
    make;                # build the libraries
    #/usr/bin/logger '..make documentation for GSA Daemon' -t 'gse-21.4';
    #make doc-full;       # build more developer-oriented documentation
    /usr/bin/logger '..make install GSA Daemon' -t 'gse-21.4';
    make install;        # install the build
    sync;
    /usr/bin/logger 'install_gsa finished' -t 'gse-21.4';
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

prepare_postgresql() {
    /usr/bin/logger 'prepare_postgresql' -t 'gse-21.4';
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
    /usr/bin/logger 'prepare_postgresql finished' -t 'gse-21.4';
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gse-21.4';
    # Create openvas.conf file
    sh -c 'cat << EOF > /etc/openvas/openvas.conf
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
vendor_version = Greenbone Source Edition 21.4.10
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
EOF'
    # Create OSPD-OPENVAS service
    sh -c 'cat << EOF > /lib/systemd/system/ospd-openvas.service
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
ExecStart=/usr/local/bin/ospd-openvas --config=/etc/ospd/ospd-openvas.conf --log-file=/var/log/gvm/ospd-openvas.log
# log level can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF'

    ## Configure ospd
    # Directory for ospd-openvas configuration file
    mkdir -p /etc/ospd;
    sh -c 'cat << EOF > /etc/ospd/ospd-openvas.conf
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
EOF'
    sync;
    /usr/bin/logger 'configure_openvas finished' -t 'gse-21.4';
}

configure_gvm() {
    /usr/bin/logger 'configure_gvm' -t 'gse-21.4';
    # Create Certificates
    /opt/gvm/bin/gvm-manage-certs -a;
    sh -c 'cat << EOF > /lib/systemd/system/gvmd.service
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
PIDFile=/run/gvm/gvmd.pid
# feed-update lock must be shared between ospd, gvmd, and greenbone-nvt-sync/greenbone-feed-sync
ExecStart=-/opt/gvm/sbin/gvmd --unix-socket=/run/gvm/gvmd.sock --feed-lock-path=/run/gvm/feed-update.lock --listen-group=gvm --client-watch-interval=0 --osp-vt-update=/run/ospd/ospd-openvas.sock
Restart=always
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
Alias=greenbone-vulnerability-manager.service
EOF'    
    sync;
    /usr/bin/logger 'configure_gvm finished' -t 'gse-21.4';
    }

configure_gsa() {
    /usr/bin/logger 'configure_gsa' -t 'gse-21.4';
    # Configure GSA daemon
    sh -c 'cat << EOF > /lib/systemd/system/gsad.service
[Unit]
Description=Greenbone Security Assistant daemon (gsad)
After=network.target networking.service gvmd.service
Documentation=man:gsad(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
User=gvm
Group=gvm
PIDFile=/run/gvm/gsad.pid
ExecStart=/opt/gvm/sbin/gsad --port=8443 --ssl-private-key=/var/lib/gvm/private/CA/serverkey.pem --ssl-certificate=/var/lib/gvm/CA/servercert.pem --munix-socket=/run/gvm/gvmd.sock --no-redirect --secure-cookie --http-sts --timeout=60 --http-cors="https://%H:8443/" --gnutls-priorities=SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
Alias=greenbone-security-assistant.service
EOF'    
    sync;
/usr/bin/logger 'configure_gsa finished' -t 'gse-21.4';
}

configure_feed_owner() {
    /usr/bin/logger 'configure_feed_owner' -t 'gse-21.4';
    echo "User admin for GVM $HOSTNAME " >> /var/lib/gvm/adminuser;
    if systemctl is-active --quiet gvmd.service;
    then
        su gvm -c '/opt/gvm/sbin/gvmd --create-user=admin' >> /var/lib/gvm/adminuser;
        su gvm -c '/opt/gvm/sbin/gvmd --get-users --verbose' > /var/lib/gvm/feedowner;
        awk -F " " {'print $2'} /var/lib/gvm/feedowner > /var/lib/gvm/uuid;
        # Ensure UUID is available in user gvm context
        su gvm -c 'cat /var/lib/gvm/uuid | xargs /opt/gvm/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $1'
        /usr/bin/logger 'configure_feed_owner User creation success' -t 'gse-21.4';
    else
        echo "User admin for GVM $HOSTNAME could NOT be created - FAIL!" >> /var/lib/gvm/adminuser;
        /usr/bin/logger 'configure_feed_owner User creation FAILED!' -t 'gse-21.4';
    fi
    /usr/bin/logger 'configure_feed_owner finished' -t 'gse-21.4';
}

configure_greenbone_updates() {
/usr/bin/logger 'configure_greenbone_updates' -t 'gse-21.4';
    # Configure daily GVM updates timer and service
    mkdir -p /opt/gvm/gse-updater;
    # Timer
    sh -c 'cat << EOF > /lib/systemd/system/gse-update.timer
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
EOF'  

    ## Create gse-update.service
    sh -c 'cat << EOF > /lib/systemd/system/gse-update.service
[Unit]
Description=gse updater
After=network.target networking.service
Documentation=man:gvmd(8)

[Service]
ExecStart=/opt/gvm/gse-updater/gse-updater.sh
TimeoutSec=900

[Install]
WantedBy=multi-user.target
EOF'    

    # Create script for gse-update.service
    sh -c 'cat << EOF  > /opt/gvm/gse-updater/gse-updater.sh;
#! /bin/bash
# updates feeds for Greenbone Vulnerability Manager
# Using the Community feed require some significant delays between syncs, as only one session at a time is allowed for community feed
# NVT data
su gvm -c "/opt/gvm/bin/greenbone-nvt-sync --rsync";
/usr/bin/logger ''nvt data Feed Version \$(su gvm -c "/opt/gvm/bin/greenbone-nvt-sync --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 62;

# CERT data
su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type cert";
/usr/bin/logger ''Certdata Feed Version \$(su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type cert --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 62;

# SCAP data
su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type scap";/usr/bin/logger ''Scapdata Feed Version \$(su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type scap --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 62;

# GVMD data
su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type gvmd_data";
/usr/bin/logger ''gvmd data Feed Version \$(su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type gvmd_data --feedversion")'' -t gse;
exit 0
EOF'
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
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking core daemons for GSE......\e[0m";
    if systemctl is-active --quiet gvmd.service;
    then
        echo -e "\e[1;32mgvmd.service started successfully";
        /usr/bin/logger 'gvmd.service started successfully' -t 'gse-21.4';
    else
        echo -e "\e[1;31mgvmd.service FAILED!\e[0m";
        /usr/bin/logger 'gvmd.service FAILED' -t 'gse-21.4';
    fi
    # gsad.service
    if systemctl is-active --quiet gsad.service;
    then
        echo -e "\e[1;32mgsad.service started successfully";
        /usr/bin/logger 'gsad.service started successfully' -t 'gse-21.4';
    else
        echo -e "\e[1;31mgsad.service FAILED!\e[0m";
        /usr/bin/logger "gsad.service FAILED!" -t 'gse-21.4';
    fi
    # ospd-openvas.service
    if systemctl is-active --quiet ospd-openvas.service;
    then
        echo -e "\e[1;32mospd-openvas.service started successfully\e[0m";
        /usr/bin/logger 'ospd-openvas.service started successfully' -t 'gse-21.4';
    else
        echo -e "\e[1;31mospd-openvas.service FAILED!";
        /usr/bin/logger 'ospd-openvas.service FAILED!\e[0m' -t 'gse-21.4';
    fi
    if systemctl is-active --quiet gse-update.timer;
    then
        echo -e "\e[1;32mgse-update.timer started successfully\e[0m"
        /usr/bin/logger 'gse-update.timer started successfully' -t 'gse-21.4';
    else
        echo -e "\e[1;31mgse-update.timer FAILED! Updates will not be automated\e[0m";
        /usr/bin/logger 'gse-update.timer FAILED! Updates will not be automated' -t 'gse-21.4';
    fi
    /usr/bin/logger 'start_services finished' -t 'gse-21.4';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gse-21.4';
    sh -c 'cat << EOF > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
EOF'
    # start systemd-tmpfiles to create directories
    systemd-tmpfiles --create;
    sh -c 'cat << EOF  > /etc/redis/redis.conf
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
    sh -c 'cat << EOF  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by redis
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT transparent_hugepage=never"
EOF'
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

show_default_scanner_status() {
    # Check status of Default scanners (Openvas and CVE).
    # If returning "Failed to verify scanner" most likely GVMD cannot communicate with ospd-openvas.sock
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking default scanner connectivity.......\e[0m";
    su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73';
    su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b';
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    # Write status to syslog too
    /usr/bin/logger ''Default OpenVAS $(su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73")'' -t 'gse-21.4';    
    /usr/bin/logger ''Default CVE $(su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b")'' -t 'gse-21.4';
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'gse-21.4';
    mkdir /opt/gvm/scripts;
    chown -R gvm:gvm /opt/gvm/scripts/;
    sh -c "cat << EOF  > /opt/gvm/scripts/gvm-tasks.py
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
EOF"
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
    echo -e "\e[1;31m-----------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;31mStarting installation of primary Greenbone Source Edition Server: $HOSTNAME\e[0m"
    echo -e "\e[1;31mServer: $HOSTNAME will also be the Certificate Authority for itself and all secondaries\e[0m"
    echo -e "\e[1;31m-----------------------------------------------------------------------------------------------------\e[0m"
    # Shared variables
    # Certificate options
   
    # Lifetime in days
    export GVM_CERTIFICATE_LIFETIME=3650
    # Country
    export GVM_CERTIFICATE_COUNTRY="DE"
    # Locality
    export GVM_CERTIFICATE_LOCALITY="Germany"
    # Organization
    export GVM_CERTIFICATE_ORG="Greenbone Source Edition"
    # (Organization unit)
    export GVM_CERTIFICATE_ORG_UNIT="Certificate Authority for $GVM_CERTIFICATE_ORG"
    # State
    export GVM_CA_CERTIFICATE_STATE="Bavaria"
    # Security Parameters
    GVM_CERTIFICATE_SECPARAM="high"
    GVM_CERTIFICATE_SIGNALG="SHA512"
    # Hostname
    export GVM_CERTIFICATE_HOSTNAME=$HOSTNAME
    # CA Certificate Lifetime
    export GVM_CA_CERTIFICATE_LIFETIME=3652
    # Key & cert material locations
    export GVM_KEY_LOCATION="/var/lib/gvm/private/CA"
    export GVM_CERT_LOCATION="/var/lib/gvm/CA"

    # Shared components
    install_prerequisites;
    prepare_nix;
    prepare_source;
    configure_cmake;
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH
    # For latest builds use prepare_source_latest instead of prepare_source
    # It is likely to break, so Don't.
    #prepare_source_latest;
    
    # Installation of specific components
    # This is the master server so install GSAD
    # Only install poetry when testing
    #install_poetry;
    #install_nmap;

    # Prepare postgresql for GVMD and redis for OpenVAS
    prepare_postgresql;
    configure_redis;
    # Install everything needed for Greenbone Source Edition
    install_gvm_libs;
    install_gvm;
    install_openvas_smb;
    install_openvas;
    install_ospd;
    install_ospd_openvas;
    install_gvm_tools;
    install_python_gvm;
    install_gsa;
    # Configuration of installed components
    configure_gvm;
    configure_openvas;
    configure_gsa;
    create_gvm_python_script;
    # Prestage only works on the specific Vagrant lab where a scan-data tar-ball is copied to the Host. 
    # Update scan-data only from greenbone when used everywhere else 
    prestage_scan_data;
    configure_greenbone_updates;
    configure_permissions;
    update_scan_data;
    update_openvas_feed;
    start_services;
    configure_feed_owner;
    show_default_scanner_status;
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot' -t 'gse-21.4';
    echo -e;
    echo -e "\e[1;32mInstallation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot\e[0m";
}

main;

exit 0;

######################################################################################################################################
# Post install 
# 
# Feedowner/admin account is automatically created during installation.x
# The admin account is import feed owner: https://community.greenbone.net/t/gvm-20-08-missing-report-formats-and-scan-configs/6397/2
# /opt/gvm/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value UUID of admin account 
# Get the uuid using /opt/gvm/sbin/gvmd --get-users --verbose
# The first OpenVas scanner is always this UUID /opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73
#
# 08b69003-5fc2-4037-a479-93b440211c73  OpenVAS  /run/ospd/ospd-openvas.sock  0  OpenVAS Default
# 6acd0832-df90-11e4-b9d5-28d24461215b  CVE    0  CVE
#
#
# Admin user:   cat /opt/gvm/lib/adminuser.
#               You should change this: /opt/gvm/sbin/gvmd --user admin --new-password 'Your new password'
#
# Check the logs:
# tail -f /var/log/gvm/ospd-openvas.log
# tail -f /var/log/gvm/gvmd.log
# tail -f /var/log/gvm/openvas-log < This is very useful when scanning
# tail -f /var/log/syslog | grep -i gse
#
# Create required certs for secondary
# # cd /root/sec_certs
# /opt/gvm/sbin/gvm-manage-certs -e ./gsecert.cfg -v -d -c
# copy secondarycert.pem, secondarykey.pem, and /var/lib/gvm/CA/cacert.pem to the remote system to the correct locations. 
# Then create the scanner in GVMD
# chown gvm:gvm *
# su gvm -c '/opt/gvm/sbin/gvmd --create-scanner="OSP Scanner secondary hostname" --scanner-host=hostname --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondarycert.pem --scanner-key-priv=./secondarykey.pem'
# Example:
#   su gvm -c '/opt/gvm/sbin/gvmd --create-scanner="OpenVAS Secondary host aboleth" --scanner-host=aboleth --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondarycert.pem --scanner-key-priv=./secondarykey.pem'
#       Scanner created.
# 
# Don't forget to install the certs on the secondary as discussed further down, then return and do these verification steps on the primary:
#   
#   su gvm -c '/opt/gvm/sbin/gvmd --get-scanners'
#       08b69003-5fc2-4037-a479-93b440211c73  OpenVAS  /var/run/ospd/ospd-openvas.sock  0  OpenVAS Default
#       6acd0832-df90-11e4-b9d5-28d24461215b  CVE    0  CVE
#       3e2232e3-b819-41bc-b5be-db52bfb06588  OpenVAS  mysecondary  9390  OSP Scanner mysecondary
#
#   su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner=3e2232e3-b819-41bc-b5be-db52bfb06588'
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
# When running a - tail -f /var/log/openvas.log - is useful in following progress during the scanning.
# /var/lib/gvm/private/CA/