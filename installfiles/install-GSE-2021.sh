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
#               2021-10-25 Correct ospd-openvas.sock path                   #
#               2021-12-17 Create secondary cert w hostname not wildcard    #
#               2022-01-08 Improved console output during install (2.10)    #
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
    echo -e "\e[1;32m - install_prerequisites()\e[0m";
    echo -e "\e[1;32m--------------------------------------------\e[0m";
    echo -e "\e[1;36m ... installing perequisite packages\e[0m";
    export DEBIAN_FRONTEND=noninteractive;
    # OS Version
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    /usr/bin/logger "Operating System $OS Version $VER" -t 'gse-21.4';
    echo -e "\e[1;36m ... Operating System $OS Version $VER\e[0m";
    # Install prerequisites
    # Prepare package sources for NODEJS 16.x
    # GSAD works with node 16.x but NOT 17.x
    echo -e "\e[1;36m ... Installing node 14.x\e[0m";
    export VERSION=node_14.x
    export KEYRING=/usr/share/keyrings/nodesource.gpg
    export DISTRIBUTION="$(lsb_release -s -c)"
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee "$KEYRING"  > /dev/null 2>&1
    gpg --no-default-keyring --keyring "$KEYRING" --list-keys > /dev/null 2>&1
    echo "deb [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRIBUTION main" | sudo tee /etc/apt/sources.list.d/nodesource.list > /dev/null 2>&1
    echo "deb-src [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRIBUTION main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list > /dev/null 2>&1
    apt-get -qq update > /dev/null 2>&1;
    # Install some basic tools on a Debian net install
    echo -e "\e[1;36m ... install tools not available if installed from Debian net-install\e[0m";
    /usr/bin/logger '..install some basic tools not available if installed from Debian net install' -t 'gse-21.4';
    echo -e "\e[1;36m ... fix-policy for apt\e[0m";
    apt-get -qq -y install --fix-policy > /dev/null 2>&1;
    echo -e "\e[1;36m ... installing required packages\e[0m";
    apt-get -qq -y install adduser wget whois build-essential devscripts git unzip apt-transport-https ca-certificates \
        curl gnupg2 software-properties-common dnsutils dirmngr --install-recommends  > /dev/null 2>&1;

    # Set locale
    echo -e "\e[1;36m ... setting locale\e[0m";
    locale-gen > /dev/null 2>&1;
    update-locale > /dev/null 2>&1;
    # For development
    #apt-get -qq -y install libcgreen1;
    # Install pre-requisites for 
    # libunistring is a new requirement from oct-13 updates
    /usr/bin/logger '..Tools for Development' -t 'gse-21.4';
    echo -e "\e[1;36m ... installing required development tools\e[0m";
    apt-get -qq -y install gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev redis-server libunistring-dev libxml2-dev > /dev/null 2>&1;
    # Install pre-requisites for gsad
    /usr/bin/logger '..Prerequisites for Greenbone Security Assistant' -t 'gse-21.4';
    echo -e "\e[1;36m ... prequisites for Greenbone Security Assistant\e[0m";
    apt-get -qq -y install libmicrohttpd-dev clang > /dev/null 2>&1;
    
    # Other pre-requisites for GSE
    echo -e "\e[1;36m ... other prerequisites for Greenbone Source Edition\e[0m";

    if [ $VER -eq "11" ] 
        then
            /usr/bin/logger '..install_prerequisites_debian_11_bullseye' -t 'gse-21.4';
            echo -e "\e[1;36m ... install_prerequisites_debian_11_bullseye\e[0m";
            # Install pre-requisites for gvmd on bullseye (debian 11)
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all \
                postgresql-server-dev-13 pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;        
            
            # Other pre-requisites for GSE - Bullseye / Debian 11
            /usr/bin/logger '....Other prerequisites for Greenbone Source Edition on Debian 11' -t 'gse-21.4';
            echo -e "\e[1;36m ... installing prequisites for Greenbone Source Edition\e[0m";
             apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy > /dev/null 2>&1;
            echo -e "\e[1;36m ... installing yarn\e[0m";
            npm install -g yarn --force > /dev/null 2>&1;
    elif [ $VER -eq "10" ]
        then
            /usr/bin/logger '..install_prerequisites_debian_10_buster' -t 'gse-21.4';
            echo -e "\e[1;36m ... install_prerequisites_debian_10_buster\e[0m";
            # Install pre-requisites for gvmd on buster (debian 10)
            echo -e "\e[1;36m ... installing prequisites for Greenbone Vulnerability Manager\e[0m";
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all \
                postgresql-server-dev-11 pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            /usr/bin/logger '....Other prerequisites for Greenbone Source Edition on Debian 10' -t 'gse-21.4';
            echo -e "\e[1;36m ... installing prequisites for Greenbone Source Edition\e[0m";
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy > /dev/null 2>&1;
            echo -e "\e[1;36m ... installing yarn\e[0m";
            npm install -g yarn --force > /dev/null 2>&1;
        else
            /usr/bin/logger '..install_prerequisites_debian_Untested' -t 'gse-21.4';
            echo -e "\e[1;36m ... installing prequisites for unsupported Debian version\e[0m";
            echo -e "\e[1;36m ... installing prequisites for gvmd\e[0m";
            # Untested but let's try like it is buster (debian 10)
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all \
                postgresql-server-dev-11 pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;
            
            # Other pre-requisites for GSE - Buster / Debian 10
            echo -e "\e[1;36m ... installing prequisites for Greenbone Source Edition\e[0m";
            /usr/bin/logger '....Other prerequisites for Greenbone Source Edition on unknown OS' -t 'gse-21.4';
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                xml-twig-tools python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python-impacket python-scapy > /dev/null 2>&1;
            echo -e "\e[1;36m ... installing yarn\e[0m";
            npm install -g yarn --force > /dev/null 2>&1;
        fi

    # Required for PDF report generation
    /usr/bin/logger '....Prerequisites for PDF report generation' -t 'gse-21.4';
    echo -e "\e[1;36m ... installing texlive required for PDF report generation\e[0m";
    echo -e "\e[1;36m ... please be patient, this will take a few minutes\e[0m";
    apt-get -qq -y install texlive-full texlive-fonts-recommended > /dev/null 2>&1;
    # Install other preferences and clean up APT
    /usr/bin/logger '....Install some preferences on Debian and clean up apt' -t 'gse-21.4';
    echo -e "\e[1;36m ... installing some preferences on Debian\e[0m";
    apt-get -qq -y install bash-completion > /dev/null 2>&1;
    # Install SUDO
    apt-get -qq -y install sudo > /dev/null 2>&1;
    # A little apt 
    echo -e "\e[1;36m ... cleaning up apt\e[0m";
    apt-get -qq -y install --fix-missing > /dev/null 2>&1;
    apt-get -qq update > /dev/null 2>&1;
    apt-get -qq -y full-upgrade > /dev/null 2>&1;
    apt-get -qq -y autoremove --purge > /dev/null 2>&1;
    apt-get -qq -y autoclean > /dev/null 2>&1;
    apt-get -qq -y clean > /dev/null 2>&1;
    # Python pip packages
    echo -e "\e[1;36m ... installing python and python-pip\e[0m";
    apt-get -qq -y install python3-pip > /dev/null 2>&1;
    python3 -m pip install --upgrade pip > /dev/null 2>&1
    # Prepare directories for scan feed data
    echo -e "\e[1;36m ... preparing directories for scan feed data\e[0m";
    mkdir -p /var/lib/gvm/private/CA > /dev/null 2>&1;
    mkdir -p /var/lib/gvm/CA > /dev/null 2>&1;
    mkdir -p /var/lib/openvas/plugins > /dev/null 2>&1;
    # logging
    echo -e "\e[1;36m ... preparing directories for logs\e[0m";
    mkdir -p /var/log/gvm/ > /dev/null 2>&1;
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    echo -e "\e[1;32m - install_prerequisites() finished\e[0m";
    /usr/bin/logger 'install_prerequisites finished' -t 'gse-21.4';
}


prepare_nix() {
    /usr/bin/logger 'prepare_nix()' -t 'gse-21.4';
    echo -e "\e[1;32m - prepare_nix()\e[0m";
    echo -e "\e[1;32mCreating Users, configuring sudoers, and setting locale\e[0m";
    # set desired locale
    echo -e "\e[1;36m ... configuring locale\e[0m";
    localectl set-locale en_US.UTF-8 > /dev/null 2>&1;
    # Create gvm user
    echo -e "\e[1;36m ... creating Greenbone Vulnerability Manager linux user gvm\e[0m";
    /usr/sbin/useradd --system --create-home --home-dir /opt/gvm/ -c "gvm User" --groups sudo --shell /bin/bash gvm > /dev/null 2>&1;
    mkdir /opt/gvm > /dev/null 2>&1;
    chown gvm:gvm /opt/gvm;
    # Update the PATH environment variable
    echo "PATH=\$PATH:/opt/gvm/bin:/opt/gvm/sbin" > /etc/profile.d/gvm.sh;
    # Add GVM library path to /etc/ld.so.conf.d

    echo -e "\e[1;36m ... configuring ld for greenbone libraries\e[0m";
    sh -c 'cat << EOF > /etc/ld.so.conf.d/greenbone.conf;
# Greenbone libraries
/opt/gvm/lib
/opt/gvm/include
EOF'

    echo -e "\e[1;36m ... creating sudoers.d/greenbone file\e[0m";
# sudoers.d to run openvas as root
    sh -c 'cat << EOF > /etc/sudoers.d/greenbone
gvm     ALL = NOPASSWD: /opt/gvm/sbin/gsad, /opt/gvm/sbin/gvmd, /opt/gvm/sbin/openvas

Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gvm/sbin"
EOF'
    # It appears that GVMD sometimes delete /run/gvm so added a subfolder (/gse) to prevent this
    echo -e "\e[1;36m ... configuring tmpfiles.d for greenbone run files\e[0m";
    sh -c 'cat << EOF > /etc/tmpfiles.d/greenbone.conf
d /run/gvm 1775 gvm gvm
d /run/gvm/gse 1775 root root
d /run/ospd 1775 gvm gvm
d /run/ospd/gse 1775 root root
EOF'
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m ... starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;32m - prepare_nix() finished\e[0m";
    /usr/bin/logger 'prepare_nix() finished' -t 'gse-21.4';

}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'gse-21.4';
    echo -e "\e[1;32m - prepare_source()\e[0m";
    echo -e "\e[1;32mPreparing GSE Source files\e[0m";
    echo -e "\e[1;36m ... preparing directories\e[0m";
    mkdir -p /opt/gvm/src/greenbone > /dev/null 2>&1
    chown -R gvm:gvm /opt/gvm/src/greenbone > /dev/null 2>&1;
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
    /usr/bin/logger '..gvm libraries' -t 'gse-21.4';
    echo -e "\e[1;36m ... downloading released packages for GSE\e[0m";
    wget -O gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v21.4.3.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..ospd-openvas' -t 'gse-21.4';
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v21.4.3.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-scanner' -t 'gse-21.4';
    wget -O openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v21.4.3.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm daemon' -t 'gse-21.4';
    wget -O gvmd.tar.gz https://github.com/greenbone/gvmd/archive/refs/tags/v21.4.4.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gsa daemon' -t 'gse-21.4';
    wget -O gsa.tar.gz https://github.com/greenbone/gsa/archive/refs/tags/v21.4.3.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-smb' -t 'gse-21.4';
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v21.4.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..ospd' -t 'gse-21.4';
    wget -O ospd.tar.gz https://github.com/greenbone/ospd/archive/refs/tags/v21.4.4.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..python-gvm' -t 'gse-21.4';
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v21.11.0.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm-tools' -t 'gse-21.4';
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v21.10.0.tar.gz > /dev/null 2>&1;
  
    # open and extract the tarballs
    echo -e "\e[1;36m ... open and extract tarballs\e[0m";
    /usr/bin/logger '..open and extract the tarballs' -t 'gse-21.4';
    find *.gz | xargs -n1 tar zxvfp > /dev/null 2>&1;
    sync;

    # Naming of directories w/o version
    /usr/bin/logger '..rename directories' -t 'gse-21.4';    
    echo -e "\e[1;36m ... renaming package directories\e[0m";
    mv /opt/gvm/src/greenbone/gvm-libs-21.4.3 /opt/gvm/src/greenbone/gvm-libs > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/ospd-openvas-21.4.3 /opt/gvm/src/greenbone/ospd-openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-scanner-21.4.3 /opt/gvm/src/greenbone/openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvmd-21.4.4 /opt/gvm/src/greenbone/gvmd > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gsa-21.4.3 /opt/gvm/src/greenbone/gsa > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-smb-21.4.0 /opt/gvm/src/greenbone/openvas-smb > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/ospd-21.4.4 /opt/gvm/src/greenbone/ospd > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/python-gvm-21.11.0 /opt/gvm/src/greenbone/python-gvm > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvm-tools-21.10.0 /opt/gvm/src/greenbone/gvm-tools > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... configuring permissions\e[0m";
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;32m - prepare_source() finished\e[0m";
    /usr/bin/logger 'prepare_source finished' -t 'gse-21.4';
}

prepare_source_latest() {    
    /usr/bin/logger 'prepare_source_latest' -t 'gse-21.4';
    echo -e "\e[1;32m - prepare_source_latest()\e[0m";
    echo -e "\e[1;32mPreparing GSE Source for latest versions\e[0m";
    mkdir -p /opt/gvm/src/greenbone > /dev/null 2>&1
    chown -R gvm:gvm /opt/gvm/src/greenbone > /dev/null 2>&1;
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    ## If you want to experiment with the latest builds
    ## Warning: It WILL likely break, so don't :)
    git clone https://github.com/greenbone/gvmd.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/gsa.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/openvas.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/gvm-libs.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/openvas-smb.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/ospd-openvas.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/ospd.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/python-gvm.git > /dev/null 2>&1;
    git clone https://github.com/greenbone/gvm-tools.git > /dev/null 2>&1;
    sync;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;32m - prepare_source_latest() finished\e[0m";
    /usr/bin/logger 'prepare_source_latest EXPERIMENTAL finished' -t 'gse-21.4';
}

install_poetry() {
    /usr/bin/logger 'install_poetry' -t 'gse-21.4';
    echo -e "\e[1;32m - install_poetry()\e[0m";
    export POETRY_HOME=/usr/poetry;
    # https://python-poetry.org/docs/
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 - > /dev/null 2>&1;
    echo -e "\e[1;32m - install_poetry() finished\e[0m";
    /usr/bin/logger 'install_poetry finished' -t 'gse-21.4';
}

install_gvm_libs() {
    /usr/bin/logger 'install_gvmlibs' -t 'gse-21.4';
    echo -e "\e[1;32m - install_gvmlibs()\e[0m";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd gvm-libs/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    echo -e "\e[1;36m ... cmake Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1
    /usr/bin/logger '..make Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gse-21.4';
    echo -e "\e[1;36m ... make Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    make > /dev/null 2>&1;
    #/usr/bin/logger '..make gvm libraries Documentation' -t 'gse-21.4';
    #make doc-full;
    /usr/bin/logger '..make install Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gse-21.4';
    echo -e "\e[1;36m ... make install gvm libraries\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... load Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32m - install_gvmlibs() finished\e[0m";
    /usr/bin/logger 'install_gvmlibs finished' -t 'gse-21.4';
}

install_python_gvm() {
    /usr/bin/logger 'install_python_gvm' -t 'gse-21.4';
    echo -e "\e[1;32m - install_python_gvm()\e[0m";
    # Installing from repo
    echo -e "\e[1;36m ... installing python-gvm\e[0m";
    #/usr/bin/python3 -m pip install python-gvm;
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd python-gvm/ > /dev/null 2>&1;
    /usr/bin/python3 -m pip install . > /dev/null 2>&1;
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32m - install_python_gvm() finished\e[0m";
    /usr/bin/logger 'install_python_gvm finished' -t 'gse-21.4';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'gse-21.4';
    echo -e "\e[1;32m - install_openvas_smb()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #config and build openvas-smb
    cd openvas-smb > /dev/null 2>&1;
    echo -e "\e[1;36m ... cmake OpenVAS SMB\e[0m";
    /usr/bin/logger '..cmake OpenVAS SMB' -t 'gse-21.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make OpenVAS SMB' -t 'gse-21.4';
    echo -e "\e[1;36m ... make OpenVAS SMB\e[0m";
    make > /dev/null 2>&1;                
    /usr/bin/logger '..make install OpenVAS SMB' -t 'gse-21.4';
    echo -e "\e[1;36m ... make install OpenVAS SMB\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... load libraries for OpenVAS SMB\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32m - install_openvas_smb() finished\e[0m";
    /usr/bin/logger 'install_openvas_smb finished' -t 'gse-21.4';
}

install_ospd() {
    /usr/bin/logger 'install_ospd' -t 'gse-21.4';
    echo -e "\e[1;32m - install_ospd()\e[0m";
    # Install from repo
    #/usr/bin/python3 -m pip install ospd;
    # Uncomment below for install from source
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    cd ospd > /dev/null 2>&1;
    echo -e "\e[1;36m ... installing ospd\e[0m";
    /usr/bin/python3 -m pip install . > /dev/null 2>&1 
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32m - install_ospd() finished\e[0m";
    /usr/bin/logger 'install_ospd finished' -t 'gse-21.4';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'gse-21.4';
    echo -e "\e[1;32m - install_ospd_openvas()\e[0m";
    # Install from repo
    #/usr/bin/python3 -m pip install ospd-openvas
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    # install from source
    echo -e "\e[1;36m ... installing ospd-openvas\e[0m";
    cd ospd-openvas > /dev/null 2>&1;
    /usr/bin/python3 -m pip install . > /dev/null 2>&1 
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32m - install_ospd_openvas() finished\e[0m";
    /usr/bin/logger 'install_ospd_openvas finished' -t 'gse-21.4';
}

install_openvas() {
    /usr/bin/logger 'install_openvas' -t 'gse-21.4';
    echo -e "\e[1;32m - install_openvas()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    cd openvas > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    /usr/bin/logger '..cmake OpenVAS Scanner' -t 'gse-21.4';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    echo -e "\e[1;36m ... cmake OpenVAS Scanner\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make OpenVAS Scanner' -t 'gse-21.4';
    echo -e "\e[1;36m ... make OpenVAS Scanner\e[0m";
    # make it
    make > /dev/null 2>&1;
    # build more developer-oriented documentation
    #make doc-full > /dev/null 2>&1; 
    /usr/bin/logger '..make install OpenVAS Scanner' -t 'gse-21.4';
    echo -e "\e[1;36m ... make install openvas scanner\e[0m";
    make install > /dev/null 2>&1;
    /usr/bin/logger '..Rebuild make cache, OpenVAS Scanner' -t 'gse-21.4';
    make rebuild_cache > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m ... load libraries for OpenVAS Scanner\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32m - install_openvas() finished\e[0m";
    /usr/bin/logger 'install_openvas finished' -t 'gse-21.4';
}

install_gvm() {
    /usr/bin/logger 'install_gvm' -t 'gse-21.4';
    echo -e "\e[1;32m - install_gvm()\e[0m";
    cd /opt/gvm/src/greenbone;
    # Build Manager
    cd gvmd/ > /dev/null 2>&1;
    /usr/bin/logger '..cmake GVM Daemon' -t 'gse-21.4';
    echo -e "\e[1;36m ... cmake Greenbone Vulnerability Manager (GVM)\e[0m";
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make GVM Daemon' -t 'gse-21.4';
    echo -e "\e[1;36m ... make Greenbone Vulnerability Manager (GVM)\e[0m";
    make > /dev/null 2>&1;
    #/usr/bin/logger '..make documentation for GVM Daemon' -t 'gse-21.4';
    #make doc-full;
    /usr/bin/logger '..make install GVM Daemon' -t 'gse-21.4';
    echo -e "\e[1;36m ... make install Greenbone Vulnerability Manager (GVM)\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32m - install_gvm() finished\e[0m";
    /usr/bin/logger 'install_gvm finished' -t 'gse-21.4';
}

install_nmap() {
    /usr/bin/logger 'install_nmap' -t 'gse-21.4';
    cd /opt/gvm/src/greenbone;
    # Install NMAP
    apt-get -qq -y install ./nmap.deb --fix-missing > /dev/null 2>&1;
    sync;
    /usr/bin/logger 'install_nmap finished' -t 'gse-21.4';
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gse-21.4';
    echo -e "\e[1;32m - prestage_scan_data() \e[0m";
    # copy scan data to prestage ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /tmp/installfiles/ > /dev/null 2>&1;
    /usr/bin/logger '..opening and extracting TAR Ball' -t 'gse-21.4';
    echo -e "\e[1;36m ... opening and extracting TAR ball with prestaged feed data\e[0m";
    tar -xzf /tmp/installfiles/scandata.tar.gz > /dev/null 2>&1; 
    /usr/bin/logger '..copy feed data to /gvm/lib/gvm and openvas' -t 'gse-21.4';
    echo -e "\e[1;36m ... copying feed data to correct locations\e[0m";
    /bin/cp -r /tmp/installfiles/GVM/openvas/plugins/* /var/lib/openvas/plugins/ > /dev/null 2>&1;
    /bin/cp -r /tmp/installfiles/GVM/gvm/* /var/lib/gvm/ > /dev/null 2>&1;
    echo -e "\e[1;36m ... setting permissions\e[0m";
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;32m - prestage_scan_data() finished\e[0m";
    /usr/bin/logger 'prestage_scan_data finished' -t 'gse-21.4';
}

update_feed_data() {
    /usr/bin/logger 'update_feed_data' -t 'gse-21.4';
    echo -e "\e[1;32m - update_feed_data() \e[0m";
    ## This relies on the configure_greenbone_updates script
    echo -e "\e[1;36m ... updating feed data\e[0m";
    echo -e "\e[1;36m ... please be patient. This may take a long time\e[0m";
    /opt/gvm/gse-updater/gse-updater.sh > /dev/null 2>&1;
    echo -e "\e[1;32m - update_feed_data() finished\e[0m";
    /usr/bin/logger 'update_feed_data finished' -t 'gse-21.4';
}

install_gsa() {
    /usr/bin/logger 'install_gsa' -t 'gse-21.4';
    echo -e "\e[1;32m - install_gsa() \e[0m";
    ## Install GSA
    cd /opt/gvm/src/greenbone > /dev/null 2>&1
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    # GSA prerequisites
    /usr/bin/logger '..installing Yarn' -t 'gse-21.4';
    echo -e "\e[1;36m ... installing yarn\e[0m";
    apt-get -qq -y install yarnpkg > /dev/null 2>&1;
    # GSA Install
    cd gsa/ > /dev/null 2>&1;
    /usr/bin/logger '..cmake GSA Daemon' -t 'gse-21.4';
    echo -e "\e[1;36m ... cmake Greenbone Security Assistant (GSA)\e[0m";
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make GSA Daemon' -t 'gse-21.4';
    echo -e "\e[1;36m ... make Greenbone Security Assistant (GSA)\e[0m";
    make > /dev/null 2>&1;                # build the libraries
    #/usr/bin/logger '..make documentation for GSA Daemon' -t 'gse-21.4';
    #make doc-full;       # build more developer-oriented documentation
    /usr/bin/logger '..make install GSA Daemon' -t 'gse-21.4';
    echo -e "\e[1;36m ... make install Greenbone Security Assistant (GSA)\e[0m";
    make install > /dev/null 2>&1;        # install the build
    sync;
    echo -e "\e[1;32m - install_gsa() finished\e[0m";
    /usr/bin/logger 'install_gsa finished' -t 'gse-21.4';
}

browserlist_update(){
    /usr/bin/logger 'browserlist_update()' -t 'gse-21.4';
    echo -e "\e[1;32m - browserlist_updat() \e[0m";
    cat << __EOF__ > /etc/cron.weekly/browserlistupdate
#!/bin/bash
npx browserslist@latest --update-db
/usr/bin/logger 'browserlist_update' -t 'gse-21.4';
exit 0
__EOF__
    sync;
    chmod 744 /etc/cron.weekly/browserlistupdate > /dev/null 2>&1;
    echo -e "\e[1;32m - browserlist_update() finished\e[0m";
    /usr/bin/logger 'browserlist_update() finished' -t 'gse-21.4';
}

install_gvm_tools() {
    /usr/bin/logger 'install_gvm_tools' -t 'gse-21.4';
    echo -e "\e[1;32m - install_gvm_tools() \e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1
    # Install gvm-tools
    cd gvm-tools/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;36m ... installing GVM-tools\e[0m";
    python3 -m pip install . > /dev/null 2>&1;
    /usr/poetry/bin/poetry install > /dev/null 2>&1;
    echo -e "\e[1;32m - install_gvm_tools() finished\e[0m";
    /usr/bin/logger 'install_gvm_tools finished' -t 'gse-21.4';
}

install_impacket() {
    /usr/bin/logger 'install_impacket' -t 'gse-21.4';
    echo -e "\e[1;32m - install_impacket() \e[0m";
    # Install impacket
    python3 -m pip install impacket > /dev/null 2>&1;
    echo -e "\e[1;32m - install_impacket() finished\e[0m";
    /usr/bin/logger 'install_impacket finished' -t 'gse-21.4';
}

prepare_postgresql() {
    /usr/bin/logger 'prepare_postgresql' -t 'gse-21.4';
    echo -e "\e[1;32m - prepare_postgresql() \e[0m";
    echo -e "\e[1;36m ... create postgres user gvm";
    su postgres -c 'createuser -DRS gvm;'
    echo -e "\e[1;36m ... create postgres user root";
    su postgres -c 'createuser -DRS root;'
    echo -e "\e[1;36m ... create database";
    su postgres -c 'createdb -O gvm gvmd;'
    # Setup permissions.
    echo -e "\e[1;36m ... setting postgres permissions";
    su postgres -c "psql gvmd -c 'create role dba with superuser noinherit;'"
    su postgres -c "psql gvmd -c 'grant dba to gvm;'"
    su postgres -c "psql gvmd -c 'grant dba to root;'"
    #   Create DB extensions (also necessary when the database got dropped).
    echo -e "\e[1;36m ... create postgres extensions";
    su postgres -c 'psql gvmd -c "create extension \"uuid-ossp\";"'
    su postgres -c 'psql gvmd -c "create extension "pgcrypto";"'
    echo -e "\e[1;32m - prepare_postgresql() finished\e[0m";
    /usr/bin/logger 'prepare_postgresql finished' -t 'gse-21.4';
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_openvas() \e[0m";
    # Create openvas.conf file
    echo -e "\e[1;36m ... create OpenVAS configuration file\e[0m";
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
    echo -e "\e[1;36m ... creating ospd-openvas service\e[0m";
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
    echo -e "\e[1;36m ... create ospd-openvas configuration file\e[0m";
    mkdir -p /etc/ospd > /dev/null 2>&1;
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
    echo -e "\e[1;32m - configure_openvas() finished\e[0m";
    /usr/bin/logger 'configure_openvas finished' -t 'gse-21.4';
}

configure_gvm() {
    /usr/bin/logger 'configure_gvm' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_gvm() \e[0m";
    # Create certificates
    echo -e "\e[1;36m ... create certificates\e[0m";
    /opt/gvm/bin/gvm-manage-certs -a > /dev/null 2>&1;
    echo -e "\e[1;36m ... create GVM service\e[0m";
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
    echo -e "\e[1;32m - configure_gvm() finished\e[0m";
    /usr/bin/logger 'configure_gvm() finished' -t 'gse-21.4';
}

configure_gsa() {
    /usr/bin/logger 'configure_gsa' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_gsa() \e[0m";
    # Configure GSA daemon
    echo -e "\e[1;36m ... create GSAD service\e[0m";
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
# With NGINX listen on 127.0.0.1 and http only (https through NGINX)
ExecStart=/opt/gvm/sbin/gsad --listen 127.0.0.1 --port=8443 --http-only
# Without NGINX user: ExecStart=/opt/gvm/sbin/gsad --port=8443 --ssl-private-key=/var/lib/gvm/private/CA/serverkey.pem --ssl-certificate=/var/lib/gvm/CA/servercert.pem --munix-socket=/run/gvm/gvmd.sock --no-redirect --secure-cookie --http-sts --timeout=60 --http-cors="https://%H:8443/" --gnutls-priorities=SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
Alias=greenbone-security-assistant.service
EOF'    
    sync;
    echo -e "\e[1;32m - configure_gsa() finished\e[0m";
/usr/bin/logger 'configure_gsa finished' -t 'gse-21.4';
}

configure_feed_owner() {
    /usr/bin/logger 'configure_feed_owner' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_feed_owner() \e[0m";
    echo "User admin for GVM $HOSTNAME " >> /var/lib/gvm/adminuser;
    echo -e "\e[1;36m ... configuring feed owner\e[0m";
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
    echo -e "\e[1;32m - configure_feed_owner() finished\e[0m";
    /usr/bin/logger 'configure_feed_owner finished' -t 'gse-21.4';
}

configure_greenbone_updates() {
    /usr/bin/logger 'configure_greenbone_updates' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_greenbone_updates() \e[0m";
    # Configure daily GVM updates timer and service
    mkdir -p /opt/gvm/gse-updater > /dev/null 2>&1;
    # Timer
    echo -e "\e[1;36m ... create gse-update timer\e[0m";
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
    echo -e "\e[1;36m ... create gse-update service\e[0m";
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
    echo -e "\e[1;36m ... create gse-update script\e[0m";
    cat << __EOF__  > /opt/gvm/gse-updater/gse-updater.sh;
#! /bin/bash
# updates feeds for Greenbone Vulnerability Manager
# Using the Community feed require some significant delays between syncs, as only one session at a time is allowed for community feed

# NVT data
su gvm -c "/opt/gvm/bin/greenbone-nvt-sync" > /dev/null 2>&1;
/usr/bin/logger ''nvt data Feed Version \$(su gvm -c "/opt/gvm/bin/greenbone-nvt-sync --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 62;

# CERT data
su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type cert" > /dev/null 2>&1;
/usr/bin/logger ''Certdata Feed Version \$(su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type cert --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 62;

# SCAP data
su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type scap" > /dev/null 2>&1;
/usr/bin/logger ''Scapdata Feed Version \$(su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type scap --feedversion")'' -t gse;
# Debian keeps TCP sessions open for 60 seconds
sleep 62;

# GVMD data
su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type gvmd_data" > /dev/null 2>&1;
/usr/bin/logger ''gvmd data Feed Version \$(su gvm -c "/opt/gvm/sbin/greenbone-feed-sync --type gvmd_data --feedversion")'' -t gse;
exit 0
__EOF__
    sync;
    chmod 744 /opt/gvm/gse-updater/gse-updater.sh > /dev/null 2>&1;
    echo -e "\e[1;32m - configure_greenbone_updates() finished\e[0m";
    /usr/bin/logger 'configure_greenbone_updates finished' -t 'gse-21.4';
}   

start_services() {
    /usr/bin/logger 'start_services' -t 'gse-21.4';
    echo -e "\e[1;32m - start_services()\e[0m";
    # Load new/changed systemd-unitfiles
    echo -e "\e[1;36m ... reload new and changed systemd unit files\e[0m";
    systemctl daemon-reload > /dev/null 2>&1;
    # Restart Redis with new config
    echo -e "\e[1;36m ... restarting redis service\e[0m";
    systemctl restart redis > /dev/null 2>&1;
    # Enable GSE units
    echo -e "\e[1;36m ... enabling ospd-openvas service\e[0m";
    systemctl enable ospd-openvas > /dev/null 2>&1;
    echo -e "\e[1;36m ... enabling gvmd service\e[0m";
    systemctl enable gvmd.service > /dev/null 2>&1;
    echo -e "\e[1;36m ... enabling gsad service\e[0m";
    systemctl enable gsad.service > /dev/null 2>&1;
    # Start GSE units
    echo -e "\e[1;36m ... restarting ospd-openvas service\e[0m";
    systemctl restart ospd-openvas > /dev/null 2>&1;
    echo -e "\e[1;36m ... restarting gvmd service\e[0m";
    systemctl restart gvmd.service > /dev/null 2>&1;
    echo -e "\e[1;36m ... restarting gsad service\e[0m";
    systemctl restart gsad.service > /dev/null 2>&1;
    # Enable gse-update timer and service
    echo -e "\e[1;36m ... enabling gse-update timer and service\e[0m";
    systemctl enable gse-update.timer > /dev/null 2>&1;
    systemctl enable gse-update.service > /dev/null 2>&1;
    # restart NGINX
    echo -e "\e[1;36m ... restarting nginx service\e[0m";
    systemctl restart nginx.service > /dev/null 2>&1;
    # Will start after next reboot - may disturb the initial update
    echo -e "\e[1;36m ... starting gse-update timer\e[0m";
    systemctl start gse-update.timer > /dev/null 2>&1;
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
    echo -e "\e[1;32m - start_services() finished\e[0m";
    /usr/bin/logger 'start_services finished' -t 'gse-21.4';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_redis()\e[0m";
    echo -e "\e[1;36m ... creating tmpfiles.d configuration for redis\e[0m";
    sh -c 'cat << EOF > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
EOF'
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m ... starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;36m ... creating redis configuration for Greenbone Source Edition\e[0m";
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
    echo -e "\e[1;36m ... configuring sysctl for Greenbone Source Edition, Redis\e[0m";
    sysctl -w vm.overcommit_memory=1 > /dev/null 2>&1;
    sysctl -w net.core.somaxconn=1024 > /dev/null 2>&1;
    echo "vm.overcommit_memory=1" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=1024" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo -e "\e[1;36m ... disable transparent huge pages with grub\e[0m";
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    sh -c 'cat << EOF  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by redis
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT transparent_hugepage=never"
EOF'
    echo -e "\e[1;36m ... updating grub\e[0m";
    update-grub > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32m - configure_redis() finished\e[0m";
    /usr/bin/logger 'configure_redis finished' -t 'gse-21.4';
}

configure_permissions() {
    /usr/bin/logger 'configure_permissions' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_permissions()\e[0m";
    /usr/bin/logger '..Setting correct ownership of files for user gvm' -t 'gse-21.4';
    echo -e "\e[1;36m ... configuring permissions for Greenbone Source Edition\e[0m";
    # Once more to ensure that GVM owns all files in /opt/gvm
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1;
    # GSE log files
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    # Openvas feed
    chown -R gvm:gvm /var/lib/openvas > /dev/null 2>&1;
    # GVM Feed
    chown -R gvm:gvm /var/lib/gvm > /dev/null 2>&1;
    # OSPD Configuration file
    chown -R gvm:gvm /etc/ospd/ > /dev/null 2>&1;
    echo -e "\e[1;32m - configure_permissions() finished\e[0m";
    /usr/bin/logger 'configure_permissions finished' -t 'gse-21.4';
}

get_scanner_status() {
    /usr/bin/logger 'get_scanner_status()' -t 'gse-21.4';
    echo -e "\e[1;32m - get_scanner_status()\e[0m";
    # Check status of Default scanners (Openvas and CVE).
    # These always have the well-known UUIDs used below. Additional scanners will have a random UUID
    # If returning "Failed to verify scanner" most likely GVMD cannot communicate with ospd-openvas.sock
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;36m ... Checking default scanner connectivity.......";
    echo -e "\e[1;33m ... Local $(su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73')\e[0m";
    echo -e "\e[1;33m ... Local $(su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b')\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    # Write status to syslog too
    /usr/bin/logger ''Default OpenVAS $(su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73")'' -t 'gse-21.4';    
    /usr/bin/logger ''Default CVE $(su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b")'' -t 'gse-21.4';
    echo -e "\e[1;32m - get_scanner_status() finished\e[0m";
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'gse-21.4';
    echo -e "\e[1;32m - create_gvm_python_script()\e[0m";
    mkdir /opt/gvm/scripts > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/scripts/ > /dev/null 2>&1;
    echo -e "\e[1;36m ... creating sample script\e[0m";
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
    echo -e "\e[1;32m - create_gvm_python_script() finished\e[0m";
    /usr/bin/logger 'create_gvm_python_script finished' -t 'gse-21.4';
}

configure_cmake() {
    /usr/bin/logger 'configure_cmake' -t 'gse-21.4';
    echo -e "\e[1;32m - configure_cmake()\e[0m";
    # Temporary workaround until CMAKE recognizes Postgresql 13
    echo -e "\e[1;36m ... configuring cmake ro recognize Postgresql v13\e[0m";
    sed -ie '1 s/^/set(PostgreSQL_ADDITIONAL_VERSIONS "13")\n/' /usr/share/cmake-3.18/Modules/FindPostgreSQL.cmake > /dev/null 2>&1
    # Temporary workaround until CMAKE recognizes Postgresql 13
    echo -e "\e[1;32m - configure_cmake() finished\e[0m";
   /usr/bin/logger 'configure_cmake finished' -t 'gse-21.4';
}

update_openvas_feed () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    echo -e "\e[1;32m - update_openvas_feed()\e[0m";
    echo -e "\e[1;36m ... updating NVT information\e[0m";
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info' > /dev/null 2>&1;
    echo -e "\e[1;32m - update_openvas_feed() finished\e[0m";
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gse';
}

install_nginx() {
    /usr/bin/logger 'install_nginx()' -t 'GSE-21.4.3';
    echo -e "\e[1;32m - install_nginx()\e[0m";
    echo -e "\e[1;36m ... installing nginx and apache2 utils\e[0m";
    apt-get -qq -y install nginx apache2-utils > /dev/null 2>&1;
    echo -e "\e[1;32m - install_nginx() finished\e[0m";
    /usr/bin/logger 'install_nginx() finished' -t 'GSE-21.4.3';
}

configure_nginx() {
    /usr/bin/logger 'configure_nginx()' -t 'GSE-21.4.3';
    echo -e "\e[1;32m - configure_nginx()\e[0m";
    echo -e "\e[1;36m ... configuring diffie hellman parameters file\e[0m";
    openssl dhparam -out /etc/nginx/dhparam.pem 2048 > /dev/null 2>&1
    # TLS
    echo -e "\e[1;36m ... configuring site\e[0m";
    cat << __EOF__ > /etc/nginx/sites-available/default;
#########################################
# reverse proxy configuration for GSE   #
# Running GSE on port 443 TLS           #
#########################################

server {
    listen 80;
    return 301 https://\$host\$request_uri;
}

server {
    client_max_body_size 32M;
    listen 443 ssl http2;
    ssl_certificate           /var/lib/gvm/CA/servercert.pem;
    ssl_certificate_key       /var/lib/gvm/private/CA/serverkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
    # Enable HSTS
    add_header Strict-Transport-Security "max-age=31536000" always;
    # Optimize session cache
    ssl_session_cache   shared:SSL:40m;
    ssl_session_timeout 4h;  # Enable session tickets
    ssl_session_tickets on;
    # Diffie Hellman Parameters
    ssl_dhparam /etc/nginx/dhparam.pem;

### GSAD is listening on localhost port 8443/TCP
    location / {
      # Authentication handled by GSAD
      # Access log for GSE
      access_log              /var/log/nginx/gse.access.log;
      error_log               /var/log/nginx/gse.error.log  warn;
      proxy_set_header        Host \$host;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;

      # Fix the “It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://localhost:8443;
      proxy_read_timeout  90;

      proxy_redirect      http://localhost:8443 https://$HOSTNAME;
    }
  }
__EOF__
    echo -e "\e[1;32m - configure_nginx() finished\e[0m";
    /usr/bin/logger 'configure_nginx() finished' -t 'GSE-21.4.3';
}

nginx_certificates() {
    ## Use this if you want to create a request to send to corporate PKI for the web interface, also change the NGINX config to use that
    /usr/bin/logger 'nginx_certificates()' -t 'GSE-21.4.3';
    echo -e "\e[1;32m - nginx_certificates()\e[0m";

    ## NGINX stuff
    ## Required information for NGINX certificates
    # organization name
    # (see also https://www.switch.ch/pki/participants/)
    export ORGNAME=$GVM_CERTIFICATE_ORG
    # the fully qualified server (or service) name, change if other servicename than hostname
    export FQDN=$HOSTNAME;
    # Local information
    export ISOCOUNTRY=$GVM_CERTIFICATE_COUNTRY
    export PROVINCE=$GVM_CA_CERTIFICATE_STATE
    export LOCALITY=$GVM_CERTIFICATE_LOCALITY
    # subjectAltName entries: to add DNS aliases to the CSR, delete
    # the '#' character in the ALTNAMES line, and change the subsequent
    # 'DNS:' entries accordingly. Please note: all DNS names must
    # resolve to the same IP address as the FQDN.
    export ALTNAMES=DNS:$HOSTNAME   # , DNS:bar.example.org , DNS:www.foo.example.org
    echo -e "\e[1;36m ... creating cert configuration file\e[0m";
    mkdir -p /etc/nginx/certs/ > /dev/null 2>&1;
    cat << __EOF__ > ./openssl.cnf
## Request for $FQDN
[ req ]
default_bits = 2048
default_md = sha256
prompt = no
encrypt_key = no
distinguished_name = dn
req_extensions = req_ext

[ dn ]
countryName         = $ISOCOUNTRY
stateOrProvinceName = $PROVINCE
localityName        = $LOCALITY
organizationName    = $ORGNAME
CN = $FQDN

[ req_ext ]
subjectAltName = $ALTNAMES
__EOF__
    sync;
    # generate Certificate Signing Request to send to corp PKI
    echo -e "\e[1;36m ... generate CSR\e[0m";
    openssl req -new -config openssl.cnf -keyout /etc/nginx/certs/$HOSTNAME.key -out /etc/nginx/certs/$HOSTNAME.csr > /dev/null 2>&1
    # generate self-signed certificate (remove when CSR can be sent to Corp PKI)
    echo -e "\e[1;36m ... generate self-signed certificate\e[0m";
    openssl x509 -in /etc/nginx/certs/$HOSTNAME.csr -out /etc/nginx/certs/$HOSTNAME.crt -req -signkey /etc/nginx/certs/$HOSTNAME.key -days 365 > /dev/null 2>&1
    chmod 600 /etc/nginx/certs/$HOSTNAME.key
    /usr/bin/logger 'nginx_certificates() finished' -t 'GSE-21.4.3';
    echo -e "\e[1;32m - nginx_certificates() finished\e[0m";
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32m - Primary Server Install main()\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36m ... Starting installation of primary Greenbone Source Edition Server $HOSTNAME\e[0m"
    echo -e "\e[1;36m ... $HOSTNAME will also be the Certificate Authority for itself and all secondaries\e[0m"
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    # Shared variables
    # GSE Certificate options
   
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
    export GVM_CERTIFICATE_SECPARAM="high"
    export GVM_CERTIFICATE_SIGNALG="SHA512"
    # Hostname
    export GVM_CERTIFICATE_HOSTNAME=$HOSTNAME
    # CA Certificate Lifetime
    export GVM_CA_CERTIFICATE_LIFETIME=3652
    # Key & cert material locations
    export GVM_KEY_LOCATION="/var/lib/gvm/private/CA"
    export GVM_CERT_LOCATION="/var/lib/gvm/CA"

    ## Start actual installation
   
    # Shared components
    install_prerequisites;
    install_nginx;
    configure_nginx;
    ## The function below can be used to create a CSR to send to corporate PKI
    #nginx_certificates;
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
    #browserlist_update;
    # Prestage only works on the specific Vagrant lab where a scan-data tar-ball is copied to the Host. 
    # Update scan-data only from greenbone when used everywhere else.
    if test -f /tmp/installfiles/scandata.tar.gz; then
        prestage_scan_data;
    fi
    configure_greenbone_updates;
    configure_permissions;
    update_feed_data;
    update_openvas_feed;
    start_services;
    configure_feed_owner;
    get_scanner_status;
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot' -t 'gse-21.4';
    echo -e;
    echo -e "\e[1;32mInstallation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot\e[0m";
    echo -e "\e[1;32m - Primary Server Install main() finished\e[0m";
}

main;

exit 0;