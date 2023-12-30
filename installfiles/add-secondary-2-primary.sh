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
#               Improved console output during install (1.10)               #
#                                                                           #
# Instruction:  Create certificates for secondary server                    #
#               Debian 10 (Buster) or Debian 11 (Bullseye)                  #
#                                                                           #
#############################################################################

create_gsecerts() {
    /usr/bin/logger 'create_gsecerts' -t 'gce-23.1';
    echo -e "\e[1;32m - create_gsecerts()\e[0m";
    cd /root/ > /dev/null 2>&1
    mkdir -p /var/lib/gvm/secondaries/$SECHOST/ > /dev/null 2>&1;
    cd /var/lib/gvm/secondaries/$SECHOST/ > /dev/null 2>&1;
    #Set required variables for secondary
    export GVM_CERTIFICATE_HOSTNAME=$SECHOST
    export GVM_CERT_PREFIX="secondary"
    export GVM_CERT_DIR="/var/lib/gvm/secondaries/$SECHOST"
    export GVM_KEY_FILENAME="$GVM_CERT_DIR/${GVM_CERT_PREFIX}-key.pem"
    export GVM_CERT_FILENAME="$GVM_CERT_DIR/${GVM_CERT_PREFIX}-cert.pem"
    export GVM_CERT_REQUEST_FILENAME="$GVM_CERT_DIR/${GVM_CERT_PREFIX}-request.pem"
    export GVM_CERT_TEMPLATE_FILENAME="gsecert-finished.cfg"
    export GVM_SIGNING_CA_KEY_FILENAME="$GVM_KEY_LOCATION/cakey.pem"
    export GVM_SIGNING_CA_CERT_FILENAME="$GVM_CERT_LOCATION/cacert.pem"
    # Create Certs
    /usr/bin/logger 'Creating certificates for secondary' -t 'gce-23.1';
    echo -e "\e[1;36m ... creating certificates for secondary $SECHOST\e[0m";
    /opt/gvm/bin/gvm-manage-certs -v -d -c > /dev/null 2>&1;
    cp /var/lib/gvm/CA/cacert.pem ./ > /dev/null 2>&1;
    sync;
    # Check certificate creation
    echo -e "\e[1;36m ... Verifying certificate creation\e[0m";
    if test -f $GVM_CERT_FILENAME; then
        /usr/bin/logger "Successfully created certificates for secondary $SECHOST" -t 'gce-23.1';
        echo -e "\e[1;36m ... Success; certificates and keys available. These files will be copied to $SECHOST\e[0m";
        echo -e "\e[1;36m ... $GVM_CERT_FILENAME\e[0m"
        echo -e "\e[1;36m ... $GVM_KEY_FILENAME, and\e[0m"
        echo -e "\e[1;36m ... $GVM_SIGNING_CA_CERT_FILENAME to secondary $SECHOST\e[0m"
        chown gvm:gvm *.pem > /dev/null 2>&1;
        chmod 777 *.pem > /dev/null 2>&1;
    else
        /usr/bin/logger "Failed creating Certificates for secondary $SECHOST" -t 'gce-23.1';
        echo -e "Failed: \e[1;31m ... $GVM_CERT_FILENAME not found, certificates not created for $SECHOST\e[0m"
    fi;
    echo -e "\e[1;32m - create_gsecerts() finished\e[0m";
    /usr/bin/logger 'create_gsecerts finished' -t 'gce-23.1';
}

add_secondary() {
    /usr/bin/logger 'add_secondary()' -t 'gce-23.1';
    echo -e "\e[1;32m - add_secondary()\e[0m";
    echo -e "\e[1;36m ... creating secondary $SECHOST on primary $HOSTNAME\e[0m";
    su gvm -c "/opt/gvm/sbin/gvmd --create-scanner=\"OpenVAS $SECHOST\" --scanner-host=$SECHOST --scanner-port=$REMOTEPORT --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=/var/lib/gvm/secondaries/$SECHOST/secondary-cert.pem --scanner-key-priv=/var/lib/gvm/secondaries/$SECHOST/secondary-key.pem" > /dev/null 2>&1
    echo -e "\e[1;36m ... copying install script and key material to $SECHOST\e[0m";
    sshpass -p $SECPASSWORD scp -o "StrictHostKeyChecking no" /root/secondary-certs.sh $GREENBONEUSER@$SECHOST: > /dev/null 2>&1
    sshpass -p $SECPASSWORD scp -o "StrictHostKeyChecking no" /var/lib/gvm/secondaries/$SECHOST/*.pem $GREENBONEUSER@$SECHOST: > /dev/null 2>&1
    sshpass -p $SECPASSWORD ssh -o "StrictHostKeyChecking no" $GREENBONEUSER@$SECHOST "chmod 755 /home/$GREENBONEUSER/*.sh" > /dev/null 2>&1
    echo -e "\e[1;36m ... executing script on $SECHOST\e[0m";
    sshpass -p $SECPASSWORD ssh -o "StrictHostKeyChecking no" $GREENBONEUSER@$SECHOST "sudo -u gvm -i /home/$GREENBONEUSER/secondary-certs.sh"
    echo -e "\e[1;32m - add_secondary() finished\e[0m";
    /usr/bin/logger 'add_secondary() finished' -t 'gce-23.1'
}

show_scanner_status() {
    /usr/bin/logger 'show_scanner_status()' -t 'gce-23.1';
    echo -e "\e[1;32m - show_scanner_status())\e[0m";
    echo -e "\e[1;36m ... Verifying secondary scanner $SECHOST on primary $HOSTNAME\e[0m";
    export SCANNER_ID=$(su gvm -c '/opt/gvm/sbin/gvmd --get-scanners' | grep $SECHOST | awk -F " " {'print $1'})
    echo -e "\e[1;33m ... Secondary Scanner ID on host $SECHOST is: $SCANNER_ID\e[0m";
    echo -e "\e[1;33m ... $SECHOST $(su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner $SCANNER_ID')\e[0m";
    #check again and use exit code
    su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner $SCANNER_ID";
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m ... Success: Secondary scanner $SECHOST UUID: $SCANNER_ID verified, user $GREENBONEUSER will be disabled on that system\e[0m"
        # Disable greenboneuser on secondary
        echo -e "\e[1;32mdisabling user $GREENBONEUSER on secondary $SECHOST\e[0m";
        sshpass -p $SECPASSWORD ssh -o "StrictHostKeyChecking no" $GREENBONEUSER@$SECHOST "su - gvm -c '/opt/gvm/sbin/openvas --update-vt-info'"
        sshpass -p $SECPASSWORD ssh -o "StrictHostKeyChecking no" $GREENBONEUSER@$SECHOST "sudo passwd --lock $GREENBONEUSER"
    else
        echo -e "\e[1;31m ... Error: Secondary scanner $SECHOST UUID: $SCANNER_ID verified, please correct any errors and, \e[0m" 
        echo -e "\e[1;31m ... try re-adding scanner $SECHOST\e[0m"
        exit 1;
    fi

    /usr/bin/logger 'show_scanner_status() finished' -t 'gce-23.1';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32m - add secondary main()\e[0m";
    # Server name of secondary and password variables
    read -p "Enter hostname of Secondary Server: " SECHOST;
    read -p "Enter password for user greenbone on $SECHOST (/var/lib/gvm/greenboneuser): " SECPASSWORD;    
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

    # Shared components
    echo -e;
    echo -e "\e[1;36m ... This may take a while, please wait\e[0m";    
    create_gsecerts;
    add_secondary;
    show_scanner_status;
    echo -e;
    echo -e "\e[1;36m ... Certificates and scanner created, verify in UI or from commandline\e[0m";
    echo -e "\e[1;36m ... certificate installation completed, check for errors in logs on $SECHOST\e[0m";
    echo -e "\e[1;32m - add secondary main() finished\e[0m";
}

main;

exit 0;
