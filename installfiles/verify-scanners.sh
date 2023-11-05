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
    echo -e
    echo -e "\e[1;32mGetting installed scanners\e[0m";
    readarray -t scanners < <(su gvm -c '/opt/gvm/sbin/gvmd --get-scanners' | awk -F " " {'print $1,$3'})
    echo -e
    echo -e "\e[1;32mRetrieving current status and version of scanners\e[0m";
    for scanner in "${scanners[@]}"
        do
            echo -e "\e[1;36m-------------------------------------------------------------------------------------------------\e[1;32m"
            echo "Scanner Identifier and Name: " $scanner
            su gvm -c "/opt/gvm/sbin/gvmd --verify-scanner $scanner";
        done
    echo -e "\e[1;36m-------------------------------------------------------------------------------------------------\e[0m"
    echo -e 
    echo -e 
    echo -e "\e[1;36m-------------------------------------------------------------------------------------------------\e[0m"
    echo -e "\e[1;36mEnumerated all scanners on $HOSTNAME\e[0m"
    echo -e "\e[1;36mPlease check that they're replying and are recent versions\e[0m"
    echo -e "\e[1;36mUse https://github.com/greenbone to check released versions\e[0m"
    echo -e "\e[1;36m-------------------------------------------------------------------------------------------------\e[0m"
    /usr/bin/logger 'show_scanner_status() finished' -t 'gse-21.4';
}

##################################################################################################################
## Main                                                                                                          #
##################################################################################################################

main() {
    echo -e "\e[1;36mVerifying Scanners, please wait\e[0m";    
    show_scanner_status;    
    echo -e;
}

main;

exit 0;
