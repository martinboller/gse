#! /bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin                                              #
# Last Update:  2022-01-08                                          #
# Version:      1.10                                                #
#                                                                   #
# Changes:      First version (1.00)                                #
#               Improved console output during install (1.10)       #
#                                                                   #
#                                                                   #
#####################################################################

configure_locale() {
  /usr/bin/logger 'configure_locale()' -t 'gce';
  echo -e "\e[32m - configure_locale()\e[0m";
  echo -e "\e[36m ... configure locale (default:C.UTF-8)\e[0m";
  export DEBIAN_FRONTEND=noninteractive;
  sh -c "cat << EOF  > /etc/default/locale
# /etc/default/locale
LANG=C.UTF-8
LANGUAGE=C.UTF-8
LC_ALL=C.UTF-8
EOF";
  update-locale > /dev/null 2>&1;
  echo -e "\e[32m - configure_locale() finished\e[0m";
  /usr/bin/logger 'configure_locale() finished' -t 'gce';
}

configure_timezone() {
  /usr/bin/logger 'configure_timezone()' -t 'gce';
  echo -e "\e[32m - configure_timezone()\e[0m";
  echo -e "\e[36m ... set timezone to Etc/UTC\e[0m";
  export DEBIAN_FRONTEND=noninteractive;
  timedatectl set-timezone UTC;
  rm /etc/localtime > /dev/null 2>&1;
  echo 'Etc/UTC' > /etc/timezone > /dev/null 2>&1;
  dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1;
  echo -e "\e[32m - configure_timezone() finished\e[0m";
  /usr/bin/logger 'configure_timezone() finished' -t 'gce';
}

gse_bootstrap_prerequisites() {
  /usr/bin/logger 'gse_bootstrap_prerequisites()' -t 'gce';
  echo -e "\e[32m - gse_bootstrap_prerequisites()\e[0m";
  # Install prerequisites and useful tools
  export DEBIAN_FRONTEND=noninteractive;
  #sed -ie s/http/https/ /etc/apt/sources.list;
  apt-get update;
  # Removing some of the cruft installed by default in the Vagrant images
  echo -e "\e[36m ... removing unneeded packages\e[0m";
  apt-get -qq -y purge postfix* memcached > /dev/null 2>&1
  sync > /dev/null 2>&1;
  echo -e "\e[36m ... cleaning up apt\e[0m";
  apt-get -qq -y install --fix-policy > /dev/null 2>&1;
  apt-get -qq update > /dev/null 2>&1;
  apt-get -qq -y full-upgrade > /dev/null 2>&1
  apt-get -qq -y --purge autoremove > /dev/null 2>&1
  apt-get -qq autoclean > /dev/null 2>&1
  sync > /dev/null 2>&1
#  apt-get -y --fix-broken install;
#  apt-get -y --fix-missing install;
  /usr/bin/logger 'install_updates()' -t 'gce';
  echo -e "\e[36m ... removing nameserver from interfaces file\e[0m";
  sed -i '/dns-nameserver/d' /etc/network/interfaces > /dev/null 2>&1;
  # copy relevant scripts
  echo -e "\e[36m ... copying instalation scripts\e[0m";
  /bin/cp -r /tmp/installfiles/* /root/ > /dev/null 2>&1;
  chmod 744 /root/*.sh > /dev/null 2>&1;
  /usr/bin/logger 'gse_bootstrap_prerequisites() finished' -t 'gce';
}

install_public_ssh_keys() {
  /usr/bin/logger 'install_public_ssh_keys()' -t 'gce';
  echo -e "\e[32m - install_public_ssh_key()\e[0m";
  # Echo add SSH public key for root logon
  export DEBIAN_FRONTEND=noninteractive;
  echo -e "\e[36m ... adding authorized_keys file and setting permissions\e[0m";
  mkdir /root/.ssh > /dev/null 2>&1;
  echo $myPublicSSHKey | tee -a /root/.ssh/authorized_keys > /dev/null 2>&1;
  chmod 700 /root/.ssh> /dev/null 2>&1;
  chmod 600 /root/.ssh/authorized_keys > /dev/null 2>&1;
  echo -e "\e[32m - install_public_ssh_key() finished\e[0m";
  /usr/bin/logger 'install_public_ssh_keys() finished' -t 'gce';
}

configure_vagrant() {
  /usr/bin/logger 'configure_vagrant()' -t 'gce';
  echo -e "\e[32mconfigure_vagrant()\e[0m";
  echo "export VAGRANT_ENV=TRUE" > /etc/profile.d/vagrant.sh;
  touch /etc/VAGRANT_ENV;
  echo -e "\e[32mconfigure_vagrant() finished\e[0m";
  /usr/bin/logger 'configure_vagrant() finished' -t 'gce';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[32m - Greenbone Community Edition Bootstrap main()\e[0m";
    # Core elements, always installs
    #prepare_files;
    export myPublicSSHKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHJYsxpawSLfmIAZTPWdWe2xLAH758JjNs5/Z2pPWYm"
    /usr/bin/logger 'Greenbone Community Edition Bootstrap main()' -t 'gce';
    configure_vagrant;
    install_public_ssh_keys;
    #configure_timezone;
    gse_bootstrap_prerequisites;
    #configure_locale;
    # NAT Network adapter weirdness, so give it a kick.
    #ifdown eth0 > /dev/null 2>&1; ifup eth0 > /dev/null 2>&1;
    if [ "$HOSTNAME" = "manticore" ];
    then
      echo -e "\e[36m ... Installing primary server\e[0m";    
      #/root/install-gse.sh
    fi
    if [ "$HOSTNAME" = "aboleth" ];
    then
      echo -e "\e[36m ... Installing secondary server\e[0m";    
      #/root/install-gse-secondary.sh
    fi
    echo -e "\e[32m - Greenbone Community Edition Bootstrap main() finished\e[0m";
    /usr/bin/logger 'Greenbone Community Edition Bootstrap main() finished' -t 'gce';
}

main;

exit 0
