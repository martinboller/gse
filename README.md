# Greenbone Vulnerability Manager 21.4.x Source Code Edition Installation script

### Bash script automating the installation of Greenbone Vulnerability Manager 21.4.3 (October 2021 releases) on Debian 10 or 11

Installation will be located in /opt/gvm/ and /var/lib/gvm/.

### Design principles:
  - Dedicated to GVM, nothing else.
  - Use the defaults where possible.
  - Least access.
  - Prepared for adding secondaries.

<b>Note</b> The primary server also serves as the Certificate Authority for itself and all secondaries.

During installation a GVM user called 'admin' is created. The generated password for user admin is
stored in the file /var/lib/gvm/adminuser. It is recommended that this password is changed and/or
the file deleted. Do NOT delete the user admin unless you also change the feedowner to another user. This is described elsewhere in this README.

To create a secondary (slave) see instructions later - but running the script _add-secondary-2-primary.sh_ does the work required on the primary, hence this is the preferred method.

## Latest changes

### 2021-12-19 - Greenbone Security Assistant Daemon (GSAD) behind NGINX Proxy
  - In order to benefit from the security features of NGINX, GSAD is now being proxied through that.
  - Connect directly to https://servername/ and NGINX will proxy to GSAD as well as redirect if you forget https.

### 2021-12-18 - Automated addition of secondary
  - The script add-secondary-2-primary.sh now does everything needed to get a secondary up and running.
  - Provided the primary can connect to the secondary over SSH/SCP and the configured port, that is port 22 and 9390.
  - Port 9390 used to communicate with secondaries can be changed in the scripts.<sup>1</sup> 

<sup>1</sup> I've successfully used 3389/TCP on networks that wouldn't allow port 9390 "for security" but allowed RDP across all networks. (Yeah, those stupid rules exist).

### 2021-12-12 - NodeJS 14 instead of 12.x with Buster and Bullseye
  - Add packages for nodesource to install node 14.x instead of the lower versions in the Debian repos. According to Greenbone documentation Node >= 14 is required.

### 2021-11-14 - Vagrantfile and bootstrap for testing with vagrant
  - Just added some files for use with VirtualBox and Vagrant.

### 2021-10-25 - Correct ospd.sock patch. Without this NVTs, scan configs, and compliance policies do not sync
  - Version 2.0 was borked with wrong path to the ospd socket causing NVT's, scan configs and policies to not synchronize across Openvas/Redis and GVMD/Postgres.

### 2021-10-23 - oct 13 bugfixes, moved install to /opt/gvm instead of /usr/local/ and use yarn from Deb repo
  - https://community.greenbone.net/t/new-releases-for-gvm-20-08-and-gvm-21-04/10385
  - Greenbone Security Assistant (GSA) 21.4.3
  - gvmd 21.4.4
  - ospd-openvas 21.4.3
  - openvas-scanner 21.4.3
  - OpenVAS SMB v21.4.0
  - gvm-libs 21.4.3
  - gvm-tools 21.10.0
  - python-gvm 21.11.0 (as of December 2021)

#### 2021-09-14 - Debian 10 and 11 support
  - Works with Debian 10 (Buster) and Debian 11 (Bullseye). Likely to work with most Debian based distros, but some checks in the scripts expect Debian 10 or 11.

#### 2021-05-08 - updated to 21.04.
  - Changed to 21.4.0 versions, as all older versions are retired as of 2021-12-03: https://community.greenbone.net/t/greenbone-os-20-08-retired/10873.

#### 2021-09-24 - August Greenbone releases
  - Modified to work with the latest releases from Greenbone: https://community.greenbone.net/t/new-releases-for-gvm-20-08-and-gvm-21-04/10385.

## Production Installation
### 1. Install a basic (net-install) Debian 11 (Bullseye) or 10 (Buster) server for the primary

Run <i>install-GSE-2021.sh</i> and wait for a (long) while. 
- The primary needs at least 4Gb of RAM, preferably more.

<b>Note:</b> I've had so many issues with TEX, which currently is resolved by installing texlive-full, which takes forever. Debian has a quirk here that breaks apt when not installing texlive-full.

### 2. Install as many basic (net-install) Debian 11 (Bullseye) or 10 (Buster) servers needed for secondaries
Run <i>install-GSE-2021-secondary.sh</i> and wait for installation to finish. 
- This works in 1Gb of RAM, but more is recommended
- Raspberry Pi's work well, however has only been tested on RPi 4's with 2Gb and more
- The latest RaspiOS is based on Bullseye, use the Raspberry Pi OS Lite (it is supposed to run as a server after all)

### 3. Add secondaries
Run <i>add-secondary-2-primary.sh</i> on the primary.
- You need to provide the folowing to the script (both will be provided when the installation of the secondary finishes).
    - hostname or IP address of the secondary.
    - Pasword of the user Greenbone on the secondary.
- This will add the new secondary to GVMD.
- Provided the primary can connect to the secondary over ssh the certs and key needed will be copied to the secondary and ospd-openvas restarted.

The <i>add-secondary-2-primary.sh</i> does the following.
    a) Copies required certificates to the secondary.
    b) runs the helper script secondary-certs.sh on the secondary to ensure all certificates are in the right location.
    c) restarts ospd-openvas on the secondary.
    c) configures GVMD to use this scanner.
 3. You can now verify the secondary using either the UI or gvmd with the switch '--verify-scanner=' as discussed later in this README.

<img src="./Images/Scanner_Verified.png" alt="Verify Scanner"/>

If this fails, just copy the .pem files from /var/lib/gvm/secondaries/hostname_of_secondary/ to the new secondary, run secondary-certs.sh and ospd-openvas.service should start and scanner can be verified. Follow the steps under <b>Manual Installation</b> below.


## Vagrant installation
Provided you have Vagrant and VirtualBox installed, installation is "just".
1. ``` git clone https://github.com/martinboller/gse.git ``` 
2. ``` cd /gse/ ```
3. ``` vagrant up ```

### In reality you might have to do the following the first time to build the testlab:
Packages required:
- VirtualBox https://www.virtualbox.org/
- Vagrant https://www.vagrantup.com/downloads

### Installation
#### VirtualBox
- Install VirtualBox on your preferred system (MacOS or Linux is preferred) as described on the VirtualBox website.
- Install the VirtualBox Extensions.

Both software titles can be downloaded from https://www.virtualbox.org/ They can also be added to your package manager, which help with keeping them up-to-date. This can also easily be changed to run with VMWare.

#### Vagrant
- Install Vagrant on your system as described on the Vagrant website.
- Vagrant is available at https://www.vagrantup.com/downloads.

### Testlab
This will install a primary called "manticore" and a secondary called "aboleth", which can be changed inside "Vagrantfile".
Prerequisite: A DHCP server on the network, alternatively change the NIC to use a static or NAT within Vagrantfile.
 - Create a directory with ample space for Virtual Machines, e.g. /mnt/mydata/VMs.
 - Configure VirtualBox to use that directory for Virtual Machines by default.
 - Change directory into /mnt/mydata/Environments/.
 - Run git clone https://github.com/martinboller/gse.git.
 - Change directory into /mnt/mydata/Environments/sf-build/.
 - Execute vagrant up and wait for the OS to install.

You may have to select which NIC to use for this e.g. wl02p01.
Logon to the website on the server https://manticore (if you have not changed the hostname and DNS works. If not, use the ip address).
 
The first install will take longer, as it needs to download the Vagrant box for Debian 11 (which this build is based on) first, however that’ll be reused in subsequent installations.


## Other useful tips and tricks
### Scanners

The first OpenVas scanner is always UUID: 08b69003-5fc2-4037-a479-93b440211c73.
The script verifies bot the OpenVAS and the GVMD Scanner by running.
For OpenVAS:

```
su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 08b69003-5fc2-4037-a479-93b440211c73'
```

Which should return this (Version Oct. 2021).

<i>Scanner version: OpenVAS 21.4.3.</i>

For GVM:
```
su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner 6acd0832-df90-11e4-b9d5-28d24461215b'
```
Which should return this (Version Oct. 2021).

<i>Scanner version: GVM/21.4.4. </i>


### Admin Account
During install an Admin user is created, and the initial password stored here: 
```
cat /opt/gvm/lib/adminuser.
```

It is good security practice to change this (do it now):
```
/opt/gvm/sbin/gvmd --user admin --new-password 'Your new password'
```

### Feed Owner
The admin account is import feed owner: https://community.greenbone.net/t/gvm-20-08-missing-report-formats-and-scan-configs/6397/2
So do <b><u>not</b></u> delete this account, unless you reconfigure it to be another. <b><u>Do</b></u> remember to change its initial password as discussed here.

#### <i><b><u>Without a feed owner there will be no feeds!!</b></u> (ask me how I know)</i>


If you want to change feedowner, the following commands can be used to create another account and make that the feedowner. You can also just change it in install-GSE-2021.sh <u>before</u> running it the first time.

```
su gvm -c '/opt/gvm/sbin/gvmd --create-user=MyOwnUser'
```

Get the UUIDs of all users.
```
su gvm -c '/opt/gvm/sbin/gvmd --get-users --verbose'
```

Or just for your newly created user.
```
su gvm -c '/opt/gvm/sbin/gvmd --get-users --verbose | grep MyOwnUser'
```

Pick the UUID for the one you just created in the list provided and replace <i>UUID of new account</i> below.

```
su gvm -c '/opt/gvm/sbin/gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value UUID of new account' 
```

### Useful logs
- tail -f /var/log/gvm/ospd-openvas.log < By default only provide informational logging, but enabling debug logging is great for t-shooting.
- tail -f /var/log/gvm/gvmd.log < How is GVM in general behaving, and can it communicate with both local and remote scanners (secondaries).
- tail -f /var/log/gvm/openvas-log < This is very useful when scanning, not least on a secondary.
- tail -f /var/log/syslog | grep -i gse < The installation scripts log a lot of what they do, this will follow along during installation.


### Manually adding a secondary
#### 1. On the primary; Create the certificate and key needed (The primary is the CA for all secondaries as well as itself)
create a directory for the files needed, and:
- copy the gsecert.cfg file into that directory. Modify it to reflect your certificate requirements (it works as is and creates wildcard cert)
- cd into the directory, and run the following:
```
/opt/gvm/sbin/gvm-manage-certs -e ./gsecert.cfg -v -d -c
```

Before doing the above, verify if the required certificates can be created by add-secondary-2-primary.sh, as that will still do most of the work even if not able to copy the required files to the secondary.

#### 2. On the secondary, do as follows to get the certs and keys in place:
Copy the created secondary-cert.pem, secondary-key.pem, as well as the cacert.pem file to the secondary (the cacert.pem can be found in /var/lib/gvm/CA/ on the primary)
```
su gvm -c 'cp ./secondary-cert.pem /var/lib/gvm/CA/'
su gvm -c 'cp ./secondary-key.pem /var/lib/gvm/private/CA/'
su gvm -c 'cp ./cacert.pem /var/lib/gvm/CA/'
```

Restart ospd-openvas:
```
systemctl restart ospd-openvas.service
```

Update Openvas feed:
```
su gvm -c '/opt/gvm/sbin/openvas --update-vt-info'
```

#### 3. On the primary, create the scanner in GVMD
Whereever the required files (secondary-cert.pem and secondary-key.pem) are:

```
chown gvm:gvm *.pem
su gvm -c '/opt/gvm/sbin/gvmd --create-scanner="OSP Scanner secondary hostname" --scanner-host=hostname --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondary-cert.pem --scanner-key-priv=./secondary-key.pem'
```

Example:
```
su gvm -c '/opt/gvm/sbin/gvmd --create-scanner="OpenVAS Secondary host aboleth" --scanner-host=aboleth --scanner-port=9390 --scanner-type="OpenVas" --scanner-ca-pub=/var/lib/gvm/CA/cacert.pem --scanner-key-pub=./secondary-cert.pem --scanner-key-priv=./secondary-key.pem'
```
Which should output this:
<i>Scanner created.</i>
 

#### 4. Verification steps on the primary

``` 
su gvm -c '/opt/gvm/sbin/gvmd --get-scanners'
```
Outputting something like this (the UUID will be different for the scanner just created)
<i>
08b69003-5fc2-4037-a479-93b440211c73  OpenVAS  /var/run/ospd/ospd-openvas.sock  0  OpenVAS Default
6acd0832-df90-11e4-b9d5-28d24461215b  CVE    0  CVE
3e2232e3-b819-41bc-b5be-db52bfb06588  OpenVAS  mysecondary  9390  OSP Scanner mysecondary
</i>

Verify the added secondary
```
su gvm -c '/opt/gvm/sbin/gvmd --verify-scanner=3e2232e3-b819-41bc-b5be-db52bfb06588'
```
Which, provided the scanner works, should return this:

<i>
Scanner version: OpenVAS 21.4.3.
</i>

<b>Congrats, You have now added a secondary manually</b>

### Other useful commands
Just after installation, going from empty feeds to fully up-to-date, you'll notice that postgres is being hammered by gvmd and that redis are by ospd-openvas as openvas-scanner uses Redis (on the secondary only ospd-openvas, openvas, and redis is running). When feeds are updated this isn't as obvious, as the delta is significantly less than "everything".
Use ps or top to follow along - the UI also show that the feeds are updating under <i>Administration -> Feed Status</i>.

<img src="./Images/GSE-Update_in_Progress.png" alt="Update in progress"/>


<img src="./Images/postgres.png" alt="Update in progress, top"/>


#### <u>Hang in there, depending on your server it will take quite a while.</u>

### Blog Post
There's a short companion blogpost on https://blog.infosecworrier.dk/2020/12/building-your-own-greenbone.html
