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
    /usr/bin/logger 'install_certs' -t 'gce-23.1';
    echo -e "\e[1;32m - install_certs()\e[0m";
    if test -f $CERT_LOCATION/cacert.pem; then
        echo -e "\e[1;36m ... certificates for secondary $HOSTNAME found, copying to correct locations\e[0m";
        cp $CERT_LOCATION/secondary-cert.pem /var/lib/gvm/CA/ > /dev/null 2>&1;
        cp $CERT_LOCATION/cacert.pem /var/lib/gvm/CA/ > /dev/null 2>&1;
        cp $CERT_LOCATION/secondary-key.pem /var/lib/gvm/private/CA/;
        chown -R gvm:gvm /var/lib/gvm/ > /dev/null 2>&1;
        sync;
        # Remove certificate files and .env
        rm $CERT_LOCATION/*.pem > /dev/null 2>&1;
        rm $CERT_LOCATION/.env > /dev/null 2>&1;
        /usr/bin/logger 'Certificates for secondary installed' -t 'gce-23.1';
    else
        /usr/bin/logger "Certificates for secondary not found, have you copied secondary-cert.pem, secondary-key.pem, and cacert.pem? to $CERT_LOCATION?" -t 'gce-23.1';
        echo -e "\e[1;31mCertificates for secondary not found, have you copied secondary-cert.pem, secondary-key.pem, and cacert.pem? to $CERT_LOCATION?\e[0m";
    fi;
    echo -e "\e[1;32m - install_certs() finished\e[0m";
    /usr/bin/logger 'install_certs finished' -t 'gce-23.1';
}

start_services() {
    /usr/bin/logger 'start_services' -t 'gce-23.1';
    echo -e "\e[1;32m - start_services()\e[0m";
    # Load new/changed systemd-unitfiles
    systemctl daemon-reload > /dev/null 2>&1;
    systemctl restart ospd-openvas > /dev/null 2>&1;
    sleep 30;
    echo -e "\e[1;32m-----------------------------------------------------------------\e[0m";
    echo -e "\e[1;36m ... Checking core daemons for GSE Secondary......\e[0m";
    if systemctl is-active --quiet ospd-openvas.service;
    then
        /usr/bin/logger 'ospd-openvas.service started successfully' -t 'gce-23.1';
        echo -e "\e[1;32m ... ospd-openvas.service started successfully\e[0m";
    else
        /usr/bin/logger 'ospd-openvas.service FAILED!' -t 'gce-23.1';
        echo -e "\e[1;31m ... ospd-openvas.service FAILED! check logs and certificates\e[0m";
    fi
    echo -e "\e[1;32m - start_services() finished\e[0m";
    /usr/bin/logger 'start_services finished' -t 'gce-23.1';
}

update_openvas_redis () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gce-23.1';
    echo -e "\e[1;32m - update_openvas_redis()\e[0m";
    echo -e "\e[1;36m ... updating NVT feed database (Redis) on $HOSTNAME\e[0m";
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info' > /dev/null 2>&1;
    echo -e "\e[1;32m - update_openvas_redis()\e[0m";
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gce-23.1';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32m - secondary certs installation main()\e[0m";

   # Shared variables
    export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    # Check if started by Vagrant
    /usr/bin/logger 'Vagrant Environment Check for file' -t 'gce-23.1.0';
    echo -e "\e[1;32mcheck if started by Vagrant\e[0m";
    if test -f "/etc/VAGRANT_ENV"; then
        /usr/bin/logger 'Use .env file in HOME' -t 'gce-23.1.0';
        echo -e "\e[1;32mUse .env file in home\e[0m";
        export ENV_DIR=$HOME;
    else
        /usr/bin/logger 'Use .env file SCRIPT_DIR' -t 'gce-23.1.0';
        echo -e "\e[1;32mUse .env file in SCRIPT_DIR\e[0m";
        export ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    fi

    # Configure environment from .env file
    set -a; source $ENV_DIR/.env;
    echo -e "\e[1;36m....env file version $ENV_VERSION used\e[0m"

    echo $CERT_DIR;
    if [[ -z $CERT_DIR ]]; then
        echo -e "\e[1;31mNo certificate file location supplied, use secondary-certs.sh location of certfiles\e[0m"
        echo -e "\e[1;31mTrying with /home/$GREENBONEUSER but if that fails, specify the location\e[0m"
        echo -e
        echo -e "\e[1;32mExample: ./secondary-certs.sh ./myCerts/"
        export CERT_LOCATION="/home/$GREENBONEUSER";
    else
        export CERT_LOCATION="$CERT_DIR";
    fi

    # Install certificates and start ospd-openvas
    install_certs;
    
    if test -f /var/lib/gvm/private/CA/secondary-key.pem; then
        echo -e "\e[1;36m ... certificates for secondary $HOSTNAME found, copying to correct locations\e[0m";
        start_services;
        # Update redis with NVT information
        update_openvas_redis;
        # Disable user greenbone after first use (installing certificates)
        echo -e "\e[1;36m ... disabling user greenbone on $HOSTNAME\e[0m";
        echo -e "\e[1;36m ... $(sudo passwd --lock greenbone)\e[0m"
        /usr/bin/logger 'Service ospd-openvas and notus secondary should now have started' -t 'gce-23.1';
    else
        /usr/bin/logger "Certificates for secondary not found, secondary not functional" -t 'gce-23.1';
        echo -e "\e[1;31mCertificates for secondary not found, secondary not functional\e[0m";
        exit 1;
    fi;
    /usr/bin/logger 'Certificate installation completed, check for errors in logs' -t 'gce-23.1';
    echo -e "\e[1;36m ... certificate installation completed, check for errors in logs on $HOSTNAME\e[0m";
    echo -e "\e[1;32m - secondary certs installation main()\e[0m";
}

export CERT_DIR="$1";
main;

exit 0;

