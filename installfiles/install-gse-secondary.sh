#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2023-05-02                                                  #
# Version:      2.70                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#               2021-05-07 Update to 21.4.0 (1.50)                          #
#               2021-09-13 Updated to run on Debian 10 and 11               #
#               2021-10-23 Latest GSE release                               #
#               2021-10-25 Correct ospd-openvas.sock                        #
#               2021-12-17 Create secondary cert w hostname not *           #
#               2022-01-08 Improved console output during install (2.10)    #
#               2023-05-02 Latest versions and greenbone-feed-sync          #
#                                                                           #
# Info:         https://sadsloth.net/post/install-gvm-20_08-src-on-debian/  #
#                                                                           #
#                                                                           #
# Instruction:  Run this script as root on a fully updated                  #
#               Debian 10 (Buster) or Debian 11 (Bullseye)                  #
#                                                                           #
#############################################################################


install_prerequisites() {
    /usr/bin/logger 'install_prerequisites' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_prerequisites()\e[0m";
    echo -e "\e[1;32m--------------------------------------------\e[0m";
    echo -e "\e[1;36m ... installing prerequisite packages\e[0m";
    export DEBIAN_FRONTEND=noninteractive;
    # OS Version
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    CODENAME=$VERSION_CODENAME
    /usr/bin/logger "Operating System: $OS Version: $VER: $CODENAME" -t 'gse-21.4.4';
    echo -e "\e[1;36m ... Operating System: $OS Version: $VER: $CODENAME\e[0m";
    # Install prerequisites
    apt-get -qq update > /dev/null 2>&1;
    # Install some basic tools on a Debian net install
    /usr/bin/logger '..Install some basic tools missing if installed from Debian net-install' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... install tools missing if installed from Debian net-install\e[0m";
    apt-get -qq -y install --fix-policy;
    apt-get -qq -y install adduser wget whois build-essential devscripts git unzip apt-transport-https ca-certificates curl gnupg2 \
        software-properties-common dnsutils dirmngr --install-recommends  > /dev/null 2>&1;
    # Set locale
    locale-gen > /dev/null 2>&1;
    update-locale > /dev/null 2>&1;
    # For development
    #apt-get -qq -y install libcgreen1;
    # Install pre-requisites for openvas
    /usr/bin/logger '..Tools for Development' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... installing required development tools\e[0m";
    apt-get -qq -y install openssh-client gpgsm dpkg xmlstarlet libbsd-dev libjson-glib-dev gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev redis-server libunistring-dev libxml2-dev > /dev/null 2>&1;    # Install pre-requisites for gsad
    /usr/bin/logger '..Prerequisites for notus-scanner' -t 'gse-21.4.4';
    apt-get -qq -y install libpaho-mqtt-dev python3 python3-pip python3-setuptools python3-paho-mqtt python3-psutil python3-gnupg python3-venv;
    
    # Other pre-requisites for GSE
    if [ $VER -eq "11" ] 
        then
            /usr/bin/logger '..install_prerequisites_debian_11_bullseye' -t 'gse-21.4.4';
            echo -e "\e[1;36m ... installing prequisites Debian 11\e[0m";
            # Install pre-requisites for gvmd on bullseye (debian 11)
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;        
            echo -e "\e[1;36m ... other prerequisites for Greenbone Source Edition\e[0m";
            # Other pre-requisites for GSE - Bullseye / Debian 11
            /usr/bin/logger '....Other prerequisites for Greenbone Source Edition on Debian 11' -t 'gse-21.4.4';
            apt-get -qq -y install doxygen mosquitto gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc > /dev/null 2>&1;        
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy > /dev/null 2>&1;
        
    elif [ $CODENAME -eq "bookworm" ]
        then
            /usr/bin/logger '..install_prerequisites_debian_12_bookworm' -t 'gse-21.4.4';
            echo -e "\e[1;36m ... installing prequisites Debian 12 Bookworm\e[0m";
            # Install pre-requisites for gvmd on Bookworm (debian 12)
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;        
            echo -e "\e[1;36m ... other prerequisites for Greenbone Source Edition\e[0m";
            # Other pre-requisites for GSE - Bookworm / Debian 12
            /usr/bin/logger '....Other prerequisites for Greenbone Source Edition on Debian 12' -t 'gse-21.4.4';
            apt-get -qq -y install doxygen mosquitto gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc > /dev/null 2>&1;        
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy > /dev/null 2>&1        
        else
            /usr/bin/logger "Operating System $OS Version $VER" -t 'gse-21.4.4';
            # Untested but let's try like it is buster (debian 10)
            echo -e "\e[1;36m ... installing prequisites Debian ??\e[0m";
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            echo -e "\e[1;36m ... other prerequisites for Greenbone Source Edition\e[0m";
            /usr/bin/logger '....Other prerequisites for Greenbone Source Edition on unknown OS' -t 'gse-21.4.4';
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy > /dev/null 2>&1;
        fi

    # Install other preferences and cleanup APT
    echo -e "\e[1;36m ... installing preferred tools and clean up apt\e[0m";
    /usr/bin/logger '....Install preferences on Debian' -t 'gse-21.4.4';
    apt-get -qq -y install bash-completion > /dev/null 2>&1;
    # Install SUDO
    apt-get -qq -y install sudo;
    # A little apt cleanup
    apt-get -qq update > /dev/null 2>&1;
    apt-get -qq -y full-upgrade > /dev/null 2>&1;
    apt-get -qq -y autoremove --purge > /dev/null 2>&1;
    apt-get -qq -y autoclean > /dev/null 2>&1;
    apt-get -qq -y clean > /dev/null 2>&1;    
    # Python pip packages
    echo -e "\e[1;36m ... installing python and python-pip\e[0m";
    apt-get -qq -y install python3-pip > /dev/null 2>&1;
    python3 -m pip install --upgrade pip > /dev/null 2>&1
    # Prepare directories for scan data
    echo -e "\e[1;36m ... preparing directories for scan feed data\e[0m";
    mkdir -p /var/lib/gvm/private/CA > /dev/null 2>&1;
    mkdir -p /var/lib/gvm/CA > /dev/null 2>&1;
    mkdir -p /var/lib/openvas/plugins > /dev/null 2>&1;
    # logging
    mkdir -p /var/log/gvm/ > /dev/null 2>&1;
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    timedatectl set-timezone UTC;
    echo -e "\e[1;32m - install_prerequisites() finished\e[0m";
    /usr/bin/logger 'install_prerequisites finished' -t 'gse-21.4.4';
}

prepare_nix() {
    echo -e "\e[1;32m - prepare_nix()\e[0m";
    echo -e "\e[1;32mCreating Users, configuring sudoers, and setting locale\e[0m";
    # set desired locale
    echo -e "\e[1;36m ... configuring locale\e[0m";
    localectl set-locale en_US.UTF-8 > /dev/null 2>&1;
    # Create gvm user
    echo -e "\e[1;36m ... creating gvm user\e[0m";
    /usr/sbin/useradd --system --create-home --home-dir /opt/gvm/ -c "gvm User" --shell /bin/bash gvm > /dev/null 2>&1;
    mkdir /opt/gvm > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1;
    # Update the PATH environment variable
    echo "PATH=\$PATH:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/gvmpy/bin" > /etc/profile.d/gvm.sh;
    # Add GVM library path to /etc/ld.so.conf.d
    echo -e "\e[1;36m ... configuring ld for greenbone libraries\e[0m";
    cat << __EOF__ > /etc/ld.so.conf.d/greenbone.conf;
# Greenbone libraries
/opt/gvm/lib
/opt/gvm/include
__EOF__
    echo -e "\e[1;36m ... creating sudoers.d/greenbone file\e[0m";
    cat << __EOF__ > /etc/sudoers.d/gvm
gvm     ALL = NOPASSWD: /opt/gvm/sbin/openvas

Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gvm/sbin"
__EOF__
    echo -e "\e[1;36m ... configuring tmpfiles.d for greenbone run files\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/greenbone.conf
d /run/gvm 1775 gvm gvm
d /run/gvm/gse 1775 root
d /run/ospd 1775 gvm gvm
d /run/ospd/gse 1775 root
d /var/log/gvm 1775 gvm gvm
__EOF__
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m ... starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;32m - prepare_nix() finished\e[0m";
}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'gse-22.4.0';
    echo -e "\e[1;32m - prepare_source()\e[0m";
    echo -e "\e[1;32mPreparing GSE Source files\e[0m";
    echo -e "\e[1;36m ... preparing directories\e[0m";
    mkdir -p /opt/gvm/src/greenbone > /dev/null 2>&1
    chown -R gvm:gvm /opt/gvm/src/greenbone > /dev/null 2>&1;
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
    /usr/bin/logger '..gse components needed' -t 'gse-22.4.0';
    echo -e "\e[1;36m ... downloading released packages for Greenbone Source Edition\e[0m";
    /usr/bin/logger '..gvm-libs' -t 'gse-22.4.2';
    wget -O gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v22.6.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..ospd-openvas' -t 'gse-22.4.2';
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v22.5.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-scanner' -t 'gse-22.4.2';
    wget -O openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v22.7.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm daemon' -t 'gse-22.4.2';
    wget -O gvmd.tar.gz https://github.com/greenbone/gvmd/archive/refs/tags/v22.4.2.tar.gz> /dev/null 2>&1;
    /usr/bin/logger '..gsa daemon (gsad)' -t 'gse-22.4.2';
    wget -O gsad.tar.gz https://github.com/greenbone/gsad/archive/refs/tags/v22.4.1.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gsa webserver' -t 'gse-22.4.2';
    wget -O gsa.tar.gz https://github.com/greenbone/gsa/archive/refs/tags/v22.4.1.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-smb' -t 'gse-22.4.2';
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v22.5.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..python-gvm' -t 'gse-22.4.2';
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v23.4.2.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm-tools' -t 'gse-23.4.2';
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v23.4.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..pg-gvm' -t 'gse-22.4.2';
    wget -O pg-gvm.tar.gz https://github.com/greenbone/pg-gvm/archive/refs/tags/v22.4.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..notus-scanner' -t 'gse-22.4.2';
    wget -O notus.tar.gz https://github.com/greenbone/notus-scanner/archive/refs/tags/v22.5.0.tar.gz > /dev/null 2>&1;
  
    # open and extract the tarballs
    echo -e "\e[1;36m ... open and extract tarballs\e[0m";
    /usr/bin/logger '..open and extract the tarballs' -t 'gse-22.4.0';
    find *.gz | xargs -n1 tar zxvfp > /dev/null 2>&1;
    sync;

    # Naming of directories w/o version
    /usr/bin/logger '..rename directories' -t 'gse-22.4.0';    
    echo -e "\e[1;36m ... renaming package directories\e[0m";
    mv /opt/gvm/src/greenbone/gvm-libs-22.6.0 /opt/gvm/src/greenbone/gvm-libs > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/ospd-openvas-22.5.0 /opt/gvm/src/greenbone/ospd-openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-scanner-22.7.0 /opt/gvm/src/greenbone/openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvmd-22.4.2 /opt/gvm/src/greenbone/gvmd > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gsa-22.4.1 /opt/gvm/src/greenbone/gsa > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gsad-22.4.1 /opt/gvm/src/greenbone/gsad > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-smb-22.5.0 /opt/gvm/src/greenbone/openvas-smb > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/python-gvm-23.4.2 /opt/gvm/src/greenbone/python-gvm > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvm-tools-23.4.0 /opt/gvm/src/greenbone/gvm-tools > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/pg-gvm-22.4.0 /opt/gvm/src/greenbone/pg-gvm > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/notus-scanner-22.5.0 /opt/gvm/src/greenbone/notus > /dev/null 2>&1;

    sync;
    echo -e "\e[1;36m ... configuring permissions\e[0m";
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;32m - prepare_source() finished\e[0m";
    /usr/bin/logger 'prepare_source finished' -t 'gse-22.4.0';
}

install_poetry() {
    /usr/bin/logger 'install_poetry' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_poetry()\e[0m";
    export POETRY_HOME=/usr/poetry;
    # https://python-poetry.org/docs/
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 - > /dev/null 2>&1;
    echo -e "\e[1;32m - install_poetry() finished\e[0m";
    /usr/bin/logger 'install_poetry finished' -t 'gse-21.4.4';
}

install_gvm_libs() {
    /usr/bin/logger 'install_gvmlibs' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_gvmlibs()\e[0m";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd gvm-libs/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    echo -e "\e[1;36m ... cmake Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1
    /usr/bin/logger '..make Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... make Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    make > /dev/null 2>&1;
    /usr/bin/logger '..make Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gse-21.4.4';
    #make doc-full > /dev/null 2>&1;
    /usr/bin/logger '..make Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... make install Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... load Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    ldconfig > /dev/null 2>&1;
    /usr/bin/logger 'install_gvmlibs finished' -t 'gse-21.4.4';
}

install_python_gvm() {
    /usr/bin/logger 'install_python_gvm' -t 'gse-21.4.4';
    # Installing from repo
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install python-gvm';
#    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
#    cd python-gvm/ > /dev/null 2>&1;
#    /usr/bin/python3 -m pip install . > /dev/null 2>&1;
    #/usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_python_gvm finished' -t 'gse-21.4.4';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_openvas_smb()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #config and build openvas-smb
    cd openvas-smb > /dev/null 2>&1;
    echo -e "\e[1;36m ... cmake OpenVAS SMB\e[0m";
    /usr/bin/logger '..cmake OpenVAS SMB' -t 'gse-21.4.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make OpenVAS SMB' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... make OpenVAS SMB\e[0m";
    make > /dev/null 2>&1;                
    /usr/bin/logger '..make install OpenVAS SMB' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... make install OpenVAS SMB\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... load libraries for OpenVAS SMB\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32m - install_openvas_smb() finished\e[0m";
    /usr/bin/logger 'install_openvas_smb finished' -t 'gse-21.4.4';
}


install_ospd() {
    /usr/bin/logger 'install_ospd' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_ospd()\e[0m";
    # Install from repo
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install ospd';
    # Uncomment below for install from source
#    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
#    cd ospd > /dev/null 2>&1;
#    echo -e "\e[1;36m ... installing ospd\e[0m";
#    /usr/bin/python3 -m pip install . > /dev/null 2>&1 
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32m - install_ospd() finished\e[0m";
    /usr/bin/logger 'install_ospd finished' -t 'gse-21.4.4';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_ospd_openvas()\e[0m";
    # Install from repo
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install ospd-openvas';
    #cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    # install from source
    #echo -e "\e[1;36m ... installing ospd-openvas\e[0m";
    #cd ospd-openvas > /dev/null 2>&1;
    #/usr/bin/python3 -m pip install . > /dev/null 2>&1 
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32m - install_ospd_openvas() finished\e[0m";
    /usr/bin/logger 'install_ospd_openvas finished' -t 'gse-21.4.4';
}

install_openvas() {
    /usr/bin/logger 'install_openvas' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_openvas()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    cd openvas > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    /usr/bin/logger '..cmake OpenVAS Scanner' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... cmake OpenVAS Scanner\e[0m";
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make OpenVAS Scanner' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... make OpenVAS Scanner\e[0m";
    # make it
    make > /dev/null 2>&1;
    # build more developer-oriented documentation
    #make doc-full > /dev/null 2>&1; 
    /usr/bin/logger '..make install OpenVAS Scanner' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... make install OpenVAS Scanner\e[0m";
    make install > /dev/null 2>&1;
    /usr/bin/logger '..Rebuild make cache, OpenVAS Scanner' -t 'gse-21.4.4';
    make rebuild_cache > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... load libraries for OpenVAS Scanner\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32m - install_openvas() finished\e[0m";
    /usr/bin/logger 'install_openvas finished' -t 'gse-21.4.4';
}

create_scan_user() {
    /usr/bin/logger 'create_scan_user' -t 'gse-21.4.4';
    echo -e "\e[1;32m - create_scan_user()\e[0m";
    cat << __EOF__ > /etc/sudoers.d/greenbone
greenbone     ALL=(ALL) NOPASSWD: ALL
__EOF__
    export greenbone_secret="$(< /dev/urandom tr -dc A-Za-z0-9_ | head -c 20)";
    echo -e "\e[1;36m ... creating user greenbone for temporary usage\e[0m";
    /usr/sbin/useradd --create-home -c "greenbone secondary user" --shell /bin/bash greenbone > /dev/null 2>&1
    echo -e "$greenbone_secret\n$greenbone_secret\n" | passwd greenbone > /dev/null 2>&1
    echo "User Greenbone for secondary $HOSTNAME created with password: $greenbone_secret" >> /var/lib/gvm/greenboneuser;
    /usr/bin/logger 'create_scan_user() finished' -t 'gse-21.4.4';
    echo -e "\e[1;32m - create_scan_user() finished\e[0m";
}

install_nmap() {
    /usr/bin/logger 'install_nmap' -t 'gse-21.4.4';
    cd /opt/gvm/src/greenbone;
    # Install NMAP
    apt-get -qq -y install ./nmap.deb --fix-missing > /dev/null 2>&1;
    sync;
    /usr/bin/logger 'install_nmap finished' -t 'gse-21.4.4';
}

install_greenbone_feed_sync() {
    /usr/bin/logger 'install_greenbone_feed_sync()' -t 'gse-22.4.0';
    echo -e "\e[1;32m - install_greenbone_feed_sync() \e[0m";
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install greenbone-feed-sync';
    /usr/bin/logger 'install_greenbone_feed_sync() finished' -t 'gse-22.4.0';
    echo -e "\e[1;32m - install_greenbone_feed_sync() finished\e[0m";
}

prepare_gvmpy() {
    /usr/bin/logger 'prepare_gvmpy' -t 'gse-22.4.0';
    echo -e "\e[1;32m - prepare_gvmpy() \e[0m";
    su gvm -c 'cd ~; python3 -m pip install --upgrade pip; python3 -m pip install --user virtualenv; python3 -m venv gvmpy' > /dev/null 2>&1;
    /usr/bin/logger 'prepare_gvmpy finished' -t 'gse-22.4.0';
    echo -e "\e[1;32m - prepare_gvmpy() finished\e[0m";
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gse-22.4.0';
    echo -e "\e[1;32m - prestage_scan_data() \e[0m";
    # copy scan data to prestage ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /root/ > /dev/null 2>&1;
    /usr/bin/logger '..opening and extracting TAR Ball' -t 'gse-22.4.0';
    echo -e "\e[1;36m ... opening and extracting TAR ball with prestaged feed data\e[0m";
    tar -xzf scandata.tar.gz > /dev/null 2>&1; 
    /usr/bin/logger '..copy feed data to /gvm/lib/gvm and openvas' -t 'gse-22.4.0';
    echo -e "\e[1;36m ... copying feed data to correct locations\e[0m";
    /usr/bin/rsync -aAXv /root/GVM/openvas/plugins/ /var/lib/openvas/plugins/
    #/bin/cp -r /root/GVM/openvas/plugins/* /var/lib/openvas/plugins/ > /dev/null 2>&1;
    /usr/bin/rsync -aAXv /root/GVM/notus/ /var/lib/notus/
    #/bin/cp -r /root/GVM/notus/* /var/lib/notus/ > /dev/null 2>&1;
    echo -e "\e[1;36m ... setting permissions\e[0m";
    echo -e "\e[1;32m - prestage_scan_data() finished\e[0m";
    /usr/bin/logger 'prestage_scan_data finished' -t 'gse-22.4.0';
}

update_feed_data() {
    /usr/bin/logger 'update_feed_data' -t 'gse-21.4.4';
    echo -e "\e[1;32m - update_feed_data() \e[0m";
    ## This relies on the configure_greenbone_updates script
    echo -e "\e[1;36m ... updating feed data\e[0m";
    echo -e "\e[1;36m ... this could take a while\e[0m";
    /opt/gvm/gvmpy/bin/greenbone-feed-sync --type nvt  --user gvm --group gvm > /dev/null 2>&1;
    echo -e "\e[1;32m - update_feed_data() finished\e[0m";
    /usr/bin/logger 'update_feed_data finished' -t 'gse-21.4.4';
}

install_gvm_tools() {
    /usr/bin/logger 'install_gvm_tools' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_gvm_tools() \e[0m";
 #   cd /opt/gvm/src/greenbone > /dev/null 2>&1
    # Install gvm-tools
 #   cd gvm-tools/ > /dev/null 2>&1;
 #   chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;36m ... installing GVM-tools\e[0m";
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install gvm-tools' > /dev/null 2>&1; 
#   python3 -m pip install . > /dev/null 2>&1;
 #   /usr/poetry/bin/poetry install > /dev/null 2>&1;
    echo -e "\e[1;32m - install_gvm_tools() finished\e[0m";
    /usr/bin/logger 'install_gvm_tools finished' -t 'gse-21.4.4';
}

install_impacket() {
    /usr/bin/logger 'install_impacket' -t 'gse-21.4.4';
    echo -e "\e[1;32m - install_impacket() \e[0m";
    # Install impacket
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install impacket' > /dev/null 2>&1;
    echo -e "\e[1;32m - install_impacket() finished\e[0m";
    /usr/bin/logger 'install_impacket finished' -t 'gse-21.4.4';
}

install_notus() {
    /usr/bin/logger 'install_notus' -t 'gse-22.4.0';
    echo -e "\e[1;32m - install_notus()\e[0m";
    mkdir -p /var/lib/notus/products;
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd notus/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1
    echo -e "\e[1;36m ... Install notus scanner Python pip module (notus-scanner) \e[0m";
    su gvm -c 'cd ~; source gvmpy/bin/activate; python3 -m pip install notus-scanner' > /dev/null 2>&1; 
    sync;
    echo -e "\e[1;32m - install_notus() finished\e[0m";
    /usr/bin/logger 'install_notus finished' -t 'gse-22.4.0';
}

prepare_gpg() {
    /usr/bin/logger 'prepare_gpg' -t 'gse-22.4.0';
    echo -e "\e[1;32m - prepare_gpg()\e[0m";
    echo -e "\e[1;36m ... Downloading and importing Greenbone Community Signing Key (PGP)\e[0m";
    /usr/bin/logger '..Downloading and importing Greenbone Community Signing Key (PGP)' -t 'gse-22.4.0';
    curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc;
    gpg --import /tmp/GBCommunitySigningKey.asc;
    echo -e "\e[1;36m ... Fully trust Greenbone Community Signing Key (PGP)\e[0m";
    /usr/bin/logger '..Fully trust Greenbone Community Signing Key (PGP)' -t 'gse-22.4.0';
    echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" > /tmp/ownertrust.txt;
    export GNUPGHOME=/tmp/openvas-gnupg;
    mkdir -p $GNUPGHOME;
    gpg --import /tmp/GBCommunitySigningKey.asc;
    gpg --import-ownertrust < /tmp/ownertrust.txt;
    export OPENVAS_GNUPG_HOME=/etc/openvas/gnupg;
    sudo mkdir -p $OPENVAS_GNUPG_HOME;
    sudo cp -r /tmp/openvas-gnupg/* $OPENVAS_GNUPG_HOME/;
    sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME;
    gpg --import-ownertrust < /tmp/ownertrust.txt;
    /usr/bin/logger 'prepare_gpg finished' -t 'gse-22.4.0';
    echo -e "\e[1;32m - prepare_gpg() finished\e[0m";
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gse-21.4.4';
    echo -e "\e[1;32m - configure_openvas() \e[0m";
    # Create openvas configuration file
    echo -e "\e[1;36m ... create OpenVAS configuration file\e[0m";
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
    echo -e "\e[1;36m ... creating ospd-openvas service\e[0m";
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
ExecStart=/opt/gvm/gvmpy/bin/ospd-openvas --port=9390 --bind-address=0.0.0.0 --pid-file=/run/gvm/ospd-openvas.pid --lock-file-dir=/run/gvm/ --key-file=/var/lib/gvm/private/CA/secondary-key.pem --cert-file=/var/lib/gvm/CA/secondary-cert.pem --ca-file=/var/lib/gvm/CA/cacert.pem --log-file=/var/log/gvm/ospd-openvas.log
# --log-level in ospd-openvas.conf can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
__EOF__

    ## Configure ospd
    # Directory for ospd-openvas configuration file
    echo -e "\e[1;36m ... create ospd-openvas configuration file\e[0m";
    mkdir -p /etc/ospd;
    cat << __EOF__ > /etc/ospd/ospd-openvas.conf
[OSPD - openvas]
log_level = INFO
socket_mode = 0o766
unix_socket = /run/ospd/ospd-openvas.sock
pid_file = /run/ospd/ospd-openvas.pid
; default = /run/ospd
lock_file_dir = /var/run/gvmd

; max_scans, is the number of scan/task to be started before start to queuing.
max_scans = 0

; The minimal available memory before the GSM starts to queue scans.
min_free_mem_scan_queue = 1500

; max_queued_scans is the maximum amount of queued scans before starting to reject the new task (will not be queued) and send an error message to gvmd
; This options are disabled with the value 0 (zero), all arriving tasks will be started without queuing.
max_queued_scans = 0
__EOF__

    # Create NOTUS Scanner service
    echo -e "\e[1;36m ... creating NOTUS scanner service\e[0m";
    cat << __EOF__ > /lib/systemd/system/notus-scanner.service
[Unit]
Description=Notus Scanner
Documentation=https://github.com/greenbone/notus-scanner
After=mosquitto.service
Wants=mosquitto.service
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
User=gvm
RuntimeDirectory=notus-scanner
RuntimeDirectoryMode=2775
PIDFile=/run/notus-scanner/notus-scanner.pid
ExecStart=/opt/gvm/gvmpy/bin/notus-scanner --products-directory /var/lib/notus/products --log-file /var/log/gvm/notus-scanner.log
SuccessExitStatus=SIGKILL
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
__EOF__

    echo "mqtt_server_uri = localhost:1883" | sudo tee -a /etc/openvas/openvas.conf
    sync;
    echo -e "\e[1;32m - configure_openvas() finished\e[0m";
    /usr/bin/logger 'configure_openvas finished' -t 'gse-21.4.4';
}

configure_greenbone_updates() {
    /usr/bin/logger 'configure_greenbone_updates' -t 'gse-21.4.4';
    echo -e "\e[1;32m - configure_greenbone_updates() \e[0m";
   # Configure daily GVM updates timer and service
    # Timer
    echo -e "\e[1;36m ... create gse-update timer\e[0m";
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
    echo -e "\e[1;36m ... create gse-update service\e[0m";
    cat << __EOF__ > /lib/systemd/system/gse-update.service
[Unit]
Description=gse updater
After=network.target networking.service
Documentation=man:gvmd(8)

[Service]
ExecStart=/opt/gvm/gvmpy/bin/greenbone-feed-sync --type nvt --user gvm --group gvm --openvas-lock-file /var/run/gvmd/feed-update.lock
TimeoutSec=300

[Install]
WantedBy=multi-user.target
__EOF__
    sync;
    chmod +x /opt/gvm/gse-updater/gse-updater.sh > /dev/null 2>&1;
    echo -e "\e[1;32m - configure_greenbone_updates() finished\e[0m";
    /usr/bin/logger 'configure_greenbone_updates finished' -t 'gse-21.4.4';
}   

start_services() {
    /usr/bin/logger 'start_services' -t 'gse-21.4.4';
    echo -e "\e[1;32m - start_services()\e[0m";
    # Load new/changed systemd-unitfiles
    echo -e "\e[1;36m ... reload new and changed systemd unit files\e[0m";
    systemctl daemon-reload > /dev/null 2>&1;
    # Restart Redis with new config
    echo -e "\e[1;36m ... restarting redis service\e[0m";
    systemctl restart redis > /dev/null 2>&1;
    # Enable GSE units
    echo -e "\e[1;36m ... enabling ospd-openvas service\e[0m";
    systemctl enable ospd-openvas.service > /dev/null 2>&1;
    # Start ospd-openvas
    echo -e "\e[1;36m ... restarting ospd-openvas service\e[0m";
    systemctl restart ospd-openvas.service > /dev/null 2>&1;
    echo -e "\e[1;36m ... enabling notus-scanner service\e[0m";
    systemctl enable notus-scanner.service > /dev/null 2>&1;
    # Start notus-scanner
    echo -e "\e[1;36m ... restarting ospd-openvas service\e[0m";
    systemctl restart notus-scanner.service > /dev/null 2>&1;
    # Enable gse-update timer and service
    echo -e "\e[1;36m ... enabling gse-update timer and service\e[0m";
    systemctl enable gse-update.timer > /dev/null 2>&1;
    systemctl enable gse-update.service > /dev/null 2>&1;
    # Will start after next reboot - may disturb the initial update
    echo -e "\e[1;36m ... starting gse-update timer\e[0m";
    systemctl start gse-update.timer > /dev/null 2>&1;
    # Check status of critical service ospd-openvas.service and gse-update
    echo -e
    echo 'Checking core daemons.....';
    if systemctl is-active --quiet notus-scanner.service;
    then
        echo -e "\e[1;32mnotus-scanner.service started successfully\e[0m";
        /usr/bin/logger 'notus-scanner.service started successfully' -t 'gse-22.4.0';
    else
        echo -e "\e[1;31mnotus-scanner.service FAILED!";
        /usr/bin/logger 'notus-scanner.service FAILED!\e[0m' -t 'gse-22.4.0';
    fi

    if systemctl is-active --quiet gse-update.timer;
    then
        echo 'gse-update.timer started successfully';
        /usr/bin/logger 'gse-update.timer started successfully' -t 'gse-21.4.4';
    else
        echo 'gse-update.timer FAILED! Updates will not be automated';
        /usr/bin/logger 'gse-update.timer FAILED! Updates will not be automated' -t 'gse-21.4.4';
    fi
    echo -e "\e[1;32m ... start:services() finished\e[0m";
    /usr/bin/logger 'start_services finished' -t 'gse-21.4.4';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gse-21.4.4';
    echo -e "\e[1;32m - configure_redis()\e[0m";
    echo -e "\e[1;36m ... creating tmpfiles.d configuration for redis\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
__EOF__
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m ... starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;36m ... creating redis configuration for Greenbone Source Edition\e[0m";
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
    sysctl -w vm.overcommit_memory=1 > /dev/null 2>&1;
    sysctl -w net.core.somaxconn=1024 > /dev/null 2>&1;
    echo "vm.overcommit_memory=1" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=1024" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    cat << __EOF__  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by redis
GRUB_CMDLINE_LINUX_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT transparent_hugepage=never"
__EOF__
    echo -e "\e[1;36m ... updating grub\e[0m";
    update-grub > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32m - configure_redis() finished\e[0m";
    /usr/bin/logger 'configure_redis finished' -t 'gse-21.4.4';
}

configure_permissions() {
    /usr/bin/logger 'configure_permissions' -t 'gse-21.4.4';
    echo -e "\e[1;32m - configure_permissions()\e[0m";
    /usr/bin/logger '..Setting correct ownership of files for user gvm' -t 'gse-21.4.4';
    echo -e "\e[1;36m ... configuring permissions for GSE\e[0m";
    # Once more to ensure that GVM owns all files in /opt/gvm
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1;
    # GSE log files
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    # Openvas feed
    chown -R gvm:gvm /var/lib/openvas > /dev/null 2>&1;
    # GVM Feed
    chown -R gvm:gvm /var/lib/gvm > /dev/null 2>&1;
    # NOTUS Feed
    chown -R gvm:gvm /var/lib/notus > /dev/null 2>&1;
    # OSPD Configuration file
    chown -R gvm:gvm /etc/ospd/ > /dev/null 2>&1;
    echo -e "\e[1;32m - configure_permissions() finished\e[0m";
    /usr/bin/logger 'configure_permissions finished' -t 'gse-21.4.4';
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'gse-21.4.4';
    mkdir /opt/gvm/scripts > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/scripts/ > /dev/null 2>&1;
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
    /usr/bin/logger 'create_gvm_python_script finished' -t 'gse-21.4.4';
}

update_openvas_feed () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    echo -e "\e[1;32m - update_openvas_feed()\e[0m";
    echo -e "\e[1;36m ... updating NVT information on $HOSTNAME\e[0m";
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info' > /dev/null 2>&1;
    echo -e "\e[1;32m - update_openvas_feed() finished\e[0m";
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gse';
}

install_openvas_from_github() {
    cd /opt/gvm/src/greenbone/
    rm -rf openvas
    git clone https://github.com/greenbone/openvas-scanner.git
    mv ./openvas-scanner ./openvas;
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32m - Secondary Server Install main()\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36m ... Starting installation of secondary Greenbone Source Edition Server version 21.4.4\e[0m"
    echo -e "\e[1;36m ... $HOSTNAME will run ospd-openvas and openvas-scanner only, managed from a primary\e[0m"
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
   # Shared components
    install_prerequisites;
    prepare_nix;
    prepare_source;
    prepare_gvmpy;
    
    # Installation of specific components
    # Only install poetry when testing
    #install_poetry;
    install_gvm_libs;
    install_openvas_smb;
    #install_openvas_from_github;
    install_openvas;
    install_ospd_openvas;
    install_notus;
    install_greenbone_feed_sync;
    prepare_gpg;
 
    # Configuration of installed components
    configure_openvas;
    configure_redis;
    # Prestage only works on the specific Vagrant lab where a scan-data tar-ball is copied to the Host. 
    # Update scan-data only from greenbone when used everywhere else 
    prestage_scan_data;
    configure_greenbone_updates;
    configure_permissions;
    update_feed_data;
    update_openvas_feed;
    start_services;
    create_scan_user;
    echo -e;
    echo -e "\e[1;32m****************************************************************************************************\e[0m";
    echo -e "\e[1;36m  Run add-secondary-2-primary on the primary server to configure this secondary\e[0m";
    echo -e "\e[1;36m  You will need hostname: \e[1;33m$HOSTNAME\e[0m and password: \e[1;33m$greenbone_secret\e[0m";
    echo -e "\e[1;32m****************************************************************************************************\e[0m";
    echo -e;
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of Openvas feed data into Redis, then reboot' -t 'gse-21.4.4';
    echo -e "\e[1;32m - Secondary Server Install main() finished\e[0m";
}

main;

exit 0;
