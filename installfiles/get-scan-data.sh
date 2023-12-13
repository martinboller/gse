#!/bin/bash
# copy scandata from primary Greenbone Server to local system
# Copy the resulting scandata.tar.gz to the system being installed to prestage scandata.
cd /tmp/ > /dev/null 2>&1;
read -p "Press Enter to start copying to /tmp: " dummy_value
mkdir /tmp/GVM
rm ./scandata.tar.gz > /dev/null 2>&1;
rsync -aAXv --info=progress2 --info=name0 root@manticore:/var/lib/gvm/scap-data /tmp/GVM/gvm/;
rsync -aAXv --info=progress2 --info=name0 root@manticore:/var/lib/openvas/ /tmp/GVM/openvas/;
rsync -aAXv --info=progress2 --info=name0 root@manticore:/var/lib/notus/ /tmp/GVM/notus/;
rm /tmp/GVM/notus/LICENSE* > /dev/null 2>&1;
sync > /dev/null 2>&1;
tar czfv /tmp/scandata.tar.gz /tmp/GVM/ > /dev/null 2>&1;
sync > /dev/null 2>&1;
cp /tmp/scandata.tar.gz $HOME
rm -rf /tmp/GVM/ > /dev/null 2>&1;
cd > /dev/null 2>&1;
