#! /bin/bash

#####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin                                              #
# Last Update:  2021-11-05                                          #
# Version:      1.00                                                #
#                                                                   #
# Changes:      					            #
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
    ifdown eth0; ifup eth0;
    # Remove memcached on vagrant box
    apt-get -y purge memcached;
    # copy relevant scripts
    /bin/cp /tmp/configfiles/Servers/*.sh /root/;
    /bin/cp /tmp/configfiles/Servers/*.cfg /root/;
    chmod +x /root/*.sh;
    /usr/bin/logger 'apt_install_prerequisites()' -t 'gse';
}

install_ssh_keys() {
    # Echo add SSH public key for root logon
    export DEBIAN_FRONTEND=noninteractive;
    mkdir /root/.ssh;
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHJYsxpawSLfmIAZTPWdWe2xLAH758JjNs5/Z2pPWYm" | sudo tee -a /root/.ssh/authorized_keys;
    sudo chmod 700 /root/.ssh;
    sudo chmod 600 /root/.ssh/authorized_keys;
    /usr/bin/logger 'install_ssh_keys()' -t 'gse';
}

restart_wait() {
    echo "Restarting Services";
    export DEBIAN_FRONTEND=noninteractive;
    # Stopping metricbeat until configured correctly
    systemctl stop metricbeat.service;
    # Restarting remaining elasticstack services
    systemctl restart elasticsearch.service;
    systemctl restart kibana.service;
    systemctl restart cerebro.service;
    systemctl restart nginx.service;
    # Making absolutely sure elastic and other services are responding
    sleep 20;
    /usr/bin/logger 'restart_wait()' -t 'gse';
}

create_nginx_htpasswd_cerebro() {
    export ht_passwd="$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 20)"
    htpasswd -cb /etc/nginx/.htpasswd alerta $HT_PASSWD;
    echo "Created password for NGINX $HOSTNAME cerebro:$ht_passwd"  >> /mnt/backup/readme-users.txt;
    echo "-------------------------------------------------------------------"  >> /mnt/backup/readme-users.txt;
    /usr/bin/logger 'create_nginx_htpasswd()' -t 'gse';
    systemctl restart nginx.service;
}

create_nginx_htpasswd_alerta() {
    export ht_passwd="$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 20)"
    htpasswd -cb /etc/nginx/.htpasswd alerta $HT_PASSWD;
    echo "Created password for NGINX $HOSTNAME alerta:$ht_passwd"  >> /mnt/backup/readme-users.txt;
    echo "-------------------------------------------------------------------"  >> /mnt/backup/readme-users.txt;
    /usr/bin/logger 'create_nginx_htpasswd()' -t 'gse';
    systemctl restart nginx.service;
}

finish_restart() {
    secs=$1
    echo -e;
    echo -e "\e[1;31m--------------------------------------------\e[0m";
        while [ $secs -gt 0 ]; do
            echo -ne "Finish setup on all nodes in: \e[1;31m$secs seconds\033[0K\r"
            sleep 1
            : $((secs--))
        done;
    echo -e
    echo -e "\e[1;31mFinishing things\e[0m";
    /usr/bin/logger 'Finishing things, then enabling SSL/TLS' -t 'gse';
}


##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    # Core elements, always installs
    #prepare_files;
    /usr/bin/logger '!!!!! Main routine starting' -t 'gse';
    install_ssh_keys;
    configure_timezone;
    apt_install_prerequisites;
    configure_locale;
    configure_timezone;

    # copy relevant scripts
    /bin/cp /tmp/configfiles/* /root/;
    chmod +x /root/*.sh;
    apt-get -y install --fix-policy;
    /usr/bin/logger 'installation finished (Main routine finished)' -t 'gse'; 

}

main;

exit 0
