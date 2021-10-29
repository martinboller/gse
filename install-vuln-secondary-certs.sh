#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-10-23                                                  #
# Version:      2.00                                                        #
#                                                                           #
# Changes:      Initial Version (1.00)                                      #
#               2021-10-23 Latest GSE release                               #
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
        cp ./secondarycert.pem /var/lib/gvm/CA/;
        cp ./cacert.pem /var/lib/gvm/CA/;
        cp ./secondarykey.pem /var/lib/gvm/private/CA/;
        chown -R gvm:gvm /var/lib/gvm/;
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

update_openvas_feed () {
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    su gvm -c '/opt/gvm/sbin/openvas --update-vt-info';
    /usr/bin/logger 'Updating NVT feed database (Redis) Finished' -t 'gse';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    install_certs;
    start_services;
    update_openvas_feed;
    /usr/bin/logger 'Updating NVT feed database (Redis)' -t 'gse';
    /usr/bin/logger 'Certificate installation completed, check for errors in logs' -t 'gse';
}

main;

exit 0;
