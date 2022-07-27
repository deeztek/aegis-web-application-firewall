#!/bin/bash

#Ensure Script is run as root and if not exit
if [ `id -u` -ne 0 ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "This script must be executed as root, Exiting..."
      exit 1
   fi


#GET INPUTS
read -p "Enter a site name to create a logrotate config: "  SITE

#Check if /etc/logrotate.d/$SITE_access exists
if [ -f "/etc/logrotate.d/$SITE_access" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site logrotate access log config seems to already exist in /etc/logrotate.d/$SITE_access"
      echo "Please delete the existing config before attempting to create it"
      exit 1
   fi

#Check if /etc/logrotate.d/$SITE_error exists
if [ -f "/etc/logrotate.d/$SITE_error" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site logrotate error log config seems to already exist in /etc/logrotate.d/$SITE_error"
      echo "Please delete the existing config before attempting to create it"
      exit 1
   fi

#Check if /etc/logrotate.d/$SITE_modsecurity exists
if [ -f "/etc/logrotate.d/$SITE_error" ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "The site logrotate modsecurity log config seems to already exist in /etc/logrotate.d/$SITE_modsecurity"
      echo "Please delete the existing config before attempting to create it"
      exit 1
   fi


echo "Creating Access Logs Logrotate Config"
/bin/cp /opt/aegis-waf/templates/site_access_logrotate_template /etc/logrotate.d/${SITE}_access

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Access Logs Logrotate"
/bin/sed -i -e "s/THE-SITE/$SITE/g" "/etc/logrotate.d/${SITE}_access" && \
/bin/chmod 0644 /etc/logrotate.d/${SITE}_access

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Error Logs Logrotate Config"
/bin/cp /opt/aegis-waf/templates/site_error_logrotate_template /etc/logrotate.d/${SITE}_error

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Error Logs Logrotate"
/bin/sed -i -e "s/THE-SITE/$SITE/g" "/etc/logrotate.d/${SITE}_error" && \
/bin/chmod 0644 /etc/logrotate.d/${SITE}_error

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Creating Modsecurity Logs Logrotate Config"
/bin/cp /opt/aegis-waf/templates/site_modsecurity_logrotate_template /etc/logrotate.d/${SITE}_modsecurity

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

echo "Configuring Mosecurity Logs Logrotate"
/bin/sed -i -e "s/THE-SITE/$SITE/g" "/etc/logrotate.d/${SITE}_modsecurity" && \
/bin/chmod 0644 /etc/logrotate.d/${SITE}_modsecurity

if [ $? -eq 0 ]; then
    echo "Done"
else
        echo "Error occured. Stopped processing!"
        exit
fi

 echo "Done!"  | boxes -d stone -p a2v1