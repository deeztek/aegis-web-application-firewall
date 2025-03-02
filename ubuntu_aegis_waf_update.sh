#!/bin/bash

#The script below assumes you have a fully installed and updated Ubuntu server

#Ensure Script is run as root and if not exit
if [ `id -u` -ne 0 ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "This script must be executed as root, Exiting..."
      exit 1
   fi


#Set the script path
SCRIPTPATH=$(pwd)

#Set upgrade_log Date/Time Stamp
TIMESTAMP=`date +%m-%d-%Y-%H%M`

#Set Font Colors
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`

echo "Installing Boxes Prerequisite"
#Install boxes
apt-get install boxes -y > /dev/null 2>&1

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "${RED}Error $THEERROR, occurred Installing Boxes Prerequisite ${RESET}"
exit 1
else
echo "${GREEN}Completed Installing Boxes Prerequisite ${RESET}"
fi

echo "Installing Spinner Prerequisite"
#Install spinner
apt-get install spinner -y  > /dev/null 2>&1

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "${RED}Error $THEERROR, occurred Installing Spinner Prerequisite ${RESET}"
exit 1
else
echo "${GREEN}Completed Installing Spinner Prerequisite ${RESET}"
fi

echo "Aegis WAF Upgrade" | boxes -d stone -p a2v1

PS3='Do you wish to continue the installation of Aegis WAF? (Enter y or Y. Warning!! Entering n or N will exit this script and the installation will stop!):'
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")

            echo "Starting Aegis WAF Upgrade" | boxes -d stone -p a2v1
            echo "${GREEN}During upgrade a $SCRIPTPATH/upgrade_log-$TIMESTAMP.log log file will be created. It's highly recommended that you open a separate shell window and tail that file in order to view progress of the installation and/or any errors that may occur.${RESET}"

            echo "[`date +%m/%d/%Y-%H:%M`] Starting Aegis WAF Upgrade." >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log
          break
            ;;
        "No")

            echo "Exiting Aegis WAF Upgrade.";
            exit
            ;;

        *) echo "Invalid option $REPLY ";;
    esac
done

echo -e "\n"

read -p "Browse to https://nginx.org/en/download.html to get the latest ${GREEN}STABLE${RESET} version of Nginx. The latest version will appear in the format nginx-1.XX.X (Example: nginx-1.26.3). Enter the latest stable version (Example: nginx-1.26.3):"  NGINXVER

read -p "Browse to https://github.com/owasp-modsecurity/ModSecurity/releases to get the latest release of Modsecurity and enter it here including the "v" in front of it (Example: v3.0.14):"  MODSECURITYVER

source "$(pwd)/spinner.sh"

# test success
start_spinner 'sleeping for 2 secs...'
sleep 2
stop_spinner $?

#START CONFIGURATION

echo "[`date +%m/%d/%Y-%H:%M`] Installing Prerequisites" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Installing Prerequisites...'
sleep 1

#Install prerequisites
/usr/bin/apt-get install jq build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev libgeoip-dev libgeoip1 libmaxminddb-dev libmaxminddb0 libyajl-dev libyajl2 liblmdb-dev automake pkgconf haveged unzip unrar sendemail libio-socket-ssl-perl zlib1g-dev libnet-ssleay-perl perl cifs-utils rar -y >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?


echo "[`date +%m/%d/%Y-%H:%M`] Cloning and building Modsecurity" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Cloning and building Modsecurity...'
sleep 1

#Clone and Build Modsecurity
cd /opt >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
rm -rf ModSecurity/ 2>&1 && \
git clone https://github.com/owasp-modsecurity/ModSecurity >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
cd ModSecurity >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
git checkout $MODSECURITYVER >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
./build.sh >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
git submodule init >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
git submodule update >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
./configure >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
make >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
make install >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Cloning Modsecurity Nginx Connector" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Cloning Modsecurity Nginx Connector...'
sleep 1

#Clone Modsecurity Nginx Connector
cd /opt >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
rm -rf ModSecurity-nginx/ 2>&1 && \
git clone https://github.com/owasp-modsecurity/ModSecurity-nginx >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Downloading and Extracting Nginx Version $NGINXVER" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Downloading and Extracting Nginx Version...'
sleep 1

#Download Latest Nginx Version
cd $SCRIPTPATH >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \

wget https://nginx.org/download/$NGINXVER.tar.gz >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
tar -zxf $NGINXVER.tar.gz >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Downloding and Extracting headers-more-nginx-module" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Downloding and Extracting headers-more-nginx-module...'
sleep 1

#Download and extract headers-more-nginx-module
cd /opt >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
rm -rf headers-more-nginx-module-master/  2>&1 && \
wget https://github.com/openresty/headers-more-nginx-module/archive/master.zip >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
unzip master.zip >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
rm master.zip >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Configuring Nginx with headers-more-nginx-module and Modsecurity-nginx connector" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Configuring Nginx with headers-more-nginx-module and Modsecurity-nginx connector...'
sleep 1

#Configure Nginx with headers-more-nginx-module and Modsecurity-nginx connector
cd $SCRIPTPATH/$NGINXVER >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
./configure --user=www-data --group=www-data --with-pcre-jit --with-debug --with-http_ssl_module --with-http_realip_module --with-http_geoip_module --with-http_auth_request_module --add-module=/opt/headers-more-nginx-module-master --add-module=/opt/ModSecurity-nginx --prefix=/usr/local/nginx --conf-path=/usr/local/nginx/conf/nginx.conf >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
make >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
make install >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1 && \
cp /opt/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Copying newest Aegis WAF files and scripts" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log

start_spinner 'Copying newest Aegis WAF files and scripts...'
sleep 1

/bin/cp -r $SCRIPTPATH/dirstructure/opt/aegis-waf/* /opt/aegis-waf 2>&1 && \
/bin/chmod +x /opt/aegis-waf/scripts/*.sh 2>&1 && \
/bin/grep -qxF 'deploy-hook = systemctl reload nginx' /etc/letsencrypt/cli.ini || /bin/cp $SCRIPTPATH/dirstructure/etc/letsencrypt/cli.ini /etc/letsencrypt/cli.ini >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] ==== FINISHED UPGRADE ==== Ensure no errors were logged During upgrade" >> $SCRIPTPATH/upgrade_log-$TIMESTAMP.log 2>&1

echo "FINISHED UPGRADE PLEASE REBOOT YOUR MACHINE!!" | boxes -d stone -p a2v1

echo "Take a look at the $SCRIPTPATH/upgrade_log-$TIMESTAMP.log file for any errors"
