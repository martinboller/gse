# Greenbone Vulnerability Manager 20.08.0 Source Code Edition Installation script

## Bash script automating the installation of Greenbone Vulnerability Manager 20.08.0 on Debian 10

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

### Latest changes 2020-01-16 - now working with secondary ospd-openvas scanner.
This requires a few manual steps, specifically:
 - Copying the already created certificates to the secondary and running the helper script install-secondary-certs
 - Configure GVMD to use this scanner.
 This is all described in the comments at the end of the install-vuln-scan-2020.sh script.

All feedback is welcome and the plan is to maintain this one, contrary to the older GVM10 install-script on my GitHub.

There's a short companion blog on https://blog.infosecworrier.dk/2020/12/building-your-own-greenbone.html
