#!/bin/bash

#Ensure Script is run as root and if not exit
if [ `id -u` -ne 0 ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "This script must be executed as root, Exiting..."
      exit 1
   fi

#Check if /usr/local/nginx/conf/ssl/dhparam.pem exists and if not exit
if [ ! -f "/usr/local/nginx/conf/ssl/dhparam.pem" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "Diffie-Hellman Key Exchange File does NOT Exist. Please run /opt/aegis-waf/scripts/create_dhparam.sh script to create one and then try to create a site, Exiting for now..."
      exit 1
   fi

#GET INPUTS
read -p "Enter a certificate name: "  CERTNAME
read -p "Enter a PRIMARY ROOT domain for the Site without www. in front of it (Example: domain.tld OR host.domain.tld): "  DOMAIN
read -p "Enter any additional sub-domains separated by a comma (Example: www.domain.tld). Leave blank and press enter if none: "  SECDOMAIN

#START CONFIGURATION

echo "Creating Nginx Site Listen Directory"
#CREATE LISTEN DIRECTORY
/bin/mkdir -p /usr/local/nginx/conf/listen/$CERTNAME

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Nginx Site Certbot .well-known Directory Structure"
#CREATE /var/www/html/SITE and /var/www/html/SITE/.well-known directories
/bin/mkdir -p /var/www/html/$CERTNAME && \
/bin/echo "TEST" > /var/www/html/$CERTNAME/index.html
/bin/mkdir -p /var/www/html/$CERTNAME/.well-known
#/bin/mkdir -p /var/www/html/$CERTNAME/.well-known/acme-challenge/
#/bin/echo "TEST" > /var/www/html/$CERTNAME/.well-known/acme-challenge/test.html
#/bin/chmod -R 755 /var/www/html/$CERTNAME/.well-known/


if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Nginx HTTP Listen Conf File for Certbot"
#COPY listenHTTP.conf and listenHTTPS TO DOMAIN LISTEN DIRECTORY
/bin/cp /opt/aegis-waf/templates/listenHTTP.conf /usr/local/nginx/conf/listen/$CERTNAME

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi



echo "Creating Nginx HTTP Site Conf File for Certbot"
#CREATE WEBSITE NGINX CONFIG FILE
/bin/cp /opt/aegis-waf/templates/http_template_site_cert_only.conf /usr/local/nginx/conf/sites-available/${CERTNAME}.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

#IF SECDOMAIN IS EMPTY THEN SET ALLDOMAIN TO $DOMAIN IF NOT SET ALLDOMAIN TO $DOMAIN AND $SECDOMAIN
if [ -z "$SECDOMAIN" ]
then
ALLDOMAIN=$DOMAIN
     
else
ALLDOMAIN="$DOMAIN,$SECDOMAIN"
    
fi


echo "Configuring Nginx HTTP Conf File Domain"
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-DOMAIN/$DOMAIN/g" "/usr/local/nginx/conf/sites-available/$CERTNAME.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx HTTP Conf File Site"
#REPLACE ALL INSTANCES OF THE-SITE WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-SITE/$CERTNAME/g" "/usr/local/nginx/conf/sites-available/$CERTNAME.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi


echo "Enabling HTTP site in Nginx"
#CREATE HARD LINK FROM NGINX SITES-AVAILABLE TO NGINX SITES-ENABLED
/bin/ln -s /usr/local/nginx/conf/sites-available/$CERTNAME.conf /usr/local/nginx/conf/sites-enabled/$CERTNAME.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Restarting Nginx"
#RESTART Nginx
/bin/systemctl restart nginx

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

#=== DO NOT ENABLE BELOW UNLESS TROUBLESHOOTING ===
#echo "Pausing for 5 seconds waiting for Nginx"
#sleep 5
#=== DO NOT ENABLE ABOVE UNLESS TROUBLESHOOTING ===

#=== DO NOT ENABLE BELOW UNLESS TROUBLESHOOTING ===
#echo "Testing Webroot Test File"
#CREATE /var/www/html/SITE and /var/www/html/SITE/.well-known directories
#/usr/bin/curl http://$DOMAIN/.well-known/acme-challenge/test.html

#if [ $? -eq 0 ]; then
#    echo "Done"
#else
#        echo "Error occured. Stopped processing!"
#        exit
#fi
#DO NOT ENABLE ABOVE UNLESS TROUBLESHOOTING


echo "Requesting Letsencrypt Certificate"
#Request Letsencrypt Certificate
echo /usr/bin/certbot certonly --noninteractive --webroot --agree-tos --register-unsafely-without-email -d ${ALLDOMAIN} -w /var/www/html/$CERTNAME

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi



