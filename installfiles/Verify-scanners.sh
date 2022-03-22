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


show_scanner_status() {
    /usr/bin/logger 'show_scanner_status()' -t 'gse-21.4';
    echo -e "\e[1;32m - show_scanner_status())\e[0m";
    echo -e "\e[1;36m ... Verifying secondary scanner $SECHOST on primary $HOSTNAME\e[0m";
    readarray -t scanners < <(su gvm -c '/opt/gvm/sbin/gvmd --get-scanners' | awk -F " " {'print $1,$3'})
    #declare -p scanners;
    for scanner in "${scanners[@]}"
        do
            echo $scanner | awk -F " " {'print $2'}
            su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner $scanner";
            echo -e
        done
    /usr/bin/logger 'show_scanner_status() finished' -t 'gse-21.4';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;32m - add secondary main()\e[0m";
    # Shared variables
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
    echo -e;
    echo -e "\e[1;36m ... This may take a while, please wait\e[0m";    
    show_scanner_status;    
    echo -e;
}

main;

exit 0;
