#!/bin/bash

#This script will backup the letsencrypt, nginx and aegis-waf folders of your Aegis WAF installation. Ensure that you have made the script executable prior to running it.

#Make script executable
#chmod +x ubuntu_aegis_waf_backup.sh

#The backupretention variable below is in days

#Create a copy of this script to a seperate directory of your Aegis WAF system and schedule it to run via a cronjob. Do not run it from its default location at /opt/aegis-waf/scripts because any updates to Aegis WAF will overwrite this script

#Example crontab entry to run the script located in the /scripts folder every day at 1230 AM
#30 12 * * *  /scripts/ubuntu_aegis_waf_backup.sh

#Ensure rar, sendmail, Perl IO::Socket::SSL and Perl Net::SSLeay are installed
apt install -y rar sendemail libio-socket-ssl-perl libnet-ssleay-perl perl

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
backupretention=14
smtpusername=smtp_username
smtppassword='smtp_password'
smtptls=auto
smtphost=smtp.domain.tld
smtpport=587
emailfrom=someone@domain.tld
emailto=someone@domain.tld
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

#PERFORM THE BACKUP
/usr/bin/rar a -m1 -mt8  $smbmount/aegis-waf-$timestamp.rar /etc/letsencrypt /usr/local/nginx /opt/aegis-waf >> $smbmount/backuplog-$timestamp.log


#delete letsencrypt backup files older than $backupretention days
/usr/bin/find $smbmount -mtime +$backupretention -exec rm {} \;

#Umount Backup Directory
/bin/umount $smbmount

#SEND EMAIL CONFIRMATION
/usr/bin/sendemail -f $emailfrom -t $emailto -u "Aegis WAF backup completed" -m "Aegis WAF backup completed"  -s $smtphost:$smtpport -o username=$smtpusername -o password=$smtppassword -o tls=$smtptls


else

#SEND EMAIL MOUNT ERROR

#SEND EMAIL MOUNT ERROR
/usr/bin/sendemail -f $emailfrom -t $emailto -u "Aegis WAF Backup Mount Backup Error" -m "Unable to mount Aegis WAF backup mount point"  -s $smtphost:$smtpport -o username=$smtpusername -o password=$smtppassword -o tls=$smtptls

fi
