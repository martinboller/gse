# Greenbone Vulnerability Manager 21.4.x Source Code Edition Installation script

## Bash script automating the installation of Greenbone Vulnerability Manager 21.4.3 (October 2021 releases) on Debian 10 or 11

Installation will be located in /usr/local/, which is the default for GVM SCE.

### Design principles:
  - Dedicated to GVM, nothing else
  - Use the defaults where possible
  - Least access

During installation a GVM user called 'admin' is created. The generated password for User admin is
stored in the file /usr/local/var/lib/adminuser. It is recommended that this password is changed and/or
the file deleted. Do NOT delete the user admin unless you also change the feedowner to another user.

To create a secondary (slave) see instructions later - but running the script _add-secondary-2-primary.sh_ does the work required on the primary (Master)

### Known issues:
  - ~~ospd-openvas running as root (it needs that for openvas scanning) however that should be changed to a specific account~~
  - ~~Not tested with separate scanner systems~~

### Latest changes 

### 2021-12-18 - Automated addition of secondary
  - The script add-secondary-2-primary.sh now does everything needed to get a secondary up and running
### 2021-12-12 - NodeJS 14 instead of 12.x with Buster and Bullseye
  - Add packages for nodesource to install node 14.x instead of the lower versions in the Debian repos

### 2021-11-14 - Vagrantfile and bootstrap for testing with vagrant
  - Just added some files for use with VirtualBox and Vagrant

### 2021-10-25 - Correct ospd.sock patch. Without this NVTs, scan configs, and compliance policies do not sync
  - Version 2.0 was borked with wrong path to the ospd socket causing NVT's, scan configs and policies to not synchronize across Openvas/Redis and GVMD/Postgres

### 2021-10-23 - oct 13 bugfixes, moved install to /opt/gvm instead of /usr/local/ and use yarn from Deb repo
  - https://community.greenbone.net/t/new-releases-for-gvm-20-08-and-gvm-21-04/10385
  - Greenbone Security Assistant (GSA) 21.4.3
  - gvmd 21.4.4
  - ospd-openvas 21.4.3
  - openvas-scanner 21.4.3
  - OpenVAS SMB v21.4.0
  - gvm-libs 21.4.3
  - gvm-tools 21.10.0
  - python-gvm 21.11.0

#### 2021-09-14 - Debian 10 and 11 support
  - Works with Debian 10 (Buster) and Debian 11 (Bullseye). Likely to work with most Debian based distros, but some checks in the scripts expect Debian 10 or 11.

#### 2021-05-08 - updated to 21.04.
  - Changed to 21.4.0 versions, as older is retired as of 2021-12-03: https://community.greenbone.net/t/greenbone-os-20-08-retired/10873

#### 2021-09-24 - August Greenbone releases
  - Modified to work with the latest releases from Greenbone: https://community.greenbone.net/t/new-releases-for-gvm-20-08-and-gvm-21-04/10385

## Add Secondary Server 

Runnning a secondary requires a few manual steps, specifically:
 1. On the Primary Server run the _add-secondary-2-primary.sh_ script. It will ask for the hostname and password for user greenbone on the secondary.
 2. The script then does the following;
    a) Copies required certificates to the secondary 
    b) runs the helper script secondary-certs.sh on the secondary to ensure all certificates are in the right location.
    c) configures GVMD to use this scanner.
 3. You can now verify the secondary using either the UI or gvmd with the switch '--verify-scanner='

<img src="./Images/Scanner_Verified.png" alt="Verify Scanner"/>

If this fails, just copy the .pem files from /var/lib/gvm/secondaries/hostname_of_secondary/ to the new secondary, run secondary-certs.sh and ospd-openvas.service should start and scanner can be verified.

Further details on using the commandline gvmd can be found the comments at the end of the install-vuln-scan-2021.sh script.

There's a short companion blog on https://blog.infosecworrier.dk/2020/12/building-your-own-greenbone.html
