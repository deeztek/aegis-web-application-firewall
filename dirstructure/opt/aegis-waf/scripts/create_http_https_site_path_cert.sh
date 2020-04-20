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
read -p "Enter a site name: "  SITE
read -p "Enter a domain(s) for the Site (Multiple domains must be separated by a space): "  DOMAIN
read -p "Enter a destination url including http(s):// (Example: http://www.domain.tld for HTTP Only or https://www.domain.tld for HTTPS) Do NOT include a Port Number: "  DESTINATION
read -p "Enter a Destination Port Number for the Site (Example: 80 for http or 443 for https):" PORT
read -p "Enter the path where SSL Certificate is stored:" PEMPATH
read -p "Enter the path where SSL Unencrypted Key is stored:" KEYPATH
read -p "Enter SSL Protocols you wish to enable separated by a space (Example: TLSv1.1 TLSv1.2 TLSv1.3):" SSLPROTOCOLS

#Check if /usr/local/nginx/conf/sites-available/$SITE.conf exists
if [ -f "/usr/local/nginx/conf/sites-available/$SITE.conf" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site seems to already exist in /usr/local/nginx/conf/sites-available/$SITE.conf"
      echo "Please delete the site before attempting to create it"
      exit 1
   fi

#Check if /usr/local/nginx/conf/sites-available/$SITE-ssl.conf exists
if [ -f "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site seems to already exist in /usr/local/nginx/conf/sites-available/$SITE-ssl.conf"
      echo "Please delete the site before attempting to create it"
      exit 1
   fi

#Check if /usr/local/nginx/conf/sites-enabled/$SITE.conf exists
if [ -f "/usr/local/nginx/conf/sites-enabled/$SITE.conf" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site seems to already exist in /usr/local/nginx/conf/sites-enabled/$SITE.conf"
      echo "Please delete the site before attempting to create it"
      exit 1
   fi

#Check if /usr/local/nginx/conf/sites-enabled/$SITE-ssl.conf exists
if [ -f "/usr/local/nginx/conf/sites-enabled/$SITE-ssl.conf" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site seems to already exist in /usr/local/nginx/conf/sites-enabled/$SITE-ssl.conf"
      echo "Please delete the site before attempting to create it"
      exit 1
   fi

#START CONFIGURATION
echo "Creating Nginx Logs Directory"
#CREATE NGINX LOGS DIRECTORY
/bin/mkdir -p /usr/local/nginx/logs/$SITE


if [ $? -eq 0 ]; then
    echo "Done"
else
	echo "Error occured. Stopped processing!" 
	exit
fi
 
echo "Creating Modsecurity Logs Directory"
#CREATE MODSECURITY LOGS DIRECTORY
/bin/mkdir -p /usr/local/nginx/logs/modsecurity/$SITE


echo "Creating Nginx Site Listen Directory"
#CREATE LISTEN DIRECTORY
/bin/mkdir -p /usr/local/nginx/conf/listen/$SITE

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating HTTP Nginx Listen Conf File"
#COPY listenHTTP.conf and listenHTTPS TO DOMAIN LISTEN DIRECTORY
/bin/cp /opt/aegis-waf/templates/listenHTTP.conf /usr/local/nginx/conf/listen/$SITE

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Modsecurity Site Conf File"
#CREATE MODSECURITY CONFIG FILE
/bin/cp /opt/aegis-waf/templates/modsecurity_template_site.conf /usr/local/nginx/conf/modsecurity/${SITE}_modsecurity.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Nginx HTTP Site Conf File"
#CREATE WEBSITE NGINX CONFIG FILE
/bin/cp /opt/aegis-waf/templates/http_template_site.conf /usr/local/nginx/conf/sites-available/${SITE}.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi


echo "Configuring Nginx HTTP Conf File Domain"
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-DOMAIN/$DOMAIN/g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx HTTP Conf File Site"
#REPLACE ALL INSTANCES OF THE-SITE WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-SITE/$SITE/g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx HTTP Conf File Destination"
#REPLACE ALL INSTANCES OF THE-DESTINATION WITH DESTINATION VARIABLE ON NGINX CONFIG FILE

/bin/sed -i -e "s,THE-DESTINATION,${DESTINATION},g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx HTTP Conf File Port"
#REPLACE ALL INSTANCES OF THE-PORT WITH PORT VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s,THE-PORT,${PORT},g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Enabling HTTP site in Nginx"
#CREATE HARD LINK FROM NGINX SITES-AVAILABLE TO NGINX SITES-ENABLED
/bin/ln -s /usr/local/nginx/conf/sites-available/$SITE.conf /usr/local/nginx/conf/sites-enabled/$SITE.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Nginx HTTPS Listen Conf File"
#COPY listenHTTP.conf and listenHTTPS TO DOMAIN LISTEN DIRECTORY
/bin/cp /opt/aegis-waf/templates/listenHTTPS.conf /usr/local/nginx/conf/listen/$SITE


if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Nginx HTTPS Site Conf File"
#CREATE WEBSITE NGINX CONFIG FILE
/bin/cp /opt/aegis-waf/templates/https_template_site_path.conf /usr/local/nginx/conf/sites-available/${SITE}-ssl.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Site SSL Certificate Path"
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s|THE-CERTIFICATE-PATH|$PEMPATH|g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Site SSL key Path"
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s|THE-KEY-PATH|$KEYPATH|g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx Conf File Domain"
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-DOMAIN/$DOMAIN/g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx Conf File Site"
#REPLACE ALL INSTANCES OF THE-SITE WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-SITE/$SITE/g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx Conf File Destination"
#REPLACE ALL INSTANCES OF THE-DESTINATION WITH DESTINATION VARIABLE ON NGINX CONFIG FILE

/bin/sed -i -e "s,THE-DESTINATION,${DESTINATION},g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx Conf File Port"
#REPLACE ALL INSTANCES OF THE-PORT WITH PORT VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s,THE-PORT,${PORT},g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Nginx Conf File SSL Protocols"
#REPLACE ALL INSTANCES OF THE-PORT WITH PORT VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s,THE-PROTOCOLS,${SSLPROTOCOLS},g" "/usr/local/nginx/conf/sites-available/$SITE-ssl.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi


echo "Configuring Modsecurity Site Conf File"
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON MODSECURITY CONFIG FILE
/bin/sed -i -e "s/THE-DOMAIN/$SITE/g" "/usr/local/nginx/conf/modsecurity/${SITE}_modsecurity.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi


echo "Enabling HTTPS site in Nginx"
#CREATE HARD LINK FROM NGINX SITES-AVAILABLE TO NGINX SITES-ENABLED
/bin/ln -s /usr/local/nginx/conf/sites-available/$SITE-ssl.conf /usr/local/nginx/conf/sites-enabled/$SITE-ssl.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi



