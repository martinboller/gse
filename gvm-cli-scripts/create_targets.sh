#!/bin/bash

## Create a few different targets using gvm-cli with port_list "All IANA assigned TCP" (33d0cd82-57c6-11e1-8ed1-406186ea4fc5)
## please note that the credential UUID's used in the last example are unique to this (now defunct) test environment
gvm-cli socket --sockpath /run/gvmd/gvmd.sock --gmp-username admin --gmp-password 2557d2d0-2ffe-4c1e-acc2-ad1fc096c048 --xml '<create_target><name>Labnet_1</name><hosts>10.10.1.0/24</hosts><port_list id="33d0cd82-57c6-11e1-8ed1-406186ea4fc5"></port_list></create_target>'
gvm-cli socket --sockpath /run/gvmd/gvmd.sock --gmp-username admin --gmp-password 2557d2d0-2ffe-4c1e-acc2-ad1fc096c048 --xml '<create_target><name>Labnet_2</name><hosts>10.10.2.0/24</hosts><port_list id="33d0cd82-57c6-11e1-8ed1-406186ea4fc5"></port_list></create_target>'
gvm-cli socket --sockpath /run/gvmd/gvmd.sock --gmp-username admin --gmp-password 2557d2d0-2ffe-4c1e-acc2-ad1fc096c048 --xml '<create_target><name>Suspicious host</name><hosts>10.10.1.197</hosts><port_list id="33d0cd82-57c6-11e1-8ed1-406186ea4fc5"></port_list></create_target>'
# With existing credentials
gvm-cli socket --sockpath /run/gvmd/gvmd.sock --gmp-username adminuser --gmp-password adminpw --xml  '<create_target><name>External_service</name><hosts>scanme.nmap.org</hosts><port_list id="33d0cd82-57c6-11e1-8ed1-406186ea4fc5"></port_list><ssh_credential id="482d2899-9fa4-40f9-962b-57f751db5603"><port>22</port></ssh_credential><smb_credential id="803ec5a2-c38f-4735-b600-0587dac056c1"></smb_credential><snmp_credential id="35ba7687-1008-46cc-8993-0ee366dbd9ba"></snmp_credential></create_target>'