#!/bin/bash

#GET INPUTS
read -p "Enter a site name: "  SITE
read -p "Enter a domain(s) for the Site (Multiple domains must be separated by a space): "  DOMAIN
read -p "Enter a destination url including http(s):// (Example: http://www.domain.tld for HTTP Only or https://www.domain.tld for HTTPS) Do NOT include a Port Number: "  DESTINATION
read -p "Enter a Destination Port Number for the Site (Example: 80 for http or 443 for https):" PORT

#START CONFIGURATION
echo Creating Nginx Logs Directory.....
#CREATE NGINX LOGS DIRECTORY
/bin/mkdir /usr/local/nginx/logs/$SITE


if [ $? -eq 0 ]; then
    echo "Done"
else
	echo "Error occured. Stopped processing!" 
	exit
fi
 
echo Creating Modsecurity Logs Directory.....
#CREATE MODSECURITY LOGS DIRECTORY
/bin/mkdir /usr/local/nginx/logs/modsecurity/$SITE


echo Creating Nginx Site Listen Directory.....
#CREATE LISTEN DIRECTORY
/bin/mkdir /usr/local/nginx/conf/listen/$SITE

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Creating Nginx Listen Conf Files......
#COPY listenHTTP.conf and listenHTTPS TO DOMAIN LISTEN DIRECTORY
/bin/cp /opt/aegis-waf/templates/listenHTTP.conf /usr/local/nginx/conf/listen/$SITE

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi


echo Creating Nginx Site Conf File.....
#CREATE WEBSITE NGINX CONFIG FILE
/bin/cp /opt/aegis-waf/templates/http_template_site.conf /usr/local/nginx/conf/sites-available/${SITE}.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Creating Modsecurity Site Conf File.....
#CREATE MODSECURITY CONFIG FILE
/bin/cp /opt/aegis-waf/templates/modsecurity_template_site.conf /usr/local/nginx/conf/modsecurity/${SITE}_modsecurity.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Configuring Nginx Conf File Domain.....
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-DOMAIN/$DOMAIN/g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Configuring Nginx Conf File Site.....
#REPLACE ALL INSTANCES OF THE-SITE WITH DOMAIN VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s/THE-SITE/$SITE/g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Configuring Nginx Conf File Destination.....
#REPLACE ALL INSTANCES OF THE-DESTINATION WITH DESTINATION VARIABLE ON NGINX CONFIG FILE

/bin/sed -i -e "s,THE-DESTINATION,${DESTINATION},g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Configuring Nginx Conf File Port.....
#REPLACE ALL INSTANCES OF THE-PORT WITH PORT VARIABLE ON NGINX CONFIG FILE
/bin/sed -i -e "s,THE-PORT,${PORT},g" "/usr/local/nginx/conf/sites-available/$SITE.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Configuring Modsecurity Site Conf File.....
#REPLACE ALL INSTANCES OF THE-DOMAIN WITH DOMAIN VARIABLE ON MODSECURITY CONFIG FILE
/bin/sed -i -e "s/THE-DOMAIN/$SITE/g" "/usr/local/nginx/conf/modsecurity/${SITE}_modsecurity.conf"

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo Enabling site in Nginx.....
#CREATE HARD LINK FROM NGINX SITES-AVAILABLE TO NGINX SITES-ENABLED
/bin/ln -s /usr/local/nginx/conf/sites-available/$SITE.conf /usr/local/nginx/conf/sites-enabled/$SITE.conf

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi



