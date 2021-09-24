# Greenbone Vulnerability Manager 21.4.x Source Code Edition Installation script

## Bash script automating the installation of Greenbone Vulnerability Manager 21.4.2 (August 2021 releases) on Debian 10 or 11 (20.8.0 will eol end of 2021)

Installation will be located in /usr/local/, which is the default for GVM SCE.

### Design principles:
  - Dedicated to GVM, nothing else
  - Use the defaults where possible
  - Least access

During installation a GVM user called 'admin' is created. The generated password for User admin is
stored in the file /usr/local/var/lib/adminuser. It is recommended that this password is changed and/or
the file deleted. Do NOT delete the user admin unless you also change the feedowner to another user.

A BIG Thank You to Greenbone Networks GmbH for supporting the security community, especially Björn Ricks (https://twitter.com/BjoernRicks).

### Known issues:
  - ~~ospd-openvas running as root (it needs that for openvas scanning) however that should be changed to a specific account~~
  - ~~Not tested with separate scanner systems~~

### Latest changes 
#### 2021-09-24 - August Greenbone releases
  Modified to work with the latest releases from Greenbone
#### 2021-09-14 - Debian 10 and 11 support
  Works with Debian 10 (Buster) and Debian 11 (Bullseye). Likely to work with most Debian based distros, but some checks in the scripts expect Debian 10 or 11.
#### 2021-05-08 - updated to 21.4.0.
  Changed to 21.4.0 versions

Runnning a secondary requires a few manual steps, specifically:
 - Copying the already created certificates to the secondary and running the helper script install-secondary-certs
 - Configure GVMD to use this scanner.
 This is all described in the comments at the end of the install-vuln-scan-2021.sh script.

All feedback is welcome and the plan is to maintain this one, contrary to the older GVM10 install-script on my GitHub.

There's a short companion blog on https://blog.infosecworrier.dk/2020/12/building-your-own-greenbone.html
