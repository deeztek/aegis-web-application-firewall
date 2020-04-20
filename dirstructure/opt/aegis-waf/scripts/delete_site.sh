#!/bin/bash

#Ensure Script is run as root and if not exit
if [ `id -u` -ne 0 ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "This script must be executed as root, Exiting..."
      exit 1
   fi

echo "WARNING" | boxes -d stone -p a2v1
echo "This script will ATTEMPT to delete Lets Encrypt certificates."
echo "You MUST verify that Lets encrypt certificates were indeed removed from their respective /etc/letsencrypt/live/domain.tld directories"
echo "You can also attempt to delete Lets Encrypt Certificates by running the following command: certbot delete --cert-name domain.tld"
echo "This script will prompt you to delete ONLY manually entered certificate and key files"

#GET INPUTS
read -p "Enter a site name to permanently delete: "  SITE

#START DELETING
echo "Removing Nginx logs directory"
#Remove Nginx logs directory
/bin/rm -rf /usr/local/nginx/logs/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error while removing Nginx Logs Directory. Error was $?"
fi

echo "Removing Modsecurity logs directory"
#Remove Modsecurity logs directory
/bin/rm -rf /usr/local/nginx/logs/modsecurity/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error while removing Modsecurity Logs Directory. Error was $?"
fi

echo "Removing sites-available .conf file(s)"
#Remove sites-available .conf file
/bin/rm -rf /usr/local/nginx/conf/sites-available/${SITE}.conf
/bin/rm -rf /usr/local/nginx/conf/sites-available/${SITE}-ssl.conf

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error removing sites-available .conf file. Error was $?"
fi

echo "Removing sites-enabled .conf file(s)"
#Remove sites-enabled .conf file
/bin/rm -rf /usr/local/nginx/conf/sites-enabled/${SITE}.conf
/bin/rm -rf /usr/local/nginx/conf/sites-enabled/${SITE}-ssl.conf

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error removing sites-enabled .conf file. Error was $?"
fi

echo "Removing listen directory"
#Remove listen directory
/bin/rm -rf /usr/local/nginx/conf/listen/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error removing listen Directory. Error was $?"
fi

echo "Removing Modsecurity .conf file"
#Remove Modsecurity .conf file
/bin/rm -rf /usr/local/nginx/conf/modsecurity/${SITE}_modsecurity.conf

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error removing Modsecurity .conf file. Error was $?"
fi

echo "Attempting to remove any existing Lets Encrypt Certificates"
#Remove Lets Encrypt Certificates
/usr/bin/certbot delete --cert-name ${SITE}

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error removing Lets Encrypt Certificates. Error was $? This error may be normal if no Lets Encrypt Certificates existed"
fi

echo "Removing Nginx Site Certbot .well-known Directory Structure"
#Remove Nginx Site Certbot .well-known Directory Structure
/bin/rm -rf /var/www/html/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo "There was an error removing Nginx Site Certbot .well-known Directory Structure. Error was $?"
fi


while true; do
    read -p "Do you wish remove the SSL Certificate and Key Files? (Enter y or Y. Warning!! Entering y or Y will remove the certificate and key files which may break other sites that use those files)" yn
    case $yn in
        [Yy]* ) echo "Removing SSL Certificate and Key Files"; /bin/rm -rf /usr/local/nginx/conf/ssl/${SITE}.pem; /bin/rm -rf /usr/local/nginx/conf/ssl/${SITE}.key;
        echo "Done"; break;;
        [Nn]* ) echo "Done;"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Restarting Nginx"
#RESTART Nginx
/bin/systemctl restart nginx

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

