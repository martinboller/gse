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
    echo -e "\e[1;36m ... Verifying Scanners, please wait\e[0m";    
    show_scanner_status;    
    echo -e;
}

main;

exit 0;
