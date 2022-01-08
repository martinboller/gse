#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2022-01-08                                                  #
# Version:      1.10                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#               2021-12-17 hostname in cert                                 #
#               2022-01-08 Improved console output during install (1.10)    #
#                                                                           #
# Instruction:  Copies required cert files  from current                    #
#               to correct directories                                      #
#                                                                           #
#                                                                           #
#############################################################################

install_certs() {
    /usr/bin/logger 'install_certs' -t 'gse';
    echo -e "\e[1;32m - install_certs()\e[0m";
     if test -f ./cacert.pem; then
        echo -e "\e[1;36m ... certificates for secondary $HOSTNAME found, copying to correct locations\e[0m";
        cp ./secondary-cert.pem /var/lib/gvm/CA/;
        cp ./cacert.pem /var/lib/gvm/CA/;
        cp ./secondary-key.pem /var/lib/gvm/private/CA/;
        chown -R gvm:gvm /var/lib/gvm/;
        sync;
        /usr/bin/logger 'Certificates for secondary installed' -t 'gse';
    else
        /usr/bin/logger 'Certificates for secondary not found, have you copied them to the current directory?' -t 'gse';
        echo -e "\e[1;31mCertificates for secondary not found, have you copied them to the current directory?\e[0m";
    fi;
    echo -e "\e[1;32m - install_certs() finished\e[0m";
    /usr/bin/logger 'install_certs finished' -t 'gse';
}

start_services() {
    /usr/bin/logger 'start_services' -t 'gse';
    echo -e "\e[1;32m - start_services()\e[0m";
    # Load new/changed systemd-unitfiles
    systemctl daemon-reload;
    systemctl restart ospd-openvas;
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;36m ... Checking core daemons for GSE Secondary......\e[0m";
    if systemctl is-active --quiet ospd-openvas.service;
    then
        /usr/bin/logger 'ospd-openvas.service started successfully' -t 'gse';
        echo -e "\e[1;32m ... ospd-openvas.service started successfully\e[0m";
    else
        /usr/bin/logger 'ospd-openvas.service FAILED!' -t 'gse';
        echo -e "\e[1;31m ... ospd-openvas.service FAILED! check logs and certificates\e[0m";
    fi
    echo -e "\e[1;32m - start_services() finished\e[0m";
    /usr/bin/logger 'start_services finished' -t 'gse';
}

update_openvas_redis () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    echo -e "\e[1;32m - update_openvas_redis()\e[0m";
    echo -e "\e[1;36m ... updating NVT feed database (Redis) on $HOSTNAME\e[0m";
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info';
    echo -e "\e[1;32m - update_openvas_redis()\e[0m";
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gse';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32m - secondary certs installation main()\e[0m";
    # Install certificates and start ospd-openvas
    install_certs;
    start_services;
    # Update redis with NVT information
    update_openvas_redis;
    # Disable user greenbone after first use (installing certificates)
    echo -e "\e[1;36m ... disabling user greenbone on $HOSTNAME\e[0m";
    echo -e "\e[1;36m ... $(passwd --lock greenbone)\e[0m"
    /usr/bin/logger 'Certificate installation completed, check for errors in logs' -t 'gse';
    echo -e "\e[1;36m ... certificate installation completed, check for errors in logs on $HOSTNAME\e[0m";
    echo -e "\e[1;32m - secondary certs installation main()\e[0m";
}

main;

exit 0;
