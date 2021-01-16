#! /bin/bash

#############################################################################
#                                                                           #
# Author:       Martin Boller                                               #
#                                                                           #
# Email:        martin                                                      #
# Last Update:  2021-01-16                                                  #
# Version:      1.00                                                        #
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
    cp ./secondarycert.pem /usr/local/var/lib/gvm/CA/;
    cp ./cacert.pem /usr/local/var/lib/gvm/CA/;
    cp ./secondarykey.pem /usr/local/var/lib/gvm/private/CA/;
    chown -R ospd:ospd /usr/local/var/lib/gvm/;
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
    else
        /usr/bin/logger 'ospd-openvas.service FAILED!' -t 'gse';
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
    /usr/bin/logger 'Installation complete - Give it a few minutes to complete ingestion of feed data into Postgres/Redis, then reboot' -t 'gse';
}

main;

exit 0;
