#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Instruction:  Run this script as root on a fully updated                  #
#               Debian 12 (Bookworm)                                        #
#                                                                           #
#############################################################################

install_prerequisites() {
    /usr/bin/logger 'install_prerequisites' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_prerequisites()\e[0m";
    echo -e "\e[1;32m--------------------------------------------\e[0m";
    echo -e "\e[1;36m...installing prerequisite packages\e[0m";
    export DEBIAN_FRONTEND=noninteractive;
    # OS Version
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    CODENAME=$VERSION_CODENAME
    /usr/bin/logger "Operating System: $OS Version: $VER: $CODENAME" -t 'ce-2024-11-28';
    echo -e "\e[1;36m...Operating System: $OS Version: $VER: $CODENAME\e[0m";
    # Install prerequisites
    apt-get -qq update > /dev/null 2>&1;
    # Install some basic tools on a Debian net install
    /usr/bin/logger '..Install some basic tools missing if installed from Debian net-install' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...install tools missing if installed from Debian net-install\e[0m";
    apt-get -qq -y install --fix-policy > /dev/null 2>&1;
    apt-get -qq -y install adduser wget whois build-essential devscripts git unzip apt-transport-https ca-certificates curl gnupg2 \
        software-properties-common dnsutils dirmngr --install-recommends  > /dev/null 2>&1;
    # Set locale
    locale-gen > /dev/null 2>&1;
    update-locale > /dev/null 2>&1;
    # For development
    #apt-get -qq -y install libcgreen1 > /dev/null 2>&1;
    # Install pre-requisites for openvas
    /usr/bin/logger '..Tools for Development' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...installing required development tools\e[0m";
    apt-get -qq -y install openssh-client gpgsm dpkg xmlstarlet libbsd-dev libjson-glib-dev gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev libunistring-dev libxml2-dev > /dev/null 2>&1;    # Install pre-requisites for gsad
    /usr/bin/logger '..Prerequisites for notus-scanner' -t 'ce-2024-11-28';
    apt-get -qq -y install libpaho-mqtt-dev python3 python3-pip python3-setuptools python3-psutil python3-gnupg python3-venv > /dev/null 2>&1;
    
    # Other pre-requisites for GSE
    if [ $VER -eq "12" ]
        then
            /usr/bin/logger '..install_prerequisites_debian_12_bookworm' -t 'ce-2024-11-28';
            echo -e "\e[1;36m...installing prequisites Debian 12 Bookworm\e[0m";
            # Install pre-requisites for gvmd on Bookworm (debian 12)
            apt-get -qq -y install gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc doxygen > /dev/null 2>&1;      
            echo -e "\e[1;36m...other prerequisites for Greenbone Community Edition\e[0m";
            # Other pre-requisites for GSE - Bookworm / Debian 12
            /usr/bin/logger '....Other prerequisites for Greenbone Community Edition on Debian 12' -t 'ce-2024-11-28';
            apt-get -qq -y install doxygen mosquitto gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev pkg-config libical-dev xsltproc > /dev/null 2>&1;       
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libhiredis-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy > /dev/null 2>&1;
            apt-get install -qq -y libhiredis-dev gcc pkg-config libssh-4 libssh-dev libgnutls28-dev libcjson-dev\
                libglib2.0-dev libjson-glib-dev libpcap-dev libgpgme-dev bison libksba-dev \
                libsnmp-dev libgcrypt20-dev redis-server libbsd-dev libcurl4-gnutls-dev pnscan > /dev/null 2>&1;
     
        else
            /usr/bin/logger "..Unsupported Debian version $OS $VER $CODENAME $DISTRIBUTION" -t 'ce-2024-11-28';
            echo -e "\e[1;36m...Unsupported Debian version $OS $VER $CODENAME $DISTRIBUTION\e[0m";
            exit;
        fi
    
    /usr/bin/logger '..install prerequisites finished' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...install prerequisites finished\e[0m";

    # Install other preferences and cleanup APT
    echo -e "\e[1;36m...installing preferred tools and clean up apt\e[0m";
    /usr/bin/logger '....Install preferences on Debian' -t 'ce-2024-11-28';
    apt-get -qq -y install bash-completion > /dev/null 2>&1;
    # Install SUDO
    apt-get -qq -y install sudo > /dev/null 2>&1;
    # A little apt cleanup
    apt-get -qq update > /dev/null 2>&1;
    apt-get -qq -y full-upgrade > /dev/null 2>&1;
    apt-get -qq -y autoremove --purge > /dev/null 2>&1;
    apt-get -qq -y autoclean > /dev/null 2>&1;
    apt-get -qq -y clean > /dev/null 2>&1;    
    # Python pip packages
    echo -e "\e[1;36m...installing python and python-pip\e[0m";
    apt-get -qq -y install python3-pip > /dev/null 2>&1;
    python3 -m pip install --upgrade pip > /dev/null 2>&1
    # Prepare directories for scan data
    echo -e "\e[1;36m...preparing directories for scan feed data\e[0m";
    mkdir -p /var/lib/gvm/private/CA > /dev/null 2>&1;
    mkdir -p /var/lib/gvm/CA > /dev/null 2>&1;
    mkdir -p /var/lib/openvas/plugins > /dev/null 2>&1;
    # logging
    mkdir -p /var/log/gvm/ > /dev/null 2>&1;
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    timedatectl set-timezone UTC > /dev/null 2>&1;
    echo -e "\e[1;32minstall_prerequisites() finished\e[0m";
    /usr/bin/logger 'install_prerequisites finished' -t 'ce-2024-11-28';
}

clean_env() {
    /usr/bin/logger 'clean_env()' -t 'ce-2024-11-28';
    echo -e "\e[1;32mclean_env()\e[0m";
    ## Deleting file with variables environment variables from env
    mv $ENV_DIR/.env /home/$GREENBONEUSER/.env;
    /usr/bin/logger 'clean_env() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mclean_env() finished\e[0m";
}

prepare_nix() {
    echo -e "\e[1;32mprepare_nix()\e[0m";
    echo -e "\e[1;32mCreating Users, configuring sudoers, and setting locale\e[0m";
    # set desired locale
    echo -e "\e[1;36m...configuring locale\e[0m";
    localectl set-locale en_US.UTF-8 > /dev/null 2>&1;
    # Create gvm user
    echo -e "\e[1;36m...creating gvm user\e[0m";
    /usr/sbin/useradd --system --create-home --home-dir /opt/gvm/ -c "gvm User" --shell /bin/bash gvm > /dev/null 2>&1;
    mkdir /opt/gvm > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1;

    # create user for valkey if required
    if [ $VALKEY_INSTALL == "Yes" ]
        then
            echo -e "\e[1;36m...creating valkey user\e[0m";
            /usr/sbin/useradd --system -c "Valkey User" --shell /bin/bash valkey > /dev/null 2>&1;
        fi

    # Update the PATH environment variable
    echo "PATH=\$PATH:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/gvmpy/bin" > /etc/profile.d/gvm.sh;
    # Add GVM library path to /etc/ld.so.conf.d
    echo -e "\e[1;36m...configuring ld for greenbone libraries\e[0m";
    cat << __EOF__ > /etc/ld.so.conf.d/greenbone.conf;
# Greenbone libraries
/opt/gvm/lib
/opt/gvm/include
__EOF__
    echo -e "\e[1;36m...creating sudoers.d/greenbone file\e[0m";
    cat << __EOF__ > /etc/sudoers.d/gvm
gvm     ALL = NOPASSWD: /opt/gvm/sbin/openvas

Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gvm/sbin"
__EOF__
    echo -e "\e[1;36m...configuring tmpfiles.d for greenbone run files\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/greenbone.conf
d /run/gvmd 1775 gvm gvm
d /run/gvmd/gse 1775 root
d /run/ospd 1775 gvm gvm
d /run/ospd/gse 1775 root
d /var/log/gvm 1775 gvm gvm
__EOF__
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m...starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;32mprepare_nix() finished\e[0m";
}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'ce-2024-11-28';
    echo -e "\e[1;32mprepare_source()\e[0m";
    echo -e "\e[1;32mPreparing GSE Source files\e[0m";
    echo -e "\e[1;36m...preparing directories\e[0m";
    echo -e "\e[1;32mInstalling the following GCE versions\e[0m";
    echo -e "\e[1;35m----------------------------------"
    echo -e "\e[1;35mgvmlibs \t\t $GVMLIBS"
    echo -e "\e[1;35mospd-openvas \t $OSPDOPENVAS"
    echo -e "\e[1;35mopenvas-scanner \t $OPENVAS"
    echo -e "\e[1;35mopenvas-smb \t $OPENVASSMB"
    echo -e "\e[1;35mgvm-tools \t\t $GVMTOOLS"
    echo -e "\e[1;35mnotus-scanner \t $NOTUS"
    echo -e "\e[1;35mfeed-sync \t\t $FEEDSYNC"
    echo -e "\e[1;35m----------------------------------"
    echo -e "\e[1;35mvalkey-server \t\t $VALKEY"
    echo -e "\e[1;35m----------------------------------\e[0m";

    mkdir -p /opt/gvm/src/greenbone > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/src/greenbone > /dev/null 2>&1;
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
  /usr/bin/logger '..gvm libraries' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...downloading released packages for Greenbone Community Edition\e[0m";
    /usr/bin/logger '..gvm-libs' -t 'ce-2024-11-28';
    wget -O gvmlibs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVMLIBS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..ospd-openvas' -t 'ce-2024-11-28';
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPDOPENVAS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-scanner' -t 'ce-2024-11-28';
    wget -O openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gsa daemon (gsad)' -t 'ce-2024-11-28';
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVASSMB.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..python-gvm' -t 'ce-2024-11-28';
    wget -O python-gvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v$PYTHONGVM.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm-tools' -t 'ce-2024-11-28';
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v$GVMTOOLS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..notus-scanner' -t 'ce-2024-11-28';
    wget -O notus.tar.gz https://github.com/greenbone/notus-scanner/archive/refs/tags/v$NOTUS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..greenbone-feed-sync' -t 'ce-2024-11-28';
    wget -O greenbone-feed-sync.tar.gz https://github.com/greenbone/greenbone-feed-sync/archive/refs/tags/v$FEEDSYNC.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..greenbone-feed-sync' -t 'gce-2024-11-25';
    wget -O valkey.tar.gz https://github.com/valkey-io/valkey/archive/refs/tags/$VALKEY.tar.gz > /dev/null 2>&1;

    # open and extract the tarballs
    echo -e "\e[1;36m...open and extract tarballs\e[0m";
    /usr/bin/logger '..open and extract the tarballs' -t 'ce-2024-11-28';
    find *.gz | xargs -n1 tar zxvfp > /dev/null 2>&1;
    sync;

    # Naming of directories w/o version
    /usr/bin/logger '..rename directories' -t 'ce-2024-11-28';    
    echo -e "\e[1;36m...renaming package directories\e[0m";
    mv /opt/gvm/src/greenbone/gvm-libs-$GVMLIBS /opt/gvm/src/greenbone/gvm-libs > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/ospd-openvas-$OSPDOPENVAS /opt/gvm/src/greenbone/ospd-openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-scanner-$OPENVAS /opt/gvm/src/greenbone/openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-smb-$OPENVASSMB /opt/gvm/src/greenbone/openvas-smb > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/python-gvm-$PYTHONGVM /opt/gvm/src/greenbone/python-gvm > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvm-tools-$GVMTOOLS /opt/gvm/src/greenbone/gvm-tools > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/notus-scanner-$NOTUS /opt/gvm/src/greenbone/notus > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/greenbone-feed-sync-$FEEDSYNC /opt/gvm/src/greenbone/greenbone-feed-sync > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/valkey-$VALKEY /opt/gvm/src/greenbone/valkey > /dev/null 2>&1;    
    sync;
    echo -e "\e[1;36m...configuring permissions\e[0m";
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;32mprepare_source() finished\e[0m";
    /usr/bin/logger 'prepare_source finished' -t 'ce-2024-11-28';
}

install_poetry() {
    /usr/bin/logger 'install_poetry' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_poetry()\e[0m";
    export POETRY_HOME=/usr/poetry;
    # https://python-poetry.org/docs/
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 - > /dev/null 2>&1;
    echo -e "\e[1;32minstall_poetry() finished\e[0m";
    /usr/bin/logger 'install_poetry finished' -t 'ce-2024-11-28';
}

install_valkey() {
    /usr/bin/logger 'install_valkey' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_valkey() $VALKEY\e[0m";
    apt -qq -y install libsystemd-dev > /dev/null 2>&1; 
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # make valkey
    cd valkey > /dev/null 2>&1;
    /usr/bin/logger '..make install valkey' -t 'gce-2024-11-25';
    echo -e "\e[1;36m...make install valkey $VALKEY\e[0m";
    make install USE_SYSTEMD=yes distclean > /dev/null 2>&1;
    # Create valkey user
    echo -e "\e[1;36m...creating valkey user\e[0m";
    /usr/sbin/useradd --system -c "Valkey User" --shell /bin/bash valkey > /dev/null 2>&1;
    mkdir /etc/valkey/;
    sync;
    echo -e "\e[1;32minstall_valkey() finished\e[0m";
    /usr/bin/logger 'install_valkey finished' -t 'ce-2024-11-28';
}

install_libxml2() {
    /usr/bin/logger 'install_libxml2' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_libxml2()\e[0m";
    cd /opt/gvm/src;
    /usr/bin/logger '..git clone libxml2' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...git clone libxml2()\e[0m";
    git clone https://gitlab.gnome.org/GNOME/libxml2 > /dev/null 2>&1;
    cd libxml2;
    /usr/bin/logger '..autogen libxml2' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...autogen libxml2()\e[0m";
    ./autogen.sh > /dev/null 2>&1;
    # /usr/bin/logger '..make libxml2' -t 'ce-2024-11-28';
    # echo -e "\e[1;36m...make libxml2()\e[0m";
    # make > /dev/null 2>&1;
    /usr/bin/logger '..make install libxml2' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...make install libxml2()\e[0m";
    make install > /dev/null 2>&1;
    /usr/bin/logger '..ldconfig libxml2' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...ldconfig libxml2()\e[0m";
    ldconfig > /dev/null 2>&1;
}

install_gvm_libs() {
    /usr/bin/logger 'install_gvmlibs' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_gvmlibs()\e[0m";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd gvm-libs/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    /usr/bin/logger '..cmake Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...cmake Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    # /usr/bin/logger '..make Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'ce-2024-11-28';
    # echo -e "\e[1;36m...make Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    # make > /dev/null 2>&1;
    #make doc-full > /dev/null 2>&1;
    /usr/bin/logger '..make install Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...make install Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...load Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    ldconfig > /dev/null 2>&1;
    /usr/bin/logger 'install_gvmlibs finished' -t 'ce-2024-11-28';
}

install_python_gvm() {
    /usr/bin/logger 'install_python_gvm' -t 'ce-2024-11-28';
    # Installing from repo
    #su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install python-gvm==$PYTHONGVM";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd python-gvm/ > /dev/null 2>&1;
    su gvm -c '~/source gvmpy/bin/activate; python3 -m pip install .';
    #/usr/poetry/bin/poetry install;
    /usr/bin/logger 'install_python_gvm finished' -t 'ce-2024-11-28';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_openvas_smb()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #config and build openvas-smb
    cd openvas-smb > /dev/null 2>&1;
    echo -e "\e[1;36m...cmake OpenVAS SMB\e[0m";
    /usr/bin/logger '..cmake OpenVAS SMB' -t 'ce-2024-11-28';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    # /usr/bin/logger '..make OpenVAS SMB' -t 'ce-2024-11-28';
    # echo -e "\e[1;36m...make OpenVAS SMB\e[0m";
    # make > /dev/null 2>&1;                
    /usr/bin/logger '..make install OpenVAS SMB' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...make install OpenVAS SMB\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...load OpenVAS SMB libraries\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32minstall_openvas_smb() finished\e[0m";
    /usr/bin/logger 'install_openvas_smb finished' -t 'ce-2024-11-28';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_ospd_openvas()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    # install from source
    echo -e "\e[1;36m...installing ospd-openvas\e[0m";
    cd ospd-openvas > /dev/null 2>&1;
    # Install from PyPi repo
    #su gvm -c "source ~/gvmpy/bin/activate;python3 -m pip install ospd-openvas==$OSPDOPENVASOLD --use-pep517";
    #su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install ospd-openvas==$OSPDOPENVAS --use-pep517" > /dev/null 2>&1;
    su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1;
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32minstall_ospd_openvas() finished\e[0m";
    /usr/bin/logger 'install_ospd_openvas finished' -t 'ce-2024-11-28';
}

install_openvas() {
    /usr/bin/logger 'install_openvas' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_openvas()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    cd openvas > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    /usr/bin/logger '..cmake OpenVAS Scanner' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...cmake OpenVAS Scanner\e[0m";
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    /usr/bin/logger '..make OpenVAS Scanner' -t 'ce-2024-11-28';
    # echo -e "\e[1;36m...make OpenVAS Scanner\e[0m";
    # # make it
    # make > /dev/null 2>&1;
    # build more developer-oriented documentation
    #make doc-full > /dev/null 2>&1; 
    /usr/bin/logger '..make install OpenVAS Scanner' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...make install OpenVAS Scanner\e[0m";
    make install > /dev/null 2>&1;
    /usr/bin/logger '..Rebuild make cache, OpenVAS Scanner' -t 'ce-2024-11-28';
    make rebuild_cache > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...load OpenVAS Scanner libraries\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32minstall_openvas() finished\e[0m";
    /usr/bin/logger 'install_openvas finished' -t 'ce-2024-11-28';
}

create_scan_user() {
    /usr/bin/logger 'create_scan_user' -t 'ce-2024-11-28';
    echo -e "\e[1;32mcreate_scan_user()\e[0m";
    cat << __EOF__ > /etc/sudoers.d/greenbone
greenbone     ALL=(ALL) NOPASSWD: ALL
__EOF__
    export greenbone_secret="$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 20)";
    echo -e "\e[1;36m...creating user greenbone for temporary usage\e[0m";
    /usr/sbin/useradd --create-home -c "greenbone secondary user" --shell /bin/bash $GREENBONEUSER > /dev/null 2>&1;
    echo -e "$greenbone_secret\n$greenbone_secret\n" | passwd $GREENBONEUSER > /dev/null 2>&1;
    echo "User Greenbone for secondary $HOSTNAME created with password: $greenbone_secret" >> /var/lib/gvm/greenboneuser;
    /usr/bin/logger 'create_scan_user() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mcreate_scan_user() finished\e[0m";
}

install_nmap() {
    /usr/bin/logger 'install_nmap' -t 'ce-2024-11-28';
    cd /opt/gvm/src/greenbone;
    # Install NMAP
    apt-get -qq -y install ./nmap.deb --fix-missing > /dev/null 2>&1;
    sync;
    /usr/bin/logger 'install_nmap finished' -t 'ce-2024-11-28';
}

install_greenbone_feed_sync() {
    /usr/bin/logger 'install_greenbone_feed_sync()' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_greenbone_feed_sync() \e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # install from source
    echo -e "\e[1;36m...installing greenbone-feed-sync\e[0m";
    cd greenbone-feed-sync > /dev/null 2>&1;
    su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1;
    #su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install greenbone-feed-sync==$FEEDSYNC" > /dev/null 2>&1;
    /usr/bin/logger 'install_greenbone_feed_sync() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_greenbone_feed_sync() finished\e[0m";
}

prepare_gvmpy() {
    /usr/bin/logger 'prepare_gvmpy' -t 'ce-2024-11-28';
    echo -e "\e[1;32mprepare_gvmpy() \e[0m";
    su gvm -c 'cd ~; python3 -m pip install --upgrade pip; python3 -m pip install --user virtualenv; python3 -m venv gvmpy' > /dev/null 2>&1;
    /usr/bin/logger 'prepare_gvmpy finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mprepare_gvmpy() finished\e[0m";
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'ce-2024-11-28';
    echo -e "\e[1;32mprestage_scan_data() \e[0m";
    # copy scan data to prestage ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /root/ > /dev/null 2>&1;
    /usr/bin/logger '..opening and extracting TAR Ball' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...opening and extracting TAR ball with prestaged feed data\e[0m";
    tar -xzf scandata.tar.gz > /dev/null 2>&1; 
    /usr/bin/logger '..copy feed data to /gvm/lib/gvm and openvas' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...copying feed data to correct locations\e[0m";
    /usr/bin/rsync -aAXv /root/GVM/openvas/plugins/ /var/lib/openvas/plugins/ > /dev/null 2>&1;
    /usr/bin/rsync -aAXv /root/GVM/notus/ /var/lib/notus/ > /dev/null 2>&1;
    rm -rf /root/tmp/ > /dev/null 2>&1;
    echo -e "\e[1;36m...setting permissions\e[0m";
    echo -e "\e[1;32mprestage_scan_data() finished\e[0m";
    /usr/bin/logger 'prestage_scan_data finished' -t 'ce-2024-11-28';
}

update_feed_data() {
    /usr/bin/logger 'update_feed_data' -t 'ce-2024-11-28';
    echo -e "\e[1;32mupdate_feed_data() \e[0m";
    ## This relies on the configure_greenbone_updates script
    echo -e "\e[1;36m...updating feed data\e[0m";
    echo -e "\e[1;36m...this could take a while\e[0m";
    /opt/gvm/gvmpy/bin/greenbone-feed-sync --type $feedtypescanner --config /etc/ospd/greenbone-feed-sync.toml > /dev/null 2>&1;
    echo -e "\e[1;32mupdate_feed_data() finished\e[0m";
    /usr/bin/logger 'update_feed_data finished' -t 'ce-2024-11-28';
}

install_gvm_tools() {
    /usr/bin/logger 'install_gvm_tools' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_gvm_tools() \e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Install gvm-tools
    cd gvm-tools/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;36m...installing GVM-tools\e[0m";
    su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1; 
#    su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install gvm-tools' > /dev/null 2>&1; 
 #   /usr/poetry/bin/poetry install > /dev/null 2>&1;
    echo -e "\e[1;32minstall_gvm_tools() finished\e[0m";
    /usr/bin/logger 'install_gvm_tools finished' -t 'ce-2024-11-28';
}

install_impacket() {
    /usr/bin/logger 'install_impacket' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_impacket() \e[0m";
    # Install impacket
    su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install impacket==$IMPACKET" > /dev/null 2>&1;
    echo -e "\e[1;32minstall_impacket() finished\e[0m";
    /usr/bin/logger 'install_impacket finished' -t 'ce-2024-11-28';
}


install_notus() {
    /usr/bin/logger 'install_notus' -t 'ce-2024-11-28';
    echo -e "\e[1;32minstall_notus()\e[0m";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd notus/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1;
    echo -e "\e[1;36m...Install paho mqtt pypi package version 1.6.1\e[0m";
    su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install paho-mqtt==$PAHOMQTT --use-pep517" > /dev/null 2>&1;
    echo -e "\e[1;36m...Install notus scanner Python pip module (notus-scanner) \e[0m";
    # From Python PyPi
    #su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install notus-scanner==$NOTUS" > /dev/null 2>&1; 
    # From downloaded source
    su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1; 
    sync;
    echo -e "\e[1;32minstall_notus() finished\e[0m";
    /usr/bin/logger 'install_notus finished' -t 'ce-2024-11-28';
}


prepare_gpg() {
    /usr/bin/logger 'prepare_gpg' -t 'ce-2024-11-28';
    echo -e "\e[1;32mprepare_gpg()\e[0m";
    echo -e "\e[1;36m...Downloading and importing Greenbone Community Signing Key (PGP)\e[0m";
    /usr/bin/logger '..Downloading and importing Greenbone Community Signing Key (PGP)' -t 'ce-2024-11-28';
    curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc > /dev/null 2>&1;
    echo -e "\e[1;36m...Fully trust Greenbone Community Signing Key (PGP)\e[0m";
    /usr/bin/logger '..Fully trust Greenbone Community Signing Key (PGP)' -t 'ce-2024-11-28';
    echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" > /tmp/ownertrust.txt;
    sync; sleep 1;
    mkdir -p $GNUPGHOME > /dev/null 2>&1;
    gpg -q --import /tmp/GBCommunitySigningKey.asc;
    gpg -q --import-ownertrust < /tmp/ownertrust.txt;
    sudo mkdir -p $OPENVAS_GNUPG_HOME > /dev/null 2>&1;
    sudo cp -r $GNUPGHOME/* $OPENVAS_GNUPG_HOME/ > /dev/null 2>&1;
    sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME > /dev/null 2>&1;
    gpg -q --import-ownertrust < /tmp/ownertrust.txt;
    /usr/bin/logger 'prepare_gpg finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mprepare_gpg() finished\e[0m";
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_openvas() \e[0m";
    # Create openvas configuration file
    echo -e "\e[1;36m...create OpenVAS configuration file\e[0m";
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

   # valkey
    if [ VALKEY_INSTALL == "Yes" ]
        then
            sed -ie 's+/run/redis/redis.sock+/run/valkey/valkey.sock'+g /etc/valkey/valkey.conf
            sed -ie 's+/run/redis/redis.sock+/run/valkey/valkey.sock'+g /etc/openvas/openvas.conf
        fi

    # Create OSPD Openvas service
    echo -e "\e[1;36m...creating ospd-openvas service\e[0m";
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
ExecStart=/opt/gvm/gvmpy/bin/ospd-openvas --port=9390 --bind-address=0.0.0.0 --pid-file=/run/gvmd/ospd-openvas.pid --lock-file-dir=/run/gvmd/ --key-file=/var/lib/gvm/private/CA/secondary-key.pem --cert-file=/var/lib/gvm/CA/secondary-cert.pem --ca-file=/var/lib/gvm/CA/cacert.pem --log-file=/var/log/gvm/ospd-openvas.log
# --log-level in ospd-openvas.conf can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
__EOF__

    ## Configure ospd
    # Directory for ospd-openvas configuration file
    echo -e "\e[1;36m...create ospd-openvas configuration file\e[0m";
    mkdir -p /etc/ospd;
    cat << __EOF__ > /etc/ospd/ospd-openvas.conf
[OSPD - openvas]
log_level = INFO
socket_mode = 0o766
unix_socket = /run/ospd/ospd-openvas.sock
pid_file = /run/ospd/ospd-openvas.pid
; default = /run/ospd
lock_file_dir = /run/gvmd

; max_scans, is the number of scan/task to be started before start to queuing.
max_scans = 0

; The minimal available memory before the GSM starts to queue scans.
min_free_mem_scan_queue = 1500

; max_queued_scans is the maximum amount of queued scans before starting to reject the new task (will not be queued) and send an error message to gvmd
; This options are disabled with the value 0 (zero), all arriving tasks will be started without queuing.
max_queued_scans = 0
__EOF__

    # Create NOTUS Scanner service
    echo -e "\e[1;36m...creating NOTUS scanner service\e[0m";
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
    echo -e "\e[1;32mconfigure_openvas() finished\e[0m";
    /usr/bin/logger 'configure_openvas finished' -t 'ce-2024-11-28';
}

configure_greenbone_updates() {
    /usr/bin/logger 'configure_greenbone_updates' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_greenbone_updates() \e[0m";
   # Configure daily GVM updates timer and service
    # Timer
    echo -e "\e[1;36m...create gce-update timer\e[0m";
    cat << __EOF__ > /lib/systemd/system/gce-update.timer
[Unit]
Description=Daily job to update nvt feed

[Timer]
# Do not run for the first 37 minutes after boot
OnBootSec=37min
# Run at 18:00 with a random delay of up-to 2 hours before nightly scans  
OnCalendar=*-*-* 18:00:00
RandomizedDelaySec=7200
# Specify service
Unit=gce-update.service

[Install]
WantedBy=multi-user.target
__EOF__

    ## Create gce-update.service
    echo -e "\e[1;36m...create gce-update service\e[0m";
    cat << __EOF__ > /lib/systemd/system/gce-update.service
[Unit]
Description=gse updater
After=network.target networking.service
Documentation=man:gvmd(8)

[Service]
ExecStart=/opt/gvm/gvmpy/bin/greenbone-feed-sync --type $feedtypescanner --config /etc/ospd/greenbone-feed-sync.toml
TimeoutSec=300

[Install]
WantedBy=multi-user.target
__EOF__

    cat << __EOF__ > /etc/ospd/greenbone-feed-sync.toml
[greenbone-feed-sync]
gvmd-lock-file = "$gvmdlockfile"
openvas-lock-file = "$gvmdlockfile"
user = "$feeduser"
group = "$feedgroup"
compression-level = $COMPRESSIONLEVEL
__EOF__

    if [ "ALTERNATIVE_FEED"="Yes" ];
    then
        cat << __EOF__ >> /etc/ospd/greenbone-feed-sync.toml
feed-url = "$FEED_URL"
__EOF__
    fi
    sync;
    chmod +x /opt/gvm/gce-updater/gce-updater.sh > /dev/null 2>&1;
    echo -e "\e[1;32mconfigure_greenbone_updates() finished\e[0m";
    /usr/bin/logger 'configure_greenbone_updates finished' -t 'ce-2024-11-28';
}   

configure_valkey() {
    /usr/bin/logger 'configure_valkey' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_valkey()\e[0m";
    echo -e "\e[1;36m...creating tmpfiles.d configuration for valkey\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/valkey.conf
d /run/valkey 0755 valkey valkey
__EOF__
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m...starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    usermod -aG valkey gvm;
    mkdir /var/lib/valkey/ > /dev/null 2>&1;
    chown -R valkey:valkey /var/lib/valkey/ > /dev/null 2>&1;
    echo -e "\e[1;36m...creating valkey configuration for Greenbone Community Edition\e[0m";
    cat << __EOF__  > /etc/valkey/valkey.conf
bind 127.0.0.1 -::1
port 0
tcp-backlog 511
unixsocket /run/valkey/valkey.sock
# unixsocketgroup wheel
unixsocketperm 766
timeout 0
tcp-keepalive 0
daemonize no
pidfile /run/valkey/valkey.pid
loglevel notice
logfile ""
syslog-enabled yes
# Specify the syslog identity.
syslog-ident valkey
databases 4096
always-show-logo no
hide-user-data-from-log yes
set-proc-title yes
proc-title-template "{title} {listen-addr} {server-mode}"
locale-collate ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
rdb-del-sync-files no
dir /var/lib/valkey/
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-max-replicas 0
repl-diskless-load disabled
dual-channel-replication-enabled no
repl-disable-tcp-nodelay no
replica-priority 100
acllog-max-len 128
lazyfree-lazy-eviction yes
lazyfree-lazy-expire yes
lazyfree-lazy-server-del yes
replica-lazy-flush yes
lazyfree-lazy-user-del yes
lazyfree-lazy-user-flush yes
oom-score-adj no
oom-score-adj-values 0 200 800
disable-thp yes
appendonly no
appendfilename "appendonly.aof"
appenddirname "appendonlydir"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-timestamp-enabled no
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
############################### ADVANCED CONFIG ###############################
hash-max-listpack-entries 512
hash-max-listpack-value 64
list-max-listpack-size -2
list-compress-depth 0
set-max-intset-entries 512
set-max-listpack-entries 128
set-max-listpack-value 64
zset-max-listpack-entries 128
zset-max-listpack-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes
__EOF__

# using valkey so change openvas.conf to use correct socket
echo -e "\e[1;36m...changind openvas to use valkey.sock\e[0m";
sed -ie 's+/run/redis/redis.sock+/run/valkey/valkey.sock'+g /etc/openvas/openvas.conf;

    cat << __EOF__  > /lib/systemd/system/valkey-server.service
[Unit]
Description=Valkey persistent key-value database
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=-/etc/default/valkey
ExecStart=/usr/local/bin/valkey-server /etc/valkey/valkey.conf --daemonize no --supervised systemd $OPTIONS
Type=notify
User=valkey
Group=valkey
RuntimeDirectory=valkey
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
__EOF__

    # Original Redis requirements - overcommit memory and TCP backlog setting > 511
    echo -e "\e[1;36m...configuring sysctl for Greenbone Community Edition, valkey\e[0m";
    sysctl -w vm.overcommit_memory=$vm_overcommit_memory > /dev/null 2>&1;
    sysctl -w net.core.somaxconn=$net_core_somaxconn > /dev/null 2>&1;
    echo "vm.overcommit_memory=$vm_overcommit_memory" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=$net_core_somaxconn" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    cat << __EOF__  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by valkey
GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=$transparent_hugepage"
__EOF__
    echo -e "\e[1;36m...updating grub\e[0m";
    update-grub > /dev/null 2>&1;
    sync;
    systemctl daemon-reload > /dev/null 2>&1;
    systemctl enable valkey-server.service > /dev/null 2>&1;
    systemctl start valkey-server.service > /dev/null 2>&1;
    echo -e "\e[1;32mconfigure_valkey() finished\e[0m";
    /usr/bin/logger 'configure_valkey finished' -t 'ce-2024-11-28';
}

start_services() {
    /usr/bin/logger 'start_services' -t 'ce-2024-11-28';
    echo -e "\e[1;32mstart_services()\e[0m";
    # Load new/changed systemd-unitfiles
    echo -e "\e[1;36m...reload new and changed systemd unit files\e[0m";
    systemctl daemon-reload > /dev/null 2>&1;
        # Redis or Valkey
    if [ "$VALKEY_INSTALL" == "Yes" ]; then
         # Restart valkey with new config
        echo -e "\e[1;36m...restarting valkey service\e[0m";
        systemctl restart valkey-server.service > /dev/null 2>&1;
    else
        # Restart Redis with new config
        echo -e "\e[1;36m...restarting redis service\e[0m";
        systemctl restart redis.service > /dev/null 2>&1;
    fi
    # Enable GSE units
    echo -e "\e[1;36m...enabling ospd-openvas service\e[0m";
    systemctl enable ospd-openvas.service > /dev/null 2>&1;
    # Start ospd-openvas
    echo -e "\e[1;36m...restarting ospd-openvas service\e[0m";
    systemctl restart ospd-openvas.service > /dev/null 2>&1;
    echo -e "\e[1;36m...enabling notus-scanner service\e[0m";
    systemctl enable notus-scanner.service > /dev/null 2>&1;
    # Start notus-scanner
    echo -e "\e[1;36m...restarting ospd-openvas service\e[0m";
    systemctl restart notus-scanner.service > /dev/null 2>&1;
    # Enable gce-update timer and service
    echo -e "\e[1;36m...enabling gce-update timer and service\e[0m";
    systemctl enable gce-update.timer > /dev/null 2>&1;
    systemctl enable gce-update.service > /dev/null 2>&1;
    # Will start after next reboot - may disturb the initial update
    echo -e "\e[1;36m...starting gce-update timer\e[0m";
    systemctl start gce-update.timer > /dev/null 2>&1;
    # Check status of critical service ospd-openvas.service and gce-update
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking valkey/redis......\e[0m";
    if [ $VALKEY_INSTALL == "Yes" ]
        then
            if systemctl is-active --quiet valkey-server.service;
            then
                echo -e "\e[1;32mvalkey-server.service started successfully";
                /usr/bin/logger 'valkey-server.service started successfully' -t 'gce-2024-06-29';
            else
                echo -e "\e[1;31mvalkey-server.service FAILED!\e[0m";
                /usr/bin/logger 'valkey-server.service FAILED' -t 'gce-2024-06-29';
            fi
        else    
            if systemctl is-active --quiet redis-server.service;
            then
                echo -e "\e[1;32mredis-server.service started successfully";
                /usr/bin/logger 'redis-server.service started successfully' -t 'gce-2024-06-29';
            else
                echo -e "\e[1;31mredis-server.service FAILED!\e[0m";
                /usr/bin/logger 'redis-server.service FAILED' -t 'gce-2024-06-29';
            fi
        fi
    echo 'Checking core daemons.....';
    if systemctl is-active --quiet notus-scanner.service;
    then
        echo -e "\e[1;32mnotus-scanner.service started successfully\e[0m";
        /usr/bin/logger 'notus-scanner.service started successfully' -t 'ce-2024-11-28';
    else
        echo -e "\e[1;31mnotus-scanner.service FAILED!";
        /usr/bin/logger 'notus-scanner.service FAILED!\e[0m' -t 'ce-2024-11-28';
    fi

    if systemctl is-active --quiet gce-update.timer;
    then
        echo 'gce-update.timer started successfully';
        /usr/bin/logger 'gce-update.timer started successfully' -t 'ce-2024-11-28';
    else
        echo 'gce-update.timer FAILED! Updates will not be automated';
        /usr/bin/logger 'gce-update.timer FAILED! Updates will not be automated' -t 'ce-2024-11-28';
    fi
    echo -e "\e[1;32m ... start:services() finished\e[0m";
    /usr/bin/logger 'start_services finished' -t 'ce-2024-11-28';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_redis()\e[0m";
    echo -e "\e[1;36m...creating tmpfiles.d configuration for redis\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
__EOF__
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m...starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;36m...creating redis configuration for Greenbone Community Edition\e[0m";
    cat << __EOF__  > /etc/redis/redis.conf
daemonize no
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
    sysctl -w vm.overcommit_memory=$vm_overcommit_memory > /dev/null 2>&1;
    sysctl -w net.core.somaxconn=$net_core_somaxconn > /dev/null 2>&1;
    echo "vm.overcommit_memory=$vm_overcommit_memory" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=$net_core_somaxconn" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    cat << __EOF__  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by redis
GRUB_CMDLINE_LINUX_DEFAULT="\$GRUB_CMDLINE_LINUX_DEFAULT transparent_hugepage=$transparent_hugepage"
__EOF__
    echo -e "\e[1;36m...updating grub\e[0m";
    update-grub > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32mconfigure_redis() finished\e[0m";
    /usr/bin/logger 'configure_redis finished' -t 'ce-2024-11-28';
}

configure_feed_validation() {
    /usr/bin/logger 'configure_feed_validation()' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_feed_validation()\e[0m";
    mkdir -p $GNUPGHOME
    gpg --import /tmp/GBCommunitySigningKey.asc
    gpg --import-ownertrust < /tmp/ownertrust.txt
    sudo mkdir -p $OPENVAS_GNUPG_HOME
    sudo cp -r /tmp/openvas-gnupg/* $OPENVAS_GNUPG_HOME/
    sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME
    # change to check signatures
    sed -ie 's/nasl_no_signature_check = yes/nasl_no_signature_check = no/' /etc/openvas/openvas.conf;
    /usr/bin/logger 'configure_feed_validation() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_feed_validation() finished\e[0m";
}

configure_permissions() {
    /usr/bin/logger 'configure_permissions' -t 'ce-2024-11-28';
    echo -e "\e[1;32mconfigure_permissions()\e[0m";
    /usr/bin/logger '..Setting correct ownership of files for user gvm' -t 'ce-2024-11-28';
    echo -e "\e[1;36m...configuring permissions for GSE\e[0m";
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
    echo -e "\e[1;32mconfigure_permissions() finished\e[0m";
    /usr/bin/logger 'configure_permissions finished' -t 'ce-2024-11-28';
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'ce-2024-11-28';
    mkdir /opt/gvm/scripts > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/scripts/ > /dev/null 2>&1;
    cat << __EOF__  > /opt/gvm/scripts/gvm-tasks.py
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
__EOF__
    sync;
    /usr/bin/logger 'create_gvm_python_script finished' -t 'ce-2024-11-28';
}

update_openvas_feed () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'ce-2024-11-28';
    echo -e "\e[1;32mupdate_openvas_feed()\e[0m";
    echo -e "\e[1;36m...updating NVT information on $HOSTNAME\e[0m";
    # Clean up redis, then update all VT information > /dev/null 2>&1;
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info' > /dev/null 2>&1;
    echo -e "\e[1;32mupdate_openvas_feed() finished\e[0m";
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'ce-2024-11-28';
}

install_openvas_from_github() {
    cd /opt/gvm/src/greenbone/
    rm -rf openvas
    git clone https://github.com/greenbone/openvas-scanner.git
    mv ./openvas-scanner ./openvas;
}

toggle_vagrant_nic() {
    /usr/bin/logger 'toggle_vagrant_nic()' -t 'ce-2024-11-28';
    echo -e "\e[1;32mtoggle_vagrant_nic()\e[0m";
    echo -e "\e[1;32mis this started by Vagrant\e[0m";
    
    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'ifdown eth0' -t 'ce-2024-11-28';
        echo -e "\e[1;32mifdown eth0\e[0m";
        ifdown eth0 > /dev/null 2>&1;
        /usr/bin/logger 'ifup eth0' -t 'ce-2024-11-28';
        echo -e "\e[1;32mifup eth0\e[0m";
        ifup eth0 > /dev/null 2>&1;
    else
        echo -e "\e[1;32mNot running Vagrant, nothing to do\e[0m";
    fi
    
    echo -e "\e[1;32mtoggle_vagrant_nic() finished\e[0m";
    /usr/bin/logger 'toggle_vagrant_nic() finished' -t 'ce-2024-11-28';
}

remove_vagrant_nic() {
    /usr/bin/logger 'remove_vagrant_nic()' -t 'ce-2024-11-28';
    echo -e "\e[1;32mremove_vagrant_nic()\e[0m";
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";

    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'Remove Vagrant eth0' -t 'ce-2024-11-28';
        echo -e "\e[1;32mStarted by Vagrant remove Vagrant NIC\e[0m";
    cat << __EOF__ > /etc/network/interfaces;
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*
# The primary network interface
auto lo
iface lo inet loopback
#iface eth0 inet dhcp
pre-up sleep 2
auto eth1
iface eth1 inet dhcp
__EOF__
    ifdown eth1 > /dev/null 2>&1; ifup eth1 > /dev/null 2>&1;

    else
        echo -e "\e[1;32mNot running Vagrant, nothing to do\e[0m";
    fi
    /usr/bin/logger 'remove_vagrant_nic() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mremove_vagrant_nic() finished\e[0m";
}

remove_vagrant_user() {
    /usr/bin/logger 'remove_vagrant_user()' -t 'ce-2024-11-28';
    echo -e "\e[1;32mremove_vagrant_user()\e[0m";
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";

    if test -f "/etc/VAGRANT_ENV"; then
        echo -e "\e[1;32m...locking vagrant users password\e[0m";
        passwd --lock vagrant > /dev/null 2>&1;
        echo -e "\e[1;32m...deleting vagrant user\e[0m";
        userdel vagrant;
        echo -e "\e[1;32m...deleting /etc/VAGRANT_ENV file\e[0m";
        rm /etc/VAGRANT_ENV > /dev/null 2>&1;
    else
        echo -e "\e[1;32mNot running Vagrant, nothing to do\e[0m";
    fi
    /usr/bin/logger 'remove_vagrant_user() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mremove_vagrant_user() finished\e[0m";
}

create_openvas_version_script() {
    /usr/bin/logger 'create_openvas_version_script()' -t 'ce-2024-11-28';
    echo -e "\e[1;32mcreate_openvas_version_script()\e[0m";
    mkdir /opt/gvm/scripts;
    cat << __EOF__  > /opt/gvm/scripts/feed-version.sh
#!/bin/bash
echo -e "\$HOSTNAME OpenVAS Feed Version:\e[1;32m" \$(grep PLUGIN_SET /var/lib/openvas/plugins/plugin_feed_info.inc | cut -c 15-26) "\e[0m"
__EOF__
    sync
    chown -R gvm:gvm /opt/gvm/scripts;
    chmod 755 /opt/gvm/scripts/*.sh;
    /usr/bin/logger 'create_openvas_version_script() finished' -t 'ce-2024-11-28';
    echo -e "\e[1;32mcreate_openvas_version_script() finished\e[0m";
}

create_wrapper() {
    echo -e "\e[1;32mcreate_wrapper()\e[0m";
    /usr/bin/logger 'create_wrapper' -t 'ce-2024-11-28';
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
    /usr/bin/logger 'create_wrapper finished' -t 'ce-2024-11-28';
}

check_valkey() {
    /usr/bin/logger 'check_valkey' -t 'gce-2024-04-14';
    echo -e "\e[1;32mcheck_valkey()\e[0m";
    # Check status of service valkey-server.service
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking valkey-server.service......\e[0m";
    if systemctl is-active --quiet valkey-server.service;
    then
        echo -e "\e[1;32mvalkey-server.service started successfully";
        /usr/bin/logger 'valkey-server.service started successfully' -t 'gce-2024-04-14';
        export VALKEY_REPLY=$(valkey-cli -s /run/valkey/valkey.sock PING);
	#echo $VALKEY_REPLY;
	if [ $VALKEY_REPLY == "PONG" ]
        then
            echo -e "\e[1;32mvalkey responding successfully with \e[1;35m$VALKEY_REPLY\e[1;32m on socket \e[1;35m$VALKEY_SOCKET\e[0m";
            /usr/bin/logger "valkey responding successfully with $VALKEY_REPLY on socket $VALKEY_SOCKET" -t 'gce-2024-04-14';
        else
            echo -e "\e[1;32mvalkey not responding on socket $VALKEY_SOCKET";
            /usr/bin/logger "valkey not responding on socket $VALKEY_SOCKET" -t 'gce-2024-04-14';
        fi
    else
        echo -e "\e[1;31mvalkey-server.service FAILED\e[0m";
        /usr/bin/logger 'valkey-server.service FAILED' -t 'gce-2024-04-14';
    fi
    /usr/bin/logger 'check_valkey finished' -t 'gce-2024-04-14';
}

run_once() {
    /usr/bin/logger 'run_once' -t 'gce-2024-04-14';
    echo -e "\e[1;32mrun_once()\e[0m";

    mkdir -p /etc/local/runonce.d/ran
    cat << __EOF__  > /usr/local/bin/runonce.sh
#!/bin/bash
for file in /etc/local/runonce.d/*
do
    if [ ! -f "$file" ]
    then
        continue
    fi
    "$file"
    mv "$file" "/etc/local/runonce.d/ran/$file.$(date +%Y%m%dT%H%M%S)"
    logger -t runonce -p local3.info "$file"
done
__EOF__

    chmod 755 /usr/local/bin/runonce.sh

    cat << __EOF__  > /etc/local/runonce.d/scan_update.sh
#!/bin/bash
/opt/gvm/gvmpy/bin/greenbone-feed-sync --type $feedtypescanner --config /etc/gvm/greenbone-feed-sync.toml > /dev/null 2>&1;
__EOF__

    chmod 755 /etc/local/runonce.d/scan_update.sh

    /usr/bin/logger 'run_once finished' -t 'gce-2024-04-14';
    echo -e "\e[1;32mrun_once() finished\e[0m";
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32mSecondary Server Install main()\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36m...Starting installation of secondary Greenbone Community Edition Server version 23.1.0\e[0m"
    echo -e "\e[1;36m...$HOSTNAME will run ospd-openvas, openvas-scanner, and notus-scanners only, managed from a primary\e[0m"
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    # Shared variables
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    # Check if started by Vagrant
    /usr/bin/logger 'Vagrant Environment Check for file' -t 'ce-2024-11-28';
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";
    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'Use .env file in HOME' -t 'ce-2024-11-28';
        echo -e "\e[1;32mUse .env file in home\e[0m";
        export ENV_DIR=$HOME;
    else
        /usr/bin/logger 'Use .env file SCRIPT_DIR' -t 'ce-2024-11-28';
        echo -e "\e[1;32mUse .env file in SCRIPT_DIR\e[0m";
        export ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    fi

    # Configure environment from env file
    set -a; source $ENV_DIR/.env;
    echo -e "\e[1;36m....env file version $ENV_VERSION used\e[0m"

    # Vagrant acts up at times with eth0, so check if running Vagrant and toggle it down/up
    toggle_vagrant_nic;

    # Shared components
    install_prerequisites;
    prepare_nix;
    prepare_source;
    prepare_gvmpy;
    create_wrapper;

    # Installation of specific components
    # Only install poetry when testing
    #install_poetry;
    install_gvm_libs;
    # Temporary Workaround updating Libxml to newer version from source until Greenbone update to use Fix: Parse XML with XML_PARSE_HUGE
    #install_libxml2;
    install_openvas_smb;
    #install_openvas_from_github;
    install_openvas;
    install_ospd_openvas;
    install_notus;
    install_greenbone_feed_sync;
    prepare_gpg;
 
    # Configuration of installed components
    configure_openvas;

   # valkey or redis
    if [ $VALKEY_INSTALL == "Yes" ]
        then
            echo -e "\e[1;32Valkey v$VALKEY replacing Redis\e[0m";
            install_valkey;
            configure_valkey;
        else 
            echo -e "\e[1;32mRedis despite new license, consider valkey\e[0m";
            apt-get -qq -y install redis-server > /dev/null 2>&1;
            configure_redis;
        fi
            
    configure_feed_validation;
    # Prestage only works on the specific Vagrant lab where a scan-data tar-ball is copied to the Host. 
    # Update scan-data only from greenbone when used everywhere else 
    prestage_scan_data;
    configure_greenbone_updates;
    configure_permissions;
    #update_feed_data;
    run_once;
    #update_openvas_feed;
    start_services;
    check_valkey;
    create_scan_user;
    clean_env;
    remove_vagrant_nic;
    remove_vagrant_user;
    create_openvas_version_script;
    echo -e;
    echo -e "\e[1;32m****************************************************************************************************\e[0m";
    echo -e "\e[1;36m  Run add-secondary-2-primary on the primary server to configure this secondary\e[0m";
    echo -e "\e[1;36m  You will need hostname: \e[1;33m$HOSTNAME\e[0m and password: \e[1;33m$greenbone_secret\e[0m";
    echo -e "\e[1;32m****************************************************************************************************\e[0m";
    echo -e;
    /usr/bin/logger 'Installation complete - will reboot in 10 seconds' -t 'ce-2024-11-28';
    echo -e "\e[1;32mSecondary Server Install main() finished\e[0m";
    sync; sleep 10; systemctl reboot;
}

main;

exit 0;
