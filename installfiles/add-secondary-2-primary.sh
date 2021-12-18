#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-12-16                                                  #
# Version:      1.00                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#                                                                           #
# Instruction:  Create certificates for secondary (slave) server            #
#               Debian 10 (Buster) or Debian 11 (Bullseye)                  #
#                                                                           #
#############################################################################

create_gsecerts() {
    /usr/bin/logger 'create_gsecerts' -t 'gse-21.4';
    cd /root/
    mkdir -p /var/lib/gvm/secondaries/$SECHOST/;
    cd /var/lib/gvm/secondaries/$SECHOST/;
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
    /usr/bin/logger 'Creating certificates for secondary' -t 'gse-21.4';
    /opt/gvm/bin/gvm-manage-certs -v -d -c;
    cp /var/lib/gvm/CA/cacert.pem ./;
    sync;
    # Check certificate creation
    if test -f $GVM_CERT_FILENAME; then
        /usr/bin/logger "Successfully created certificates for secondary $SECHOST" -t 'gse-21.4';
        echo -e "\e[1;32mSuccess; certificates and keys available. These files will be copied to $SECHOST\e[0m";
        echo -e "\e[1;32m$GVM_CERT_FILENAME\e[0m"
        echo -e "\e[1;32m$GVM_KEY_FILENAME, and\e[0m"
        echo -e "\e[1;32m$GVM_SIGNING_CA_CERT_FILENAME to secondary $SECHOST\e[0m"
        chown gvm:gvm *.pem;
    else
        /usr/bin/logger "Failed creating Certificates for secondary $SECHOST" -t 'gse-21.4';
        echo -e "Failed: \e[1;31m$GVM_CERT_FILENAME not found, certificates not created for $SECHOST\e[0m"
    fi;
    /usr/bin/logger 'create_gsecerts finished' -t 'gse-21.4';
}

add_secondary() {
    su gvm -c "/opt/gvm/sbin/gvmd --create-scanner=\"OpenVAS $SECHOST\" --scanner-host=$SECHOST --scanner-port=$REMOTEPORT --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=/var/lib/gvm/secondaries/$SECHOST/secondary-cert.pem --scanner-key-priv=/var/lib/gvm/secondaries/$SECHOST/secondary-key.pem"
    sshpass -p $SECPASSWORD scp -o "StrictHostKeyChecking no" /root/install-vuln-secondary-certs.sh greenbone@$SECHOST:
    sshpass -p $SECPASSWORD scp -o "StrictHostKeyChecking no" /var/lib/gvm/secondaries/$SECHOST/*.pem greenbone@$SECHOST:
    sshpass -p $SECPASSWORD ssh -o "StrictHostKeyChecking no" greenbone@$SECHOST "sudo /root/install-vuln-secondary-certs.sh":    
}


##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    # Shared variables
    read -p "Enter hostname of Secondary Server: " SECHOST;
    read -p "Enter password for user greenbone on $SECHOST (/var/lib/gvm/greenboneuser): " SECPASSWORD;    
    # Remote Port on secondary
    export REMOTEPORT=9390
    # Certificate options
    #
    # Lifetime in days
    export GVM_CERTIFICATE_LIFETIME=3650
    # Country
    export GVM_CERTIFICATE_COUNTRY="DE"
    # Locality
    export GVM_CERTIFICATE_LOCALITY="Germany"
    # Organization
    export GVM_CERTIFICATE_ORG="Greenbone Scanner"
    # (Organization unit)
    export GVM_CERTIFICATE_ORG_UNIT="Certificate Authority for Vulnerability Management"
    # State
    export GVM_CA_CERTIFICATE_STATE="Bavaria"
    # Security Parameters
    GVM_CERTIFICATE_SECPARAM="high"
    GVM_CERTIFICATE_SIGNALG="SHA512"
    # Hostname
    export GVM_CERTIFICATE_HOSTNAME=$HOSTNAME  
    # CA Certificate Lifetime
    export GVM_CA_CERTIFICATE_LIFETIME=3652
    # Key & cert material locations
    export GVM_KEY_LOCATION="/var/lib/gvm/private/CA"
    export GVM_CERT_LOCATION="/var/lib/gvm/CA"

    # Shared components
    create_gsecerts;
    add_secondary;
    echo -e;
    echo -e "\e[1;32mCertificates created and scanner created, verify in UI or from commandline\e[0m";
}

main;

exit 0;
