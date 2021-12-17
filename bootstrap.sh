#! /bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin                                              #
# Last Update:  2021-11-05                                          #
# Version:      1.00                                                #
#                                                                   #
# Changes:      					                                #
#                                                                   #
#                                                                   #
#####################################################################

configure_locale() {
  echo -e "\e[32mconfigure_locale()\e[0m";
  echo -e "\e[36m-Configure locale (default:C.UTF-8)\e[0m";
  export DEBIAN_FRONTEND=noninteractive;
  sudo sh -c "cat << EOF  > /etc/default/locale
# /etc/default/locale
LANG=C.UTF-8
LANGUAGE=C.UTF-8
LC_ALL=C.UTF-8
EOF";
  update-locale;
  /usr/bin/logger 'configure_locale()' -t 'gse';
}

configure_timezone() {
  echo -e "\e[32mconfigure_timezone()\e[0m";
  echo -e "\e[36m-Set timezone to Etc/UTC\e[0m";
  export DEBIAN_FRONTEND=noninteractive;
  sudo rm /etc/localtime;
  sudo sh -c "echo 'Etc/UTC' > /etc/timezone";
  sudo dpkg-reconfigure -f noninteractive tzdata;
  /usr/bin/logger 'configure_timezone()' -t 'gse';
}

apt_install_prerequisites() {
    # Install prerequisites and useful tools
    export DEBIAN_FRONTEND=noninteractive;
    apt-get -y remove postfix*;
        sudo sync \
        && sudo apt-get update \
        && sudo apt-get -y full-upgrade \
        && sudo apt-get -y --purge autoremove \
        && sudo apt-get autoclean \
        && sudo sync;
        /usr/bin/logger 'install_updates()' -t 'gse';
    sed -i '/dns-nameserver/d' /etc/network/interfaces;
    # copy relevant scripts
    /bin/cp /tmp/installfiles/*.sh /root/;
    chmod +x /root/*.sh;
    /usr/bin/logger 'apt_install_prerequisites()' -t 'gse';
}

install_ssh_keys() {
    # Echo add SSH public key for root logon
    export DEBIAN_FRONTEND=noninteractive;
    mkdir /root/.ssh;
    echo $mySSHKey | sudo tee -a /root/.ssh/authorized_keys;
    sudo chmod 700 /root/.ssh;
    sudo chmod 600 /root/.ssh/authorized_keys;
    /usr/bin/logger 'install_ssh_keys()' -t 'gse';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    # Core elements, always installs
    #prepare_files;
    export mySSHKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHJYsxpawSLfmIAZTPWdWe2xLAH758JjNs5/Z2pPWYm"
    /usr/bin/logger '!!!!! Main routine starting' -t 'gse';
    install_ssh_keys;
    configure_timezone;
    apt_install_prerequisites;
    configure_locale;
    configure_timezone;

    # copy relevant scripts
    /bin/cp /tmp/installfiles/* /root/;
    chmod +x /root/*.sh;
    apt-get -y install --fix-policy;
    /usr/bin/logger 'installation finished (Main routine finished)' -t 'gse'; 
}

main;

exit 0
