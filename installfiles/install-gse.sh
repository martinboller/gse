#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Instruction:  Run this script as root on a fully updated                  #
#               Debian 11 (Bullseye) or Debian 12 (Bookworm)                #
#                                                                           #
#############################################################################


install_prerequisites() {
    /usr/bin/logger 'install_prerequisites' -t 'gce-2024-06-29';
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
    DISTRIBUTION=$VERSION_CODENAME
    /usr/bin/logger "Operating System $OS Version $VER Codename $CODENAME" -t 'gce-2024-06-29';
    export DISTRIBUTION="$(lsb_release -s -c)"
    echo -e "\e[1;36m...Operating System $OS Version $VER Codename $CODENAME\e[0m";
    # Install prerequisites
    # Some APT gymnastics to ensure it is all cleaned up
    apt-get -qq update > /dev/null 2>&1;
    #apt-get -qq -y install --fix-broken > /dev/null 2>&1;
    #apt-get -qq -y install --fix-missing > /dev/null 2>&1;
    # Install some basic tools on a Debian net install
    echo -e "\e[1;36m...install tools not available if installed from Debian net-install\e[0m";
    /usr/bin/logger '..install some basic tools not available if installed from Debian net install' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...fix-policy for apt\e[0m";
    #apt-get -qq -y install --fix-policy > /dev/null 2>&1;
    echo -e "\e[1;36m...installing required packages\e[0m";
    apt-get -qq -y install adduser wget whois build-essential devscripts git unzip zip apt-transport-https ca-certificates \
        curl gnupg2 software-properties-common dnsutils dirmngr --install-recommends  > /dev/null 2>&1;

    # For development (unit tests)
    #apt-get -qq -y install libcgreen1 > /dev/null 2>&1;
    # Install pre-requisites for 
    # libunistring is a new requirement from oct-13 updates
    /usr/bin/logger '..Tools for Development' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...installing required development tools\e[0m";
    apt-get -qq -y install openssh-client gpgsm dpkg xmlstarlet libbsd-dev libjson-glib-dev libpaho-mqtt-dev gcc pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev \
        libgcrypt20-dev libunistring-dev libxml2-dev > /dev/null 2>&1;
    # Install pre-requisites for gsad
    /usr/bin/logger '..Prerequisites for Greenbone Security Assistant' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...prerequisites for Greenbone Security Assistant\e[0m";
    apt-get -qq -y install libmicrohttpd-dev clang cmake > /dev/null 2>&1;
    apt-get -qq -y install python3 python3-pip python3-setuptools python3-psutil python3-gnupg python3-venv python3-wheel > /dev/null 2>&1;

    # Other pre-requisites for GSE
    echo -e "\e[1;36m...other prerequisites for Greenbone Community Edition\e[0m";

    if [ $VER -eq "12" ] 
        then
            /usr/bin/logger '..install prerequisites Debian 12 Bookworm' -t 'gce-2024-06-29';
            echo -e "\e[1;36m...install prerequisites Debian 12 Bookworm\e[0m";
            # Going with default debian 12 package (node 18.x)
            # Install pre-requisites for gvmd on bookworm (debian 12)
            apt update > /dev/null 2>&1;
            apt-get -qq -y install doxygen mosquitto gcc cmake libnet1-dev libglib2.0-dev libgnutls28-dev libpq-dev postgresql-contrib postgresql postgresql-server-dev-all \
                postgresql-server-dev-15 pkg-config libical-dev xsltproc > /dev/null 2>&1;        
            # Removed doxygen for now
            # Other pre-requisites for GSE - Bullseye / Debian 11
            /usr/bin/logger '....Other prerequisites for Greenbone Community Edition on Debian 12' -t 'gce-2024-06-29';
            echo -e "\e[1;36m...installing prerequisites for Greenbone Community Edition\e[0m";
            apt-get -qq -y install software-properties-common libgpgme11-dev uuid-dev libgnutls28-dev libgpgme-dev \
                bison libksba-dev libsnmp-dev libgcrypt20-dev gnutls-bin nmap xmltoman gcc-mingw-w64 graphviz nodejs rpm nsis \
                sshpass socat gettext python3-polib libldap2-dev libradcli-dev libpq-dev perl-base heimdal-dev libpopt-dev \
                python3-psutil fakeroot gnupg socat snmp smbclient rsync python3-paramiko python3-lxml \
                    python3-defusedxml python3-pip python3-psutil virtualenv python3-impacket python3-scapy cmdtest npm > /dev/null 2>&1;
            echo -e "\e[1;36m...installing yarn\e[0m";
            apt-get -qq -y install libhiredis-dev gcc pkg-config libssh-4 libssh-dev libgnutls28-dev libglib2.0-dev libjson-glib-dev libpcap-dev libgpgme-dev bison libksba-dev libsnmp-dev libgcrypt20-dev libbsd-dev libcurl4-gnutls-dev > /dev/null 2>&1;
            apt-get -qq -y install libcjson-dev pnscan > /dev/null 2>&1;
        else
            /usr/bin/logger "..Unsupported Debian version $OS $VER $CODENAME $DISTRIBUTION" -t 'gce-2024-06-29';
            echo -e "\e[1;36m...Unsupported Debian version $OS $VER $CODENAME $DISTRIBUTION\e[0m";
            exit;
        fi
    
    /usr/bin/logger '..install prerequisites finished' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...install prerequisites finished\e[0m";
     
     # Speed up installation without texlive (but then PDF reports wont work)
    if [ "$TEXLIVE_INSTALL" == "Yes" ]; then
    # Required for PDF report generation
       /usr/bin/logger '....Prerequisites for PDF report generation' -t 'gce-2024-06-29';
        echo -e "\e[1;36m...installing texlive required for PDF report generation\e[0m";
        echo -e "\e[1;36m...please be patient, this could take quite a while depending on your system\e[0m";
        apt-get -qq -y install texlive-latex-extra --no-install-recommends > /dev/null 2>&1;
        apt-get -qq -y install texlive-fonts-recommended > /dev/null 2>&1;
        #apt-get -qq -y install texlive-full texlive-fonts-recommended > /dev/null 2>&1;
    else
        echo -e "\e[1;32mNot installing texlive, you won't be able to create PDF-reports\e[0m";
    fi
   
    # Install other preferences and clean up APT
    /usr/bin/logger '....Install some preferences on Debian and clean up apt' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...installing some preferences on Debian\e[0m";
    apt-get -qq -y install bash-completion haveged > /dev/null 2>&1;
    # Install SUDO
    apt-get -qq -y install sudo > /dev/null 2>&1;
    # A little apt 
    echo -e "\e[1;36m...cleaning up apt\e[0m";
    #apt-get -qq -y install --fix-missing > /dev/null 2>&1;
    apt-get -qq update > /dev/null 2>&1;
    apt-get -qq -y full-upgrade > /dev/null 2>&1;
    #apt-get -qq -y autoremove --purge > /dev/null 2>&1;
    #apt-get -qq -y autoclean > /dev/null 2>&1;
    #apt-get -qq -y clean > /dev/null 2>&1;
    # Python pip packages
    echo -e "\e[1;36m...installing python and python-pip\e[0m";
    apt-get -qq -y install python3-pip python-wheel-common > /dev/null 2>&1;
    python3 -m pip install --upgrade pip > /dev/null 2>&1;
    # Prepare directories for scan feed data
    echo -e "\e[1;36m...preparing directories for scan feed data\e[0m";
    mkdir -p /var/lib/gvm/private/CA > /dev/null 2>&1;
    mkdir -p /var/lib/gvm/CA > /dev/null 2>&1;
    mkdir -p /var/lib/openvas/plugins > /dev/null 2>&1;
    # logging
    echo -e "\e[1;36m...preparing directories for logs\e[0m";
    mkdir -p /var/log/gvm/ > /dev/null 2>&1;
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    timedatectl set-timezone UTC  > /dev/null 2>&1;
    echo -e "\e[1;32minstall_prerequisites() finished\e[0m";
    /usr/bin/logger 'install_prerequisites finished' -t 'gce-2024-06-29';
}

clean_env() {
    /usr/bin/logger 'clean_env()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mclean_env()\e[0m";
    ## Deleting file with variables environment variables from env
    rm $ENV_DIR/.env > /dev/null 2>&1;
    /usr/bin/logger 'clean_env() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mclean_env() finished\e[0m";
}

prepare_nix() {
    /usr/bin/logger 'prepare_nix()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_nix()\e[0m";
    echo -e "\e[1;32mCreating Users, configuring sudoers, and setting locale\e[0m";
    # set desired locale
    echo -e "\e[1;36m...configuring locale\e[0m";
    localectl set-locale en_US.UTF-8 > /dev/null 2>&1;
    # Create gvm user
    echo -e "\e[1;36m...creating Greenbone Vulnerability Manager linux user gvm\e[0m";
    /usr/sbin/useradd --system --create-home --home-dir /opt/gvm/ -c "gvm User" --groups sudo --shell /bin/bash gvm > /dev/null 2>&1;
    mkdir /opt/gvm > /dev/null 2>&1;
    chown gvm:gvm /opt/gvm;
    # create user for valkey if required

    if [ $VALKEY_INSTALL == "Yes" ]
        then
            echo -e "\e[1;36m...creating valkey user\e[0m";
            /usr/sbin/useradd --system -c "Valkey User" --shell /bin/bash valkey > /dev/null 2>&1;
        fi

    # Update the PATH environment variable
    cat << __EOF__ > /etc/profile.d/gvm.sh
# Add GVM library path to /etc/ld.so.conf.d
PATH=\$PATH:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/gvmpy/bin
# Lib XML issues when the feeds grew beyond the original limit in lib xml. Solved in newer builds.
export LIBXML_MAX_NODESET_LENGTH=40000000
__EOF__

    echo -e "\e[1;36m...configuring ld for greenbone libraries\e[0m";
    cat << __EOF__ > /etc/ld.so.conf.d/greenbone.conf;
# Greenbone libraries
/opt/gvm/lib
/opt/gvm/include
__EOF__

    echo -e "\e[1;36m...creating sudoers.d/greenbone file\e[0m";
# sudoers.d to run openvas as root
    cat << __EOF__ > /etc/sudoers.d/greenbone
gvm     ALL = NOPASSWD: /opt/gvm/sbin/openvas

Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gvm/sbin"
__EOF__
    # It appears that GVMD sometimes delete /run/gvmd so added a subfolder (/gse) to prevent this
    echo -e "\e[1;36m...configuring tmpfiles.d for greenbone run files\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/greenbone.conf
d /run/gsad 1775 gvm gvm
d /run/gvmd 1775 gvm gvm
d /run/gvmd/gse 1775 root root
d /run/ospd 1775 gvm gvm
d /run/ospd/gse 1775 root root
__EOF__
    # start systemd-tmpfiles to create directories as specificed in tmpfiles.d/greenbone.conf
    echo -e "\e[1;36m...starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    echo -e "\e[1;32mprepare_nix() finished\e[0m";
    /usr/bin/logger 'prepare_nix() finished' -t 'gce-2024-06-29';
}

prepare_source() {    
    /usr/bin/logger 'prepare_source' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_source()\e[0m";
    echo -e "\e[1;32mPreparing GSE Source files\e[0m";
    echo -e "\e[1;36m...Installing as specified in the env file\e[0m";
    echo -e "\e[1;36m...Certificate Organization: $GVM_CERTIFICATE_ORG\e[0m";
    echo -e "\e[1;32mInstalling the following GCE versions\e[0m";
    echo -e "\e[1;35m----------------------------------"
    echo -e "\e[1;35mgvmlibs \t\t\t $GVMLIBS"
    echo -e "\e[1;35mospd-openvas \t\t $OSPDOPENVAS"
    echo -e "\e[1;35mopenvas-scanner \t\t $OPENVAS"
    echo -e "\e[1;35mgvm daemon \t\t $GVMD"
    echo -e "\e[1;35mGSA Daemon \t\t $GSAD"
    echo -e "\e[1;35mGSA Web \t\t\t $GSA"
    echo -e "\e[1;35mopenvas-smb \t\t $OPENVASSMB"
    echo -e "\e[1;35mpython-gvm \t\t $PYTHONGVM"
    echo -e "\e[1;35mgvm-tools \t\t $GVMTOOLS"
    echo -e "\e[1;35mpostgre gvm (pg-gvm) \t $POSTGREGVM"
    echo -e "\e[1;35mnotus-scanner \t\t $NOTUS"
    echo -e "\e[1;35mfeed-sync \t\t $FEEDSYNC"
    echo -e "\e[1;35m----------------------------------\e[0m";
    echo -e "\e[1;36m...preparing directories\e[0m";
    mkdir -p /opt/gvm/src/greenbone > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/src/greenbone > /dev/null 2>&1;
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #Get all packages (the python elements can be installed w/o, but downloaded and used for install anyway)
    /usr/bin/logger '..gvm libraries' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...downloading released packages for Greenbone Community Edition\e[0m";
    /usr/bin/logger '..gvm-libs' -t 'gce-2024-06-29';
    wget -O gvm-libs.tar.gz https://github.com/greenbone/gvm-libs/archive/refs/tags/v$GVMLIBS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..ospd-openvas' -t 'gce-2024-06-29';
    wget -O ospd-openvas.tar.gz https://github.com/greenbone/ospd-openvas/archive/refs/tags/v$OSPDOPENVAS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-scanner' -t 'gce-2024-06-29';
    wget -O openvas.tar.gz https://github.com/greenbone/openvas-scanner/archive/refs/tags/v$OPENVAS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm daemon' -t 'gce-2024-06-29';
    wget -O gvmd.tar.gz https://github.com/greenbone/gvmd/archive/refs/tags/v$GVMD.tar.gz > /dev/null 2>&1;
    # Note: gvmd 22.5.2 and 22.5.3 spawns a huge number of instances and exhaust system resources 
    /usr/bin/logger '..gsa daemon (gsad)' -t 'gce-2024-06-29';
    wget -O gsad.tar.gz https://github.com/greenbone/gsad/archive/refs/tags/v$GSAD.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gsa webserver' -t 'gce-2024-06-29';
    wget -O gsa.tar.gz https://github.com/greenbone/gsa/archive/refs/tags/v$GSA.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..openvas-smb' -t 'gce-2024-06-29';
    wget -O openvas-smb.tar.gz https://github.com/greenbone/openvas-smb/archive/refs/tags/v$OPENVASSMB.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..python-gvm' -t 'gce-2024-06-29';
    wget -O pythongvm.tar.gz https://github.com/greenbone/python-gvm/archive/refs/tags/v$PYTHONGVM.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..gvm-tools' -t 'gce-2024-06-29';
    wget -O gvm-tools.tar.gz https://github.com/greenbone/gvm-tools/archive/refs/tags/v$GVMTOOLS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..pg-gvm' -t 'gce-2024-06-29';
    wget -O pg-gvm.tar.gz https://github.com/greenbone/pg-gvm/archive/refs/tags/v$POSTGREGVM.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..notus-scanner' -t 'gce-2024-06-29';
    wget -O notus.tar.gz https://github.com/greenbone/notus-scanner/archive/refs/tags/v$NOTUS.tar.gz > /dev/null 2>&1;
    /usr/bin/logger '..greenbone-feed-sync' -t 'gce-2024-06-29';
    wget -O greenbone-feed-sync.tar.gz https://github.com/greenbone/greenbone-feed-sync/archive/refs/tags/v$FEEDSYNC.tar.gz > /dev/null 2>&1;
    # valkey to replace redis
    /usr/bin/logger '..greenbone-feed-sync' -t 'gce-2024-11-25';
    wget -O valkey.tar.gz https://github.com/valkey-io/valkey/archive/refs/tags/$VALKEY.tar.gz > /dev/null 2>&1;
    
    # open and extract the tarballs
    echo -e "\e[1;36m...open and extract tarballs\e[0m";
    /usr/bin/logger '..open and extract the tarballs' -t 'gce-2024-06-29';
    find *.gz | xargs -n1 tar zxvfp > /dev/null 2>&1;
    sync;

    # Naming of directories w/o version
    /usr/bin/logger '..rename directories' -t 'gce-2024-06-29';    
    echo -e "\e[1;36m...renaming package directories\e[0m";
    mv /opt/gvm/src/greenbone/gvm-libs-$GVMLIBS /opt/gvm/src/greenbone/gvm-libs > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/ospd-openvas-$OSPDOPENVAS /opt/gvm/src/greenbone/ospd-openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-scanner-$OPENVAS /opt/gvm/src/greenbone/openvas > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvmd-$GVMD /opt/gvm/src/greenbone/gvmd > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gsa-$GSA /opt/gvm/src/greenbone/gsa > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gsad-$GSAD /opt/gvm/src/greenbone/gsad > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/openvas-smb-$OPENVASSMB /opt/gvm/src/greenbone/openvas-smb > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/python-gvm-$PYTHONGVM /opt/gvm/src/greenbone/python-gvm > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/gvm-tools-$GVMTOOLS /opt/gvm/src/greenbone/gvm-tools > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/pg-gvm-$POSTGREGVM /opt/gvm/src/greenbone/pg-gvm > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/notus-scanner-$NOTUS /opt/gvm/src/greenbone/notus > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/greenbone-feed-sync-$FEEDSYNC /opt/gvm/src/greenbone/greenbone-feed-sync > /dev/null 2>&1;
    mv /opt/gvm/src/greenbone/valkey-$VALKEY /opt/gvm/src/greenbone/valkey > /dev/null 2>&1;

    sync;
    echo -e "\e[1;36m...configuring permissions\e[0m";
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;32mprepare_source() finished\e[0m";
    /usr/bin/logger 'prepare_source finished' -t 'gce-2024-06-29';
}

install_libxml2() {
    /usr/bin/logger 'install_libxml2' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_libxml2()\e[0m";
    cd /opt/gvm/src;
    /usr/bin/logger '..git clone libxml2' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...git clone libxml2()\e[0m";
    git clone https://gitlab.gnome.org/GNOME/libxml2
    cd libxml2;
    /usr/bin/logger '..autogen libxml2' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...autogen libxml2()\e[0m";
    ./autogen.sh
    # /usr/bin/logger '..make libxml2' -t 'gce-2024-06-29';
    # echo -e "\e[1;36m...make libxml2()\e[0m";
    # make;
    /usr/bin/logger '..make install libxml2' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install libxml2()\e[0m";
    make install;
    /usr/bin/logger '..ldconfig libxml2' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...ldconfig libxml2()\e[0m";
    ldconfig;
}

install_poetry() {
    /usr/bin/logger 'install_poetry' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_poetry()\e[0m";
    export POETRY_HOME=/usr/poetry;
    # https://python-poetry.org/docs/
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 - > /dev/null 2>&1;
    echo -e "\e[1;32minstall_poetry() finished\e[0m";
    /usr/bin/logger 'install_poetry finished' -t 'gce-2024-06-29';
}

install_pggvm() {
    /usr/bin/logger 'install_pggvm' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_pggvm()\e[0m";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd pg-gvm/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    echo -e "\e[1;36m...cmake pg-gvm PostgreSQL server extension\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    #/usr/bin/logger '..make pg-gvm PostgreSQL server extension' -t 'gce-2024-06-29';
    #echo -e "\e[1;36m...make pg-gvm PostgreSQL server extension\e[0m";
    #make > /dev/null 2>&1;
    #/usr/bin/logger '..make pg-gvm libraries Documentation' -t 'gce-2024-06-29';
    #make doc-full;
    /usr/bin/logger '..make install pg-gvm PostgreSQL server extension' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install pg-gvm PostgreSQL server extension\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32minstall_pggvm() finished\e[0m";
    /usr/bin/logger 'install_pggvm finished' -t 'gce-2024-06-29';
}

install_notus() {
    /usr/bin/logger 'install_notus' -t 'gce-2024-06-29';
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
    /usr/bin/logger 'install_notus finished' -t 'gce-2024-06-29';
}

install_gvm_libs() {
    /usr/bin/logger 'install_gvmlibs' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_gvmlibs()\e[0m";
    cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    cd gvm-libs/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/ > /dev/null 2>&1;
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    /usr/bin/logger '..cmake Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...cmake Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    # /usr/bin/logger '..make Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gce-2024-06-29';
    # echo -e "\e[1;36m...make Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    # make > /dev/null 2>&1;
    #/usr/bin/logger '..make gvm libraries Documentation' -t 'gce-2024-06-29';
    #make doc-full;
    /usr/bin/logger '..make install Greenbone Vulnerability Manager libraries (gvm-libs)' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install gvm libraries\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...load Greenbone Vulnerability Manager libraries (gvm-libs)\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32minstall_gvmlibs() finished\e[0m";
    /usr/bin/logger 'install_gvmlibs finished' -t 'gce-2024-06-29';
}

install_python_gvm() {
    /usr/bin/logger 'install_python_gvm' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_python_gvm()\e[0m";
    # Installing from repo
    echo -e "\e[1;36m...installing python-gvm\e[0m";
    su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install python-gvm==$PYTHONGVM --use-pep517" > /dev/null 2>&1;
    #cd /opt/gvm/src/greenbone/ > /dev/null 2>&1;
    #cd python-gvm/ > /dev/null 2>&1;
    #su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1;
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32minstall_python_gvm() finished\e[0m";
    /usr/bin/logger 'install_python_gvm finished' -t 'gce-2024-06-29';
}

install_python_ical() {
    /usr/bin/logger 'install_python_ical()' -t 'gce-2024-06-29';
    # Required/useful for python-gvm (GMP) create_schedule
    # Installing from python repo
    su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install icalendar';
    /usr/bin/logger 'install_python_ical finished' -t 'gce-2024-06-29';
}

install_valkey() {
    /usr/bin/logger 'install_valkey' -t 'gce-2024-06-29';
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
    mkdir /etc/valkey/ > /dev/null 2>&1;
    mkdir /run/valkey/ > /dev/null 2>&1;
    chown -R valkey:valkey /run/valkey > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32minstall_valkey() finished\e[0m";
    /usr/bin/logger 'install_valkey finished' -t 'gce-2024-06-29';
}

install_openvas_smb() {
    /usr/bin/logger 'install_openvas_smb' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_openvas_smb()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #config and build openvas-smb
    cd openvas-smb > /dev/null 2>&1;
    echo -e "\e[1;36m...cmake OpenVAS SMB\e[0m";
    /usr/bin/logger '..cmake OpenVAS SMB' -t 'gce-2024-06-29';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    # /usr/bin/logger '..make OpenVAS SMB' -t 'gce-2024-06-29';
    # echo -e "\e[1;36m...make OpenVAS SMB\e[0m";
    # make > /dev/null 2>&1;                
    #/usr/bin/logger '..make Openvas SMB Documentation' -t 'gce-2024-06-29';
    #make doc-full;
    /usr/bin/logger '..make install OpenVAS SMB' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install OpenVAS SMB\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...load OpenVAS SMB libraries\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32minstall_openvas_smb() finished\e[0m";
    /usr/bin/logger 'install_openvas_smb finished' -t 'gce-2024-06-29';
}

install_ospd_openvas() {
    /usr/bin/logger 'install_ospd_openvas' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_ospd_openvas()\e[0m";
    echo -e "\e[1;36m...installing ospd-openvas\e[0m";
    # Install from repo
    echo -e "\e[1;36m...installing ospd-openvas workaround\e[0m";
    su gvm -c "source ~/gvmpy/bin/activate;python3 -m pip install ospd-openvas==$OSPDOPENVAS --use-pep517" > /dev/null 2>&1;
    #cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    #cd ospd-openvas > /dev/null 2>&1;
    #su gvm -c 'source ~/gvmpy/bin/activate;python3 -m pip install .' > /dev/null 2>&1;
    sync
    # For use when testing (just comment uncomment poetry install in "main" and here)
    #/usr/poetry/bin/poetry install;
    echo -e "\e[1;32minstall_ospd_openvas() finished\e[0m";
    /usr/bin/logger 'install_ospd_openvas finished' -t 'gce-2024-06-29';
}

install_openvas() {
    /usr/bin/logger 'install_openvas()' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_openvas()\e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Configure and build scanner
    cd openvas > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    /usr/bin/logger '..cmake OpenVAS Scanner' -t 'gce-2024-06-29';
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    echo -e "\e[1;36m...cmake OpenVAS Scanner\e[0m";
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    #/usr/bin/logger '..make OpenVAS Scanner' -t 'gce-2024-06-29';
    #/usr/bin/logger '..make Openvas Scanner Documentation' -t 'gce-2024-06-29';
    #make doc-full;
    # echo -e "\e[1;36m...make OpenVAS Scanner\e[0m";
    # # make it
    # make > /dev/null 2>&1;
    # build more developer-oriented documentation
    #make doc-full > /dev/null 2>&1; 
    /usr/bin/logger '..make install OpenVAS Scanner' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install openvas scanner\e[0m";
    make install > /dev/null 2>&1;
    /usr/bin/logger '..Rebuild make cache, OpenVAS Scanner' -t 'gce-2024-06-29';
    make rebuild_cache > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...load OpenVAS Scanner libraries\e[0m";
    ldconfig > /dev/null 2>&1;
    echo -e "\e[1;32minstall_openvas() finished\e[0m";
    /usr/bin/logger 'install_openvas finished' -t 'gce-2024-06-29';
}

install_gvm() {
    /usr/bin/logger 'install_gvm()' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_gvm()\e[0m";
    cd /opt/gvm/src/greenbone;
    # Build Manager
    cd gvmd/ > /dev/null 2>&1;
    /usr/bin/logger '..cmake GVM Daemon' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...cmake Greenbone Vulnerability Manager (GVM)\e[0m";
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    # /usr/bin/logger '..make GVM Daemon' -t 'gce-2024-06-29';
    # echo -e "\e[1;36m...make Greenbone Vulnerability Manager (GVM)\e[0m";
    # make > /dev/null 2>&1;
    #/usr/bin/logger '..make documentation for GVM Daemon' -t 'gce-2024-06-29';
    #make doc-full;
    /usr/bin/logger '..make install GVM Daemon' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install Greenbone Vulnerability Manager (GVM)\e[0m";
    make install > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32minstall_gvm() finished\e[0m";
    /usr/bin/logger 'install_gvm() finished' -t 'gce-2024-06-29';
}

install_nmap() {
    /usr/bin/logger 'install_nmap' -t 'gce-2024-06-29';
    cd /opt/gvm/src/greenbone;
    # Install NMAP
    apt-get -qq -y install nmap --fix-missing > /dev/null 2>&1;
    sync;
    /usr/bin/logger 'install_nmap finished' -t 'gce-2024-06-29';
}

install_greenbone_feed_sync() {
    /usr/bin/logger 'install_greenbone_feed_sync()' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_greenbone_feed_sync() \e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # install from source
    echo -e "\e[1;36m...installing greenbone-feed-sync\e[0m";
    #cd greenbone-feed-sync > /dev/null 2>&1;
    #su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1;
    su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install greenbone-feed-sync==$FEEDSYNC" > /dev/null 2>&1;
    /usr/bin/logger 'install_greenbone_feed_sync() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_greenbone_feed_sync() finished\e[0m";
}

prestage_scan_data() {
    /usr/bin/logger 'prestage_scan_data' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprestage_scan_data() \e[0m";
    # copy scan data to prestage ~1.5 Gib required otherwise
    # change this to copy from cloned repo
    cd /root/ > /dev/null 2>&1;
    /usr/bin/logger '..opening and extracting TAR Ball' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...opening and extracting TAR ball with prestaged feed data\e[0m";
    tar -xzf scandata.tar.gz > /dev/null 2>&1; 
    /usr/bin/logger '..copy feed data to /gvm/lib/gvm and openvas' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...copying feed data to correct locations\e[0m";
    /usr/bin/rsync -aAXv /root/GVM/openvas/ /var/lib/openvas/ > /dev/null 2>&1;
    #/bin/cp -r /root/GVM/openvas/* /var/lib/openvas/ > /dev/null 2>&1;
    /usr/bin/rsync -aAXv /root/GVM/gvm/scap-data /var/lib/gvm/ > /dev/null 2>&1;
    #/bin/cp -r /root/GVM/gvm/* /var/lib/gvm/ > /dev/null 2>&1;
    /usr/bin/rsync -aAXv /root/GVM/notus/ /var/lib/notus/ > /dev/null 2>&1;
    #/bin/cp -r /root/GVM/notus/* /var/lib/notus/ > /dev/null 2>&1;
    echo -e "\e[1;36m...Cleaning Up\e[0m";
    rm -rf /root/tmp/;
    echo -e "\e[1;32mprestage_scan_data() finished\e[0m";
    /usr/bin/logger 'prestage_scan_data finished' -t 'gce-2024-06-29';
}

update_feed_data() {
    /usr/bin/logger 'update_feed_data' -t 'gce-2024-06-29';
    echo -e "\e[1;32mupdate_feed_data() \e[0m";
    ## This relies on the configure_greenbone_updates script
    echo -e "\e[1;36m...updating feed data\e[0m";
    echo -e "\e[1;36m...This may take a few minutes, please wait...\e[0m";
    /opt/gvm/gvmpy/bin/greenbone-feed-sync --type all --config /etc/gvm/greenbone-feed-sync.toml > /dev/null 2>&1;
    echo -e "\e[1;32mupdate_feed_data() finished\e[0m";
    /usr/bin/logger 'update_feed_data finished' -t 'gce-2024-06-29';
}

install_gsad() {
    /usr/bin/logger 'install_gsad' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_gsad() \e[0m";
    ## Install GSA Daemon
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    # GSAD Install
    cd gsad/ > /dev/null 2>&1;
    /usr/bin/logger '..cmake Greenbone Security Assistant Daemon (GSAD)' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...cmake Greenbone Security Assistant Daemon (GSAD)\e[0m";
    export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH;
    cmake -DCMAKE_INSTALL_PREFIX=/opt/gvm . > /dev/null 2>&1;
    # /usr/bin/logger '..make GSA Daemon' -t 'gce-2024-06-29';
    # echo -e "\e[1;36m...make Greenbone Security Assistant Daemon (GSAD)\e[0m";
    # make > /dev/null 2>&1; # build the libraries
    #/usr/bin/logger '..make documentation for GSA Daemon' -t 'gce-2024-06-29';
    #make doc-full;       # build more developer-oriented documentation
    /usr/bin/logger '..make install GSA Daemon' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...make install Greenbone Security Assistant Daemon (GSAD)\e[0m";
    make install > /dev/null 2>&1;        # install the build
    sync;
    echo -e "\e[1;32minstall_gsad() finished\e[0m";
    /usr/bin/logger 'install_gsad finished' -t 'gce-2024-06-29';
}

install_gsa_web() {
    /usr/bin/logger 'install_gsa_web()' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_gsa_web() \e[0m";
    ## Install GSA
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    # GSA prerequisites
    # Terser is a new NPM requirement 
    npm add -D terser > /dev/null 2>&1;
    # GSA Install
    cd gsa/ > /dev/null 2>&1;
    /usr/bin/logger '..Build GSA Web Server' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...Build Web Server GSA\e[0m";
    echo -e "\e[1;36m...Running npm install\e[0m";
    npm install > /dev/null 2>&1;
    echo -e "\e[1;36m...Running npm run build\e[0m";
    npm run build > /dev/null 2>&1;
    sync > /dev/null 2>&1;
    echo -e "\e[1;36m...create web directory and copy web build there\e[0m";
    mkdir -p /opt/gvm/share/gvm/gsad/web/ > /dev/null 2>&1;
    cp -r build/* /opt/gvm/share/gvm/gsad/web/ > /dev/null 2>&1;
    echo -e "\e[1;32minstall_gsa_web() finished\e[0m";
    /usr/bin/logger 'install_gsa_web() finished' -t 'gce-2024-06-29';
}

browserlist_update(){
    /usr/bin/logger 'browserlist_update()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mbrowserlist_updat() \e[0m";
    cat << __EOF__ > /etc/cron.weekly/browserlistupdate
#!/bin/bash
npx browserslist@latest --update-db
/usr/bin/logger 'browserlist_update' -t 'gce-2024-06-29';
exit 0
__EOF__
    sync;
    chmod 744 /etc/cron.weekly/browserlistupdate > /dev/null 2>&1;
    echo -e "\e[1;32mbrowserlist_update() finished\e[0m";
    /usr/bin/logger 'browserlist_update() finished' -t 'gce-2024-06-29';
}

install_gvm_tools() {
    /usr/bin/logger 'install_gvm_tools' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_gvm_tools() \e[0m";
    cd /opt/gvm/src/greenbone > /dev/null 2>&1;
    # Install gvm-tools
    cd gvm-tools/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm > /dev/null 2>&1;
    echo -e "\e[1;36m...installing GVM-tools\e[0m";
    # From Python PyPi Repo
    su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install gvm-tools==$GVMTOOLS" > /dev/null 2>&1;
    # From downloaded sources
    #su gvm -c 'source ~/gvmpy/bin/activate; python3 -m pip install .' > /dev/null 2>&1;
#    /usr/poetry/bin/poetry install > /dev/null 2>&1;
    # Increase default timeouts from 60 secs to 600 secs
    export PY_VERSION="$(ls /opt/gvm/gvmpy/lib/)"
    sed -ie 's/DEFAULT_READ_TIMEOUT = 60/DEFAULT_TIMEOUT = 600/' /opt/gvm/gvmpy/lib/$PY_VERSION/site-packages/gvm/connections/_connection.py
    echo -e "\e[1;32minstall_gvm_tools() finished\e[0m";
    /usr/bin/logger 'install_gvm_tools finished' -t 'gce-2024-06-29';
}

install_impacket() {
    /usr/bin/logger 'install_impacket' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_impacket() \e[0m";
    # Install impacket
    su gvm -c "source ~/gvmpy/bin/activate; python3 -m pip install impacket==$IMPACKET" > /dev/null 2>&1;
    echo -e "\e[1;32minstall_impacket() finished\e[0m";
    /usr/bin/logger 'install_impacket finished' -t 'gce-2024-06-29';
}

prepare_gvmpy() {
    /usr/bin/logger 'prepare_gvmpy' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_gvmpy() \e[0m";
    su gvm -c 'cd ~; python3 -m pip install --upgrade pip; python3 -m pip install --user virtualenv; python3 -m venv gvmpy' > /dev/null 2>&1;
    /usr/bin/logger 'prepare_gvmpy finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_gvmpy() finished\e[0m";
}

prepare_postgresql() {
    /usr/bin/logger 'prepare_postgresql' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_postgresql() \e[0m";
    systemctl start postgresql.service;
    echo -e "\e[1;36m...create postgres user gvm";
    su postgres -c 'createuser -DRS gvm;'
    echo -e "\e[1;36m...create postgres user root";
    su postgres -c 'createuser -DRS root;'
    echo -e "\e[1;36m...create database";
    su postgres -c 'createdb -O gvm gvmd;'
    # Setup permissions.
    echo -e "\e[1;36m...setting postgres permissions";
    su postgres -c "psql gvmd -c 'create role dba with superuser noinherit;'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'grant dba to gvm;'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'grant dba to root;'" > /dev/null 2>&1;
    #   Create DB extensions (also necessary when the database got dropped).
    echo -e "\e[1;36m...create postgres extensions";
    su postgres -c 'psql gvmd -c "create extension \"uuid-ossp\";"' > /dev/null 2>&1;
    su postgres -c 'psql gvmd -c "create extension \"pgcrypto\";"' > /dev/null 2>&1;
    su postgres -c 'psql gvmd -c "create extension \"pg-gvm\";"' > /dev/null 2>&1;
    export PGSQL_VERSION="$(ls /etc/postgresql/)" > /dev/null 2>&1;
    # Disable JIT for postgresql
        cat << __EOF__ > /etc/postgresql/$PGSQL_VERSION/main/conf.d/99-nojit.conf
jit = off    
__EOF__

    echo -e "\e[1;32mprepare_postgresql() finished\e[0m";
    /usr/bin/logger 'prepare_postgresql finished' -t 'gce-2024-06-29';
}

tune_postgresql() {
    /usr/bin/logger 'tune_postgresql()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mtune_postgresql()\e[0m";

    echo -e "\e[1;36m...Setting optimized postgres values";
    ## These values are stored in /var/lib/postgresql/15/main/postgresql.auto.conf
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET max_connections = \"$pg_max_connections\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET shared_buffers = \"$pg_shared_buffers\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET effective_cache_size = \"$pg_effective_cache_size\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET maintenance_work_mem = \"$pg_maintenance_work_mem\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET checkpoint_completion_target = \"$pg_checkpoint_completion_target\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET wal_buffers = \"$pg_wal_buffers\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET default_statistics_target = \"$pg_default_statistics_target\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET random_page_cost = \"$pg_random_page_cost\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET effective_io_concurrency = \"$pg_effective_io_concurrency\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET work_mem = \"$pg_work_mem\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET huge_pages = \"$pg_huge_pages\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET min_wal_size = \"$pg_min_wal_size\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET max_wal_size = \"$pg_max_wal_size\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET max_worker_processes = \"$pg_max_worker_processes\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET max_parallel_workers_per_gather = \"$pg_max_parallel_workers_per_gather\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET max_parallel_workers = \"$pg_max_parallel_workers\"'" > /dev/null 2>&1;
    su postgres -c "psql gvmd -c 'ALTER SYSTEM SET max_parallel_maintenance_workers = \"$pg_max_parallel_maintenance_workers\"'" > /dev/null 2>&1;
    echo -e "\e[1;36m...Restarting PostgreSql";
    systemctl restart postgresql.service;

    /usr/bin/logger 'tune_postgresql() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mtune_postgresql() finished\e[0m";
}

configure_openvas() {
    /usr/bin/logger 'configure_openvas' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_openvas() \e[0m";
    mkdir /var/lib/notus/;
    chown -R gvm:gvm /var/lib/notus/;
    # Create openvas.conf file
    echo -e "\e[1;36m...create OpenVAS configuration file\e[0m";
    mkdir -p /etc/openvas/;
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
vendor_version = Greenbone Community Edition 23.1.0
plugins_folder = /var/lib/openvas/plugins
config_file = /etc/openvas/openvas.conf
max_hosts = 40
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
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
__EOF__

    echo "mqtt_server_uri = localhost:1883" | sudo tee -a /etc/openvas/openvas.conf 

    # Create OSPD-OPENVAS service
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
ExecStart=/opt/gvm/gvmpy/bin/ospd-openvas --config=/etc/ospd/ospd-openvas.conf --log-file=/var/log/gvm/ospd-openvas.log
# log level can be debug too, info is default
# This works asynchronously, but does not take the daemon down during the reload so it is ok.
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
__EOF__

    ## Configure ospd
    # Directory for ospd-openvas configuration file
    echo -e "\e[1;36m...create ospd-openvas configuration file\e[0m";
    mkdir -p /etc/ospd > /dev/null 2>&1;
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
    sync;
    echo -e "\e[1;32mconfigure_openvas() finished\e[0m";
    /usr/bin/logger 'configure_openvas finished' -t 'gce-2024-06-29';
}

configure_gvm() {
    /usr/bin/logger 'configure_gvm' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_gvm() \e[0m";
    # Create certificates
    echo -e "\e[1;36m...create certificates\e[0m";
    /opt/gvm/bin/gvm-manage-certs -a > /dev/null 2>&1;
    echo -e "\e[1;36m...create GVM service\e[0m";
    cat << __EOF__ > /lib/systemd/system/gvmd.service
[Unit]
Description=Greenbone Vulnerability Manager daemon (gvmd)
After=network.target networking.service postgresql.service ospd-openvas.service systemd-tmpfiles.service
Wants=postgresql.service ospd-openvas.service
Documentation=man:gvmd(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
User=gvm
#Group=gvm
PIDFile=/run/gvmd/gvmd.pid
RuntimeDirectory=gvmd
RuntimeDirectory=gvmd
# feed-update lock must be shared between ospd, gvmd, and greenbone-feed-sync
ExecStart=/usr/bin/wrapper /opt/gvm/sbin/gvmd /etc/gvm/gvmd.conf
#ExecStart=-/opt/gvm/sbin/gvmd --unix-socket=/run/gvmd/gvmd.sock --feed-lock-path=/run/gvmd/feed-update.lock --listen-group=gvm --client-watch-interval=0 --osp-vt-update=/run/ospd/ospd-openvas.sock
Restart=on-failure
RestartSec=10
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
Alias=greenbone-vulnerability-manager.service
__EOF__

    echo -e "\e[1;36m...create GVM config-file\e[0m";
    cat << __EOF__ > /etc/gvm/gvmd.conf
--unix-socket=/run/gvmd/gvmd.sock 
--feed-lock-path=/run/gvmd/feed-update.lock 
--listen-group=gvm 
--client-watch-interval=0 
--osp-vt-update=/run/ospd/ospd-openvas.sock
--scanner-connection-retry=5
__EOF__
    sync;
    echo -e "\e[1;32mconfigure_gvm() finished\e[0m";
    /usr/bin/logger 'configure_gvm() finished' -t 'gce-2024-06-29';
}

configure_gsa() {
    /usr/bin/logger 'configure_gsa' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_gsa() \e[0m";
    # Configure GSA daemon
    echo -e "\e[1;36m...create GSAD service\e[0m";
    cat << __EOF__ > /lib/systemd/system/gsad.service
[Unit]
Description=Greenbone Security Assistant daemon (gsad)
After=network.target networking.service gvmd.service
Documentation=man:gsad(8)
ConditionKernelCommandLine=!recovery

[Service]
Type=forking
#User=gvm
#Group=gvm
# With NGINX listen on 127.0.0.1 and http only (https through NGINX)
ExecStart=/usr/bin/wrapper /opt/gvm/sbin/gsad /etc/gsad/gsad.conf
#ExecStart=/opt/gvm/sbin/gsad --listen 127.0.0.1 --port=8443 --http-only
# --drop-privileges=gvm
# Without NGINX user: ExecStart=/opt/gvm/sbin/gsad --port=8443 --ssl-private-key=/var/lib/gvm/private/CA/serverkey.pem --ssl-certificate=/var/lib/gvm/CA/servercert.pem --munix-socket=/run/gvmd/gvmd.sock --no-redirect --secure-cookie --http-sts --timeout=60 --http-cors="https://%H:8443/" --gnutls-priorities=SECURE256:+SECURE128:-VERS-TLS-ALL:+VERS-TLS1.2
Restart=always
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
Alias=greenbone-security-assistant.service
__EOF__

    mkdir /etc/gsad/;
    cat << __EOF__ > /etc/gsad/gsad.conf
#--foreground
--drop-privileges=gvm
#--do-chroot
--no-redirect
--secure-cookie
--listen=127.0.0.1
--port=8443 
--http-only 
--timeout=2880
__EOF__
    sync;
    touch /var/log/gvm/gsad.log > /dev/null 2>&1;
    chown -R gvm:gvm /var/log/gvm/ > /dev/null 2>&1;
    echo -e "\e[1;32mconfigure_gsa() finished\e[0m";
    /usr/bin/logger 'configure_gsa finished' -t 'gce-2024-06-29';
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

configure_feed_owner() {
    /usr/bin/logger 'configure_feed_owner' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_feed_owner() \e[0m";
    echo "User $GVM_ADMINUSER for GVM $HOSTNAME " >> /var/lib/gvm/adminuser;
    echo -e "\e[1;36m...configuring feed owner\e[0m";
    if systemctl is-active --quiet gvmd.service;
    then
        su gvm -c "/opt/gvm/sbin/gvmd --create-user=$GVM_ADMINUSER" >> /var/lib/gvm/adminuser;
        su gvm -c '/opt/gvm/sbin/gvmd --get-users --verbose' > /var/lib/gvm/feedowner;
        awk -F " " {'print $2'} /var/lib/gvm/feedowner > /var/lib/gvm/uuid;
        # Ensure UUID is available in user gvm context
        su gvm -c 'cat /var/lib/gvm/uuid | xargs /opt/gvm/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $1'
        /usr/bin/logger 'configure_feed_owner User creation success' -t 'gce-2024-06-29';
    else
        echo "User admin for GVM $HOSTNAME could NOT be created - FAIL!" >> /var/lib/gvm/adminuser;
        /usr/bin/logger 'configure_feed_owner User creation FAILED!' -t 'gce-2024-06-29';
    fi
    echo -e "\e[1;32mconfigure_feed_owner() finished\e[0m";
    /usr/bin/logger 'configure_feed_owner finished' -t 'gce-2024-06-29';
}

configure_greenbone_updates() {
    /usr/bin/logger 'configure_greenbone_updates' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_greenbone_updates() \e[0m";
    # Configure daily GVM updates timer and service using the new grenbone-update-sync python code
    # Timer
    echo -e "\e[1;36m...create gce-update timer\e[0m";
    cat << __EOF__ > /lib/systemd/system/gce-update.timer
[Unit]
Description=Daily job to update vulnerability feeds

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
Description=gce feed updater
After=network.target networking.service
Documentation=man:gvmd(8)

[Service]
ExecStart=/opt/gvm/gvmpy/bin/greenbone-feed-sync --type $feedtype --config /etc/gvm/greenbone-feed-sync.toml
TimeoutSec=900

[Install]
WantedBy=multi-user.target
__EOF__

    cat << __EOF__ > /etc/gvm/greenbone-feed-sync.toml
[greenbone-feed-sync]
gvmd-lock-file = "$gvmdlockfile"
openvas-lock-file = "$gvmdlockfile"
user = "$feeduser"
group = "$feedgroup"
compression-level = $COMPRESSIONLEVEL
__EOF__

if [ "$ALTERNATIVE_FEED" == "Yes" ]; then
        cat << __EOF__ >> /etc/gvm/greenbone-feed-sync.toml
feed-url = "$FEED_URL"
__EOF__
    fi
    sync;
    echo -e "\e[1;32mconfigure_greenbone_updates() finished\e[0m";
    /usr/bin/logger 'configure_greenbone_updates finished' -t 'gce-2024-06-29';
}   

start_services() {
    /usr/bin/logger 'start_services' -t 'gce-2024-06-29';
    echo -e "\e[1;32mstart_services()\e[0m";
    # Load new/changed systemd-unitfiles
    echo -e "\e[1;36m...reload new and changed systemd unit files\e[0m";
    systemctl daemon-reload > /dev/null 2>&1;
    # Redis or Valkey
    if [ $VALKEY_INSTALL == "Yes" ]; then
         # Restart valkey with new config
        echo -e "\e[1;36m...restarting valkey service\e[0m";
        systemctl restart valkey.service > /dev/null 2>&1;
    else
        # Restart Redis with new config
        echo -e "\e[1;36m...restarting redis service\e[0m";
        systemctl restart redis.service > /dev/null 2>&1;
    fi
       # Enable GSE units
    echo -e "\e[1;36m...enabling notus-scanner service\e[0m";
    systemctl enable notus-scanner.service > /dev/null 2>&1;
    echo -e "\e[1;36m...enabling ospd-openvas service\e[0m";
    systemctl enable ospd-openvas.service > /dev/null 2>&1;
    echo -e "\e[1;36m...enabling gvmd service\e[0m";
    systemctl enable gvmd.service > /dev/null 2>&1;
    echo -e "\e[1;36m...enabling gsad service\e[0m";
    systemctl enable gsad.service > /dev/null 2>&1;
    # Start GSE units
    echo -e "\e[1;36m...restarting ospd-openvas service\e[0m";
    systemctl restart ospd-openvas > /dev/null 2>&1;
    echo -e "\e[1;36m...restarting notus-scanner service\e[0m";
    systemctl restart notus-scanner.service > /dev/null 2>&1;
    echo -e "\e[1;36m...restarting gvmd service\e[0m";
    systemctl restart gvmd.service > /dev/null 2>&1;
    echo -e "\e[1;36m...restarting gsad service\e[0m";
    systemctl restart gsad.service > /dev/null 2>&1;
    # Enable gce-update timer and service
    echo -e "\e[1;36m...enabling gce-update timer and service\e[0m";
    systemctl enable gce-update.timer > /dev/null 2>&1;
    systemctl enable gce-update.service > /dev/null 2>&1;
    # restart NGINX
    echo -e "\e[1;36m...restarting nginx service\e[0m";
    systemctl restart nginx.service > /dev/null 2>&1;
    # Will start after next reboot - may disturb the initial update
    echo -e "\e[1;36m...starting gce-update timer\e[0m";
    systemctl start gce-update.timer > /dev/null 2>&1;
    # Check status of critical services
    # gvmd.service
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking valkey/redis......\e[0m";
    if [ $VALKEY_INSTALL == "Yes" ]
        then
            if systemctl is-active --quiet valkey.service;
            then
                echo -e "\e[1;32mvalkey.service started successfully";
                /usr/bin/logger 'valkey.service started successfully' -t 'gce-2024-06-29';
            else
                echo -e "\e[1;31mvalkey.service FAILED!\e[0m";
                /usr/bin/logger 'valkey.service FAILED' -t 'gce-2024-06-29';
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
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;32mChecking core daemons for GSE......\e[0m";
    if systemctl is-active --quiet gvmd.service;
    then
        echo -e "\e[1;32mgvmd.service started successfully";
        /usr/bin/logger 'gvmd.service started successfully' -t 'gce-2024-06-29';
    else
        echo -e "\e[1;31mgvmd.service FAILED!\e[0m";
        /usr/bin/logger 'gvmd.service FAILED' -t 'gce-2024-06-29';
    fi
    # gsad.service
    if systemctl is-active --quiet gsad.service;
    then
        echo -e "\e[1;32mgsad.service started successfully";
        /usr/bin/logger 'gsad.service started successfully' -t 'gce-2024-06-29';
    else
        echo -e "\e[1;31mgsad.service FAILED!\e[0m";
        /usr/bin/logger "gsad.service FAILED!" -t 'gce-2024-06-29';
    fi
    # ospd-openvas.service
    if systemctl is-active --quiet ospd-openvas.service;
    then
        echo -e "\e[1;32mospd-openvas.service started successfully\e[0m";
        /usr/bin/logger 'ospd-openvas.service started successfully' -t 'gce-2024-06-29';
    else
        echo -e "\e[1;31mospd-openvas.service FAILED!";
        /usr/bin/logger 'ospd-openvas.service FAILED!\e[0m' -t 'gce-2024-06-29';
    fi
    # notus-secanner.service
    if systemctl is-active --quiet notus-scanner.service;
    then
        echo -e "\e[1;32mnotus-scanner.service started successfully\e[0m";
        /usr/bin/logger 'notus-scanner.service started successfully' -t 'gce-2024-06-29';
    else
        echo -e "\e[1;31mnotus-scanner.service FAILED!";
        /usr/bin/logger 'notus-scanner.service FAILED!\e[0m' -t 'gce-2024-06-29';
    fi
    if systemctl is-active --quiet gce-update.timer;
    then
        echo -e "\e[1;32mgce-update.timer started successfully\e[0m"
        /usr/bin/logger 'gce-update.timer started successfully' -t 'gce-2024-06-29';
    else
        echo -e "\e[1;31mgce-update.timer FAILED! Updates will not be automated\e[0m";
        /usr/bin/logger 'gce-update.timer FAILED! Updates will not be automated' -t 'gce-2024-06-29';
    fi
    echo -e "\e[1;32mstart_services() finished\e[0m";
    /usr/bin/logger 'start_services finished' -t 'gce-2024-06-29';
}

configure_redis() {
    /usr/bin/logger 'configure_redis' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_redis()\e[0m";
    echo -e "\e[1;36m...creating tmpfiles.d configuration for redis\e[0m";
    cat << __EOF__ > /etc/tmpfiles.d/redis.conf
d /run/redis 0755 redis redis
__EOF__
    # start systemd-tmpfiles to create directories
    echo -e "\e[1;36m...starting systemd-tmpfiles to create directories\e[0m";
    systemd-tmpfiles --create > /dev/null 2>&1;
    usermod -aG redis gvm;
    echo -e "\e[1;36m...creating redis configuration for Greenbone Community Edition\e[0m";
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
    echo -e "\e[1;36m...configuring sysctl for Greenbone Community Edition, Redis\e[0m";
    sysctl -w vm.overcommit_memory=$vm_overcommit_memory > /dev/null 2>&1;
    sysctl -w net.core.somaxconn=$net_core_somaxconn > /dev/null 2>&1;
    echo "vm.overcommit_memory=$vm_overcommit_memory" >> /etc/sysctl.d/60-gse-redis.conf;
    echo "net.core.somaxconn=$net_core_somaxconn" >> /etc/sysctl.d/60-gse-redis.conf;
    # Disable THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled;
    cat << __EOF__  > /etc/default/grub.d/99-transparent-huge-page.cfg
# Turns off Transparent Huge Page functionality as required by redis
GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=$transparent_hugepage"
__EOF__
    echo -e "\e[1;36m...updating grub\e[0m";
    update-grub > /dev/null 2>&1;
    sync;
    echo -e "\e[1;32mconfigure_redis() finished\e[0m";
    /usr/bin/logger 'configure_redis finished' -t 'gce-2024-06-29';
}

configure_valkey() {
    /usr/bin/logger 'configure_valkey' -t 'gce-2024-06-29';
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
daemonize yes
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

    cat << __EOF__  > /lib/systemd/system/valkey.service
[Unit]
Description=Valkey persistent key-value database
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=-/etc/default/valkey
ExecStart=/usr/local/bin/valkey-server /etc/valkey/valkey.conf --daemonize yes --supervised systemd $OPTIONS
Type=notify
User=valkey
Group=valkey
RuntimeDirectory=valkey
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
__EOF__

    # Redis requirements - overcommit memory and TCP backlog setting > 511
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
    systemctl enable valkey.service > /dev/null 2>&1;
    systemctl start valkey.service > /dev/null 2>&1;
    echo -e "\e[1;32mconfigure_valkey() finished\e[0m";
    /usr/bin/logger 'configure_valkey finished' -t 'gce-2024-06-29';
}

prepare_db_maintenance() {
    echo -e "\e[1;32mprepare_db_maintenance()\e[0m";
    /usr/bin/logger 'prepare_db_maintenance()' -t 'gce-2024-06-29';
    ## Weekly maintenance
    cat << __EOF__ > /etc/cron.weekly/gvmd-maintenance
su gvm -c '/opt/gvm/sbin/gvmd --optimize=analyze';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=cleanup-report-formats';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=cleanup-result-nvts';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=cleanup-config-prefs';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=cleanup-result-severities';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=update-report-cache';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=vacuum';
# End of maintenance
__EOF__

    ## Daily Maintenance
    cat << __EOF__  > /etc/cron.daily/gvmd-maintenance
su gvm -c '/opt/gvm/sbin/gvmd --optimize=analyze';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=cleanup-result-severities';
su gvm -c '/opt/gvm/sbin/gvmd --optimize=update-report-cache';
__EOF__
    chmod 755 /etc/cron.weekly/gvmd-maintenance
    chmod 755 /etc/cron.daily/gvmd-maintenance
    sync;
    echo -e "\e[1;32mprepare_db_maintenance() finished\e[0m";
    /usr/bin/logger 'prepare_db_maintenance() finished' -t 'gce-2024-06-29';
}

prepare_gpg() {
    /usr/bin/logger 'prepare_gpg' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_gpg()\e[0m";
    echo -e "\e[1;36m...Downloading and importing Greenbone Community Signing Key (PGP)\e[0m";
    /usr/bin/logger '..Downloading and importing Greenbone Community Signing Key (PGP)' -t 'gce-2024-06-29';
    curl -f -L https://www.greenbone.net/GBCommunitySigningKey.asc -o /tmp/GBCommunitySigningKey.asc > /dev/null 2>&1;
    echo -e "\e[1;36m...Fully trust Greenbone Community Signing Key (PGP)\e[0m";
    /usr/bin/logger '..Fully trust Greenbone Community Signing Key (PGP)' -t 'gce-2024-06-29';
    echo "8AE4BE429B60A59B311C2E739823FAA60ED1E580:6:" > /tmp/ownertrust.txt;
    sync; sleep 1;
    mkdir -p $GNUPGHOME > /dev/null 2>&1;
    gpg -q --import /tmp/GBCommunitySigningKey.asc;
    gpg -q --import-ownertrust < /tmp/ownertrust.txt;
    sudo mkdir -p $OPENVAS_GNUPG_HOME > /dev/null 2>&1;
    sudo cp -r $GNUPGHOME/* $OPENVAS_GNUPG_HOME/ > /dev/null 2>&1;
    sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME > /dev/null 2>&1;
    gpg -q --import-ownertrust < /tmp/ownertrust.txt;
    /usr/bin/logger 'prepare_gpg finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mprepare_gpg() finished\e[0m";
}

configure_feed_validation() {
    /usr/bin/logger 'configure_feed_validation()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_feed_validation()\e[0m";
    mkdir -p $GNUPGHOME
    gpg --import /tmp/GBCommunitySigningKey.asc
    gpg --import-ownertrust < /tmp/ownertrust.txt
    sudo mkdir -p $OPENVAS_GNUPG_HOME
    sudo cp -r /tmp/openvas-gnupg/* $OPENVAS_GNUPG_HOME/
    sudo chown -R gvm:gvm $OPENVAS_GNUPG_HOME
    # change to check signatures
    sed -ie 's/nasl_no_signature_check = yes/nasl_no_signature_check = no/' /etc/openvas/openvas.conf;
    /usr/bin/logger 'configure_feed_validation() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_feed_validation() finished\e[0m";
}

configure_permissions() {
    /usr/bin/logger 'configure_permissions' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_permissions()\e[0m";
    /usr/bin/logger '..Setting correct ownership of files for user gvm' -t 'gce-2024-06-29';
    echo -e "\e[1;36m...configuring permissions for Greenbone Community Edition\e[0m";
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
    chown -R gvm:gvm /var/lib/gvm
    chown -R gvm:gvm /var/lib/openvas
    chown -R gvm:gvm /var/lib/notus
    chown -R gvm:gvm /var/log/gvm
    chown -R gvm:gvm /run/gvmd
    chmod -R g+srw /var/lib/gvm
    chmod -R g+srw /var/lib/openvas
    chmod -R g+srw /var/log/gvm
    # NOTUS Feed
    chown -R gvm:gvm /var/lib/notus > /dev/null 2>&1;
    echo -e "\e[1;32mconfigure_permissions() finished\e[0m";
    /usr/bin/logger 'configure_permissions finished' -t 'gce-2024-06-29';
}

get_scanner_status() {
    /usr/bin/logger 'get_scanner_status()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mget_scanner_status()\e[0m";
    # Check status of Default scanners (Openvas and CVE).
    # These always have the well-known UUIDs used below. Additional scanners will have a random UUID
    # If returning "Failed to verify scanner" most likely GVMD cannot communicate with ospd-openvas.sock
    echo -e
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;36m...Checking default scanner connectivity.......";
    echo -e "\e[1;33m ... Local $(su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73')\e[0m";
    echo -e "\e[1;33m ... Local $(su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b')\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    # Write status to syslog too
    /usr/bin/logger ''Default OpenVAS $(su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73")'' -t 'gce-2024-06-29';    
    /usr/bin/logger ''Default CVE $(su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b")'' -t 'gce-2024-06-29';
    echo -e "\e[1;32mget_scanner_status() finished\e[0m";
}

create_gvm_python_script() {
    /usr/bin/logger 'create_gvm_python_script' -t 'gce-2024-06-29';
    echo -e "\e[1;32mcreate_gvm_python_script()\e[0m";
    echo -e "\e[1;36m...copying scripts and xml files\e[0m";
    git clone https://github.com/martinboller/greenbone-gmp-scripts.git /opt/gvm/scripts/ > /dev/null 2>&1;
    cp -r /root/XML-Files/ /opt/gvm/scripts/  > /dev/null 2>&1;
    sync;
    echo -e "\e[1;36m...cleaning home dir for root\e[0m";
    rm -rf /root/XML-Files/ > /dev/null 2>&1;
    rm -rf /root/gvm-cli-scripts/ > /dev/null 2>&1;
    chown -R gvm:gvm /opt/gvm/scripts/ > /dev/null 2>&1;
    chmod 755 /opt/gvm/scripts/*.py;
    sync;
    echo -e "\e[1;32mcreate_gvm_python_script() finished\e[0m";
    /usr/bin/logger 'create_gvm_python_script finished' -t 'gce-2024-06-29';
}

configure_cmake() {
    /usr/bin/logger 'configure_cmake' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_cmake()\e[0m";
    # Temporary workaround until CMAKE recognizes Postgresql 13
    echo -e "\e[1;36m...configuring cmake to recognize Postgresql v13\e[0m";
    sed -ie '1 s/^/set(PostgreSQL_ADDITIONAL_VERSIONS "13")\n/' /usr/share/cmake-3.18/Modules/FindPostgreSQL.cmake > /dev/null 2>&1;
    # Temporary workaround until CMAKE recognizes Postgresql 13
    echo -e "\e[1;32mconfigure_cmake() finished\e[0m";
   /usr/bin/logger 'configure_cmake finished' -t 'gce-2024-06-29';
}

update_openvas_feed () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    echo -e "\e[1;32mupdate_openvas_feed()\e[0m";
    echo -e "\e[1;36m...updating NVT information\e[0m";
    # Clean up redis, then update all VT information
    redis-cli -s /run/redis/redis.sock FLUSHALL > /dev/null 2>&1;
    valkey-cli -s /run/valkey/valkey.sock FLUSHALL > /dev/null 2>&1;
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info' > /dev/null 2>&1;
    echo -e "\e[1;32mupdate_openvas_feed() finished\e[0m";
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gse';
}

install_nginx() {
    /usr/bin/logger 'install_nginx()' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_nginx()\e[0m";
    echo -e "\e[1;36m...installing nginx and apache2 utils\e[0m";
    apt-get -qq -y install nginx apache2-utils > /dev/null 2>&1;
    echo -e "\e[1;32minstall_nginx() finished\e[0m";
    /usr/bin/logger 'install_nginx() finished' -t 'gce-2024-06-29';
}

configure_nginx() {
    /usr/bin/logger 'configure_nginx()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_nginx()\e[0m";
    echo -e "\e[1;36m...configuring diffie hellman parameters file\e[0m";
    openssl dhparam -out /etc/nginx/dhparam.pem 2048 > /dev/null 2>&1;
    # TLS
    echo -e "\e[1;36m...configuring site\e[0m";
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
    echo -e "\e[1;32mconfigure_nginx() finished\e[0m";
    /usr/bin/logger 'configure_nginx() finished' -t 'gce-2024-06-29';
}

nginx_certificates() {
    ## Use this if you want to create a request to send to corporate PKI for the web interface, also change the NGINX config to use that
    /usr/bin/logger 'nginx_certificates()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mnginx_certificates()\e[0m";
    ## NGINX stuff
    ## Required information for NGINX certificates
    echo -e "\e[1;36m...creating cert configuration file\e[0m";
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
    echo -e "\e[1;36m...generate CSR\e[0m";
    openssl req -new -config openssl.cnf -keyout /etc/nginx/certs/$HOSTNAME.key -out /etc/nginx/certs/$HOSTNAME.csr > /dev/null 2>&1;
    # generate self-signed certificate (remove when CSR can be sent to Corp PKI)
    echo -e "\e[1;36m...generate self-signed certificate\e[0m";
    openssl x509 -in /etc/nginx/certs/$HOSTNAME.csr -out /etc/nginx/certs/$HOSTNAME.crt -req -signkey /etc/nginx/certs/$HOSTNAME.key -days 365 > /dev/null 2>&1;
    chmod 600 /etc/nginx/certs/$HOSTNAME.key
    /usr/bin/logger 'nginx_certificates() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mnginx_certificates() finished\e[0m";
}

install_openvas_from_github() {
    cd /opt/gvm/src/greenbone/
    rm -rf openvas
    git clone https://github.com/greenbone/openvas-scanner.git
    mv ./openvas-scanner ./openvas;
}

install_exim() {
    ## Installs Exim4 to allow for sending GCE alerts over e-mail
    /usr/bin/logger 'install_exim()' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_exim()\e[0m";
    # remove postfix if installed
    apt-get -qq -y update > /dev/null 2>&1;
    apt-get -qq -y purge postfix* > /dev/null 2>&1;
    apt-get -qq -y update > /dev/null 2>&1;
    apt-get -qq -y install exim4 > /dev/null 2>&1;
    /usr/bin/logger 'install_exim() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32minstall_exim() finished\e[0m";    
}

configure_exim() {
    ## Configures Exim4 from the env variables specified
    /usr/bin/logger 'configure_exim()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_exim()\e[0m";
    echo -e "\e[32mconfigure_exim()\e[0m";
    echo -e "\e[36m-Configure exim4.conf.conf\e[0m";
    cat << __EOF__  > /etc/exim4/update-exim4.conf.conf
# This is a Debian Firewall specific file
dc_eximconfig_configtype='smarthost'
dc_other_hostnames='$MAIL_SERVER_DOMAIN'
dc_local_interfaces='127.0.0.1'
dc_readhost='$INTERNAL_DOMAIN'
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets='$RELAY_NETS'
dc_smarthost='$MAIL_SERVER::$MAIL_SERVER_PORT'
CFILEMODE='644'
dc_use_split_config='true'
dc_hide_mailname='true'
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
__EOF__

    echo -e "\e[36m-Configure mail access\e[0m";
    cat << __EOF__  > /etc/exim4/passwd.client
    # password file used when the local exim is authenticating to a remote
# host as a client.
#
# see exim4_passwd_client(5) for more documentation
$MAIL_SERVER:$MAIL_ADDRESS:$MAIL_PASSWORD
__EOF__

    echo -e "\e[36m-Configure mail addresses\e[0m";
    cat << __EOF__  > /etc/email-addresses
<my local user>: $MAIL_ADDRESS
root: $MAIL_ADDRESS
__EOF__
    # Time to reconfigure exim4
    dpkg-reconfigure -fnoninteractive exim4-config > /dev/null 2>&1;
    /usr/bin/logger 'configure_exim() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_exim() finished\e[0m";    
}

toggle_vagrant_nic() {
    /usr/bin/logger 'toggle_vagrant_nic()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mtoggle_vagrant_nic()\e[0m";
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";

    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'ifdown eth0' -t 'gce-2024-06-29';
        echo -e "\e[1;32mStarted by Vagrant ifdown eth0\e[0m";
        ifdown eth0 > /dev/null 2>&1;
        /usr/bin/logger 'ifup eth0' -t 'gce-2024-06-29';
        echo -e "\e[1;32mStarted by Vagrant, ifup eth0\e[0m";
        ifup eth0 > /dev/null 2>&1;
    else
        echo -e "\e[1;32mNot running Vagrant, nothing to do\e[0m";
    fi
    
    echo -e "\e[1;32mtoggle_vagrant_nic() finished\e[0m";
    /usr/bin/logger 'toggle_vagrant_nic() finished' -t 'gce-2024-06-29';
}

remove_vagrant_nic() {
    /usr/bin/logger 'remove_vagrant_nic()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mremove_vagrant_nic()\e[0m";
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";

    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'Remove Vagrant eth0' -t 'gce-2024-06-29';
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
    /usr/bin/logger 'remove_vagrant_nic() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mremove_vagrant_nic() finished\e[0m";
}

remove_vagrant_user() {
    /usr/bin/logger 'remove_vagrant_user()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mremove_vagrant_user()\e[0m";
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";

    if test -f "/etc/VAGRANT_ENV"; then
        echo -e "\e[1;32m...locking vagrant users password\e[0m";
        passwd --lock vagrant > /dev/null 2>&1;
        #echo -e "\e[1;32m...deleting vagrant user\e[0m";
        #userdel vagrant;
        echo -e "\e[1;32m...deleting /etc/VAGRANT_ENV file\e[0m";
        rm /etc/VAGRANT_ENV > /dev/null 2>&1;
    else
        echo -e "\e[1;32mNot running Vagrant, nothing to do\e[0m";
    fi
    /usr/bin/logger 'remove_vagrant_user() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mremove_vagrant_user() finished\e[0m";
}

configure_maxrows() {
    /usr/bin/logger 'configure_maxrows()' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_maxrows()\e[0m";
    
    # The default value for "Max Rows Per Page" is 1000. 0 indicates no limit.
    echo -e "\e[1;32m...Configuring Maximum rows returned to unlimited\e[0m";
    su gvm -c '/opt/gvm/sbin/gvmd --modify-setting 76374a7a-0569-11e6-b6da-28d24461215b --value 0'

    /usr/bin/logger 'configure_maxrows() finished' -t 'gce-2024-06-29';
    echo -e "\e[1;32mconfigure_maxrows() finished\e[0m";
}

send_mail() {
    /usr/bin/logger 'send_mail()' -t 'gce-2024-06-29';
    echo -e "\e[1;32msend_mail()\e[0m";

    echo -e "\e[1;32m...configuring Recipient and sender mail-addresses\e[0m";
    cat << __EOF__ > /etc/profile.d/gvmmail.sh
export RCPT_TO="$RCPT_TO"
export MAIL_ADDRESS="$MAIL_ADDRESS" 
__EOF__
    sync
    echo -e "\e[1;32m...Sending mail\e[0m";
    (echo "To: $MAIL_ADDRESS"; echo "Reply-To: $MAIL_ADDRESS"; echo "Subject: Installed Greenbone Vulnerability Manager on $(hostname -f)"; echo ""; echo -e "Server: $(hostname -f) \n Running: \n OSPD-OpenVAS=$OSPDOPENVAS \n OpenVAS=$OPENVAS \n GVM-Daemon=$GVMD \n GSA-Daemon=$GSA \n GSA=$GSA \n OpenVAS-SMB=$OPENVASSMB \n Python-GVM=$PYTHONGVM \n GVM-Tools=$GVMTOOLS \n pg-gvm=$POSTGREGVM \n Notus-scanner=$NOTUS \n greenbone-feed-sync=$FEEDSYNC \n on $PRETTY_NAME") | sendmail $RCPT_TO

    /usr/bin/logger 'send_mail()' -t 'gce-2024-06-29';
    echo -e "\e[1;32msend_mail()\e[0m";
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32mPrimary Server Install main()\e[0m";
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36m...Starting installation of primary Greenbone Community Edition Server 22.4.0\e[0m"
    echo -e "\e[1;36m...$HOSTNAME will also be the Certificate Authority for itself and all secondaries\e[0m"
    echo -e "\e[1;32m-----------------------------------------------------------------------------------------------------\e[0m"
    # Shared variables
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    # Check if started by Vagrant
    /usr/bin/logger 'Vagrant Environment Check for file' -t 'gce-2024-06-29';
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";
    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'Use .env file in HOME' -t 'gce-2024-06-29';
        echo -e "\e[1;32mUse .env file in home\e[0m";
        export ENV_DIR=$HOME;
    else
        /usr/bin/logger 'Use .env file SCRIPT_DIR' -t 'gce-2024-06-29';
        echo -e "\e[1;32mUse .env file in SCRIPT_DIR\e[0m";
        export ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    fi

    # Configure environment from .env file
    set -a; source $ENV_DIR/.env;
    echo -e "\e[1;36m....env file version $ENV_VERSION used\e[0m"
    echo -e "\e[1;36m....Using alternative feed: $ALTERNATIVE_FEED, $FEED_URL\e[0m"
   
    # Vagrant acts up at times with eth0, so check if running Vagrant and toggle it down/up
    toggle_vagrant_nic;

    ################################
    ## Start actual installation
    ################################
    ## Shared components
    install_prerequisites;
    install_nginx;
    configure_nginx;
    ## The function below can be used to create a CSR to send to corporate PKI
    #nginx_certificates;
    prepare_nix;
    prepare_source;
    # configure_cmake;
    # For latest builds use prepare_source_latest instead of prepare_source
    # It is likely to break, so only use if you're feeling really lucky.
    #prepare_source_latest;
    
    # Installation of specific components
    # This is the master server so install GVMD, GSAD, and GSA
    # Only install poetry when testing
    #install_poetry;
    #install_nmap;
    
    apt-get -qq -y install --fix-broken > /dev/null 2>&1;
    # Prepare Python Virtual Evironment for gvm python tools and utilities.
    prepare_gvmpy;
    # Create wrapper to start services with config files
    create_wrapper;
    # Install everything needed for Greenbone Community Edition
    #install_impacket;
    install_gvm_libs;
    # Temporary Workaround updating Libxml to newer version from source until Greenbone update to use Fix: Parse XML with XML_PARSE_HUGE
    #install_libxml2;
    install_openvas_smb;
    #install_openvas_from_github;
    install_openvas;
    install_ospd_openvas;
    install_gvm;
    install_pggvm;
    install_gsa_web;
    install_gsad;
    install_notus;
    install_gvm_tools;
    install_python_gvm;
    #install_python_ical;
    install_greenbone_feed_sync;
    if [ "$INSTALL_MAIL_SERVER" == "Yes" ]; then
        install_exim;
        configure_exim;
    else
        echo -e "\e[1;32mNot installing mailserver\e[0m";
    fi
    # Configuration of installed components
    prepare_postgresql;
    tune_postgresql;
    configure_gvm;
    configure_openvas;
    configure_gsa;
    
    # valkey or redis
    if [ $VALKEY_INSTALL == "Yes" ]
        then
            echo -e "\e[1;36m...Installing Valkey v$VALKEY\e[0m";
            install_valkey;
            configure_valkey;
        else 
            echo -e "\e[1;36m...Installing redis\e[0m";
            apt-get -qq -y install redis-server > /dev/null 2>&1;
            configure_redis;
        fi
    
    ## Some PGP stuff
    prepare_gpg;
    ## DB Maintenance
    prepare_db_maintenance;
    ## Add a simple GVM script as example
    create_gvm_python_script;
    #browserlist_update;
    # Prestage only works on the specific Vagrant lab where a scan-data tar-ball is copied to the Host. 
    # Update scan-data only from greenbone when used everywhere else.
    prestage_scan_data;
    configure_feed_validation;
    configure_greenbone_updates;
    configure_permissions;
    update_feed_data;
    #update_openvas_feed;
    start_services;
    configure_feed_owner;
    configure_maxrows;
    get_scanner_status;
    #clean_env;
    remove_vagrant_nic;
    remove_vagrant_user;
    if [ "$INSTALL_MAIL_SERVER" == "Yes" ]; then
        send_mail;
    fi
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot' -t 'gce-2024-06-29';
    echo -e;
    echo -e "\e[1;32mInstallation complete - will reboot in 10 seconds\e[0m";
    echo -e "\e[1;32mPrimary Server Install main() finished\e[0m";
    echo -e;
    echo -e "\e[1;32m*******************************************************************************************************\e[0m";
    echo -e "\e[1;36mInitial credential for this Greenbone Community Edition server:";
    cat /var/lib/gvm/adminuser;
    echo -e "\e[1;32mPlease change the initial password, but do NOT delete user $GVM_ADMINUSER, as it is also the feedowner\e[0m"; 
    echo -e "\e[1;32m*******************************************************************************************************\e[0m";
    echo -e;
    sync; sleep 10; systemctl reboot;
}

main;

exit 0;
