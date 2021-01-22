#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-01-20                                                  #
# Version:      1.10                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#                                                                           #
#                                                                           #
# Info:        https://sadsloth.net/post/install-gvm-20_08-src-on-debian/   #
#                                                                           #
#                                                                           #
# Instruction:  Copies required cert files  from current                    #
#               to correct directories                                      #
#                                                                           #
#                                                                           #
#############################################################################

install_certs() {
    /usr/bin/logger 'install_certs' -t 'gse';
     if test -f ./secondarycert.pem; then
        echo "Certificates for secondary found, now copying to correct locations";
        cp ./secondarycert.pem /usr/local/var/lib/gvm/CA/;
        cp ./cacert.pem /usr/local/var/lib/gvm/CA/;
        cp ./secondarykey.pem /usr/local/var/lib/gvm/private/CA/;
        chown -R ospd:ospd /usr/local/var/lib/gvm/;
        sync;
        /usr/bin/logger 'Certificates for secondary installed' -t 'gse';
    else
        /usr/bin/logger 'Certificates for secondary not found, have you copied them to the current directory?' -t 'gse';
        echo "Certificates for secondary not found, have you copied them to the current directory?";
    fi;
    /usr/bin/logger 'install_certs finished' -t 'gse';
}

start_services() {
    /usr/bin/logger 'start_services' -t 'gse';
    # Load new/changed systemd-unitfiles
    systemctl daemon-reload;
    systemctl restart ospd-openvas;
    if systemctl is-active --quiet ospd-openvas.service;
    then
        /usr/bin/logger 'ospd-openvas.service started successfully' -t 'gse';
        echo 'ospd-openvas.service started successfully';
    else
        /usr/bin/logger 'ospd-openvas.service FAILED!' -t 'gse';
        echo 'ospd-openvas.service FAILED! check logs and certificates';
    fi
    /usr/bin/logger 'start_services finished' -t 'gse';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    /usr/local/sbin/openvas --update-vt-info;
    install_certs;
    start_services;
    /usr/bin/logger 'Certificate installation completed, check for errors in logs' -t 'gse';
}

main;

exit 0;
