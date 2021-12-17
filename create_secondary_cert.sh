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
    mkdir -p sec_certs/$SECHOST/;
    cd /root/sec_certs/$SECHOST/;
    #Set required variables for secondary
    export GVM_CERTIFICATE_HOSTNAME=$SECHOST
    export GVM_CERT_PREFIX="secondary"
    export GVM_CERT_DIR="/root/sec_certs/$SECHOST"
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
        echo -e "\e[1;32mSuccess; certificates and keys available. Copy $GVM_CERT_FILENAME, $GVM_KEY_FILENAME, and $GVM_SIGNING_CA_CERT_FILENAME to secondary $SECHOST\\e[0m"
        chown gvm:gvm *.pem;
    else
        /usr/bin/logger "Failed creating Certificates for secondary $SECHOST" -t 'gse-21.4';
        echo -e "Failed: \e[1;31m$GVM_CERT_FILENAME not found, certificates not created for $SECHOST\e[0m"
    fi;
    /usr/bin/logger 'create_gsecerts finished' -t 'gse-21.4';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    # Shared variables
    read -p "Enter hostname of Secondary Server: " SECHOST;
    # Certificate options
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
}

main;

exit 0;

######################################################################################################################################
# Post install 
# 
# Feedowner/admin account is automatically created during installation.x
# The admin account is import feed owner: https://community.greenbone.net/t/gvm-20-08-missing-report-formats-and-scan-configs/6397/2
# /opt/gvm/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value UUID of admin account 
# Get the uuid using /opt/gvm/sbin/gvmd --get-users --verbose
# The first OpenVas scanner is always this UUID /opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73
#
# 08b69003-5fc2-4037-a479-93b440211c73  OpenVAS  /run/ospd/ospd-openvas.sock  0  OpenVAS Default
# 6acd0832-df90-11e4-b9d5-28d24461215b  CVE    0  CVE
#
#
# Admin user:   cat /opt/gvm/lib/adminuser.
#               You should change this: /opt/gvm/sbin/gvmd --user admin --new-password 'Your new password'
#
# Check the logs:
# tail -f /var/log/gvm/ospd-openvas.log
# tail -f /var/log/gvm/gvmd.log
# tail -f /var/log/gvm/openvas-log < This is very useful when scanning
# tail -f /var/log/syslog | grep -i gse
#
# Create required certs for secondary
# # cd /root/sec_certs
# /opt/gvm/sbin/gvm-manage-certs -e ./gsecert.cfg -v -d -c
# copy secondarycert.pem, secondarykey.pem, and /var/lib/gvm/CA/cacert.pem to the remote system to the correct locations. 
# Then create the scanner in GVMD
# chown gvm:gvm *
# su gvm -c '/opt/gvm/sbin/gvmd --create-scanner="OSP Scanner secondary hostname" --scanner-host=hostname --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondarycert.pem --scanner-key-priv=./secondarykey.pem'
# Example:
#   su gvm -c '/opt/gvm/sbin/gvmd --create-scanner="OpenVAS Secondary host aboleth" --scanner-host=aboleth --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondarycert.pem --scanner-key-priv=./secondarykey.pem'
#       Scanner created.
# 
# Don't forget to install the certs on the secondary as discussed further down, then return and do these verification steps on the primary:
#   
#   su gvm -c '/opt/gvm/sbin/gvmd --get-scanners'
#       08b69003-5fc2-4037-a479-93b440211c73  OpenVAS  /var/run/ospd/ospd-openvas.sock  0  OpenVAS Default
#       6acd0832-df90-11e4-b9d5-28d24461215b  CVE    0  CVE
#       3e2232e3-b819-41bc-b5be-db52bfb06588  OpenVAS  mysecondary  9390  OSP Scanner mysecondary
#
#   su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner=3e2232e3-b819-41bc-b5be-db52bfb06588'
#       Scanner version: OpenVAS 20.8.0.
#
#
#The gsecert.cfg file supplied creates a wildcard cert, so can be used on all the secondaries you wish. 
# 
# On Secondary:
# copy certificate files to correct locations. When copied locally use the script install-vuln-secondary-certs.sh
# The script also restarts the unit.
#
# Using ps or top, You'll notice that postgres is being hammered by gvmd and that redis are
# too, but by ospd-openvas.
#
# When running a - tail -f /var/log/openvas.log - is useful in following progress during the scanning.
# /var/lib/gvm/private/CA/