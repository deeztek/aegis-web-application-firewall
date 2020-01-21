#!/bin/bash

#This script will restore the letsencrypt, nginx and aegis-waf folders from an existing aegis-waf-mm-dd-yyyy-hhmm.rar backup file. Ensure that you have made the script executable prior to running it.

#Make script executable
#chmod +x ubuntu_aegis_waf_restore.sh

#Create a copy of this script to a seperate directory of your Aegis WAF system. Do not run it from its default location at /opt/aegis-waf/scripts because any updates to Aegis WAF will overwrite this script

#Ensure unrar is installed
apt install -y unrar sendemail libio-socket-ssl-perl libnet-ssleay-perl perl cifs-utils

#Ensure Script is run as root and if not exit
if [ `id -u` -ne 0 ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "This script must be executed as root, Exiting..."
      exit 1
   fi


smbdomain='DOMAIN'
smbusername='username'
smbpassword='password'
smbhost=192.168.XXX.XXX
smbshare='/shares/backups/aegis-waf'
smbmount='/mnt/aegisbackup'
restorefile='aegis-waf-mm-dd-yyyy-hhmm.rar'
smbver=3.0
timestamp=`date +%m-%d-%Y-%H%M`

#Check if $smbmount exists and if not create it
if [ ! -d "$smbmount" ]; then
      /bin/mkdir $smbmount
      echo "$smbmount directory does not exist. Creating...."
   fi

#Check if $smbmount exists and if not exit
if [ ! -d "$smbmount" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The $smbmount directory does not exist even after attempting to create automatically. Exiting for now..."
      exit 1
   fi

#Umount Backup Directory
/bin/umount $smbmount

/bin/mount -t cifs -o vers=$smbver,domain=$smbdomain,username=$smbusername,password=$smbpassword //$smbhost$smbshare $smbmount

#CHECK IF MOUNT EXISTS
if mount | grep -q "$smbmount"; then

#PERFORM THE RESTORE
cd /
/usr/bin/unrar x -y $smbmount/$restorefile >> $smbmount/restorelog-$timestamp.log

#Umount Backup Directory
/bin/umount $smbmount

echo "Aegis WAF Restore Complete. Check out the restore log located at $smbmount/restorelog-$timestamp.log for details or any errors during the restore process"


else

echo "Aegis WAF Restore Error. The script was unable to mount the backup directory. Check your settings and try again"

fi
