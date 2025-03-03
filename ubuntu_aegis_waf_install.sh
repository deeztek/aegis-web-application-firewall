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

#Set install_log Date/Time Stamp
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

echo "Aegis WAF Installation" | boxes -d stone -p a2v1

PS3='Do you wish to continue the installation of Aegis WAF? (Enter y or Y. Warning!! Entering n or N will exit this script and the installation will stop!):'
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")

            echo "Starting Aegis WAF Installation" | boxes -d stone -p a2v1
            echo "${GREEN}During installation a $SCRIPTPATH/install_log-$TIMESTAMP.log log file will be created. It's highly recommended that you open a separate shell window and tail that file in order to view progress of the installation and/or any errors that may occur.${RESET}"

            echo "[`date +%m/%d/%Y-%H:%M`] Starting Aegis WAF Installation." >> $SCRIPTPATH/install_log-$TIMESTAMP.log
          break
            ;;
        "No")

            echo "Exiting Aegis WAF Installation.";
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

echo "[`date +%m/%d/%Y-%H:%M`] Installing Prerequisites" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Installing Prerequisites...'
sleep 1

#Install prerequisites
/usr/bin/apt-get install jq build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev libgeoip-dev libgeoip1 libmaxminddb-dev libmaxminddb0 libyajl-dev libyajl2 liblmdb-dev automake pkgconf haveged unzip unrar sendemail libio-socket-ssl-perl zlib1g-dev libnet-ssleay-perl perl cifs-utils rar -y >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?


echo "[`date +%m/%d/%Y-%H:%M`] Cloning and building Modsecurity" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Cloning and building Modsecurity...'
sleep 1

#Clone and Build Modsecurity
cd /opt >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
rm -rf ModSecurity/ 2>&1 && \
git clone https://github.com/owasp-modsecurity/ModSecurity >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cd ModSecurity >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
git checkout $MODSECURITYVER >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
./build.sh >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
git submodule init >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
git submodule update >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
./configure >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
make >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
make install >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Cloning Modsecurity Nginx Connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Cloning Modsecurity Nginx Connector...'
sleep 1

#Clone Modsecurity Nginx Connector
cd /opt >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
rm -rf ModSecurity-nginx/ 2>&1 && \
git clone https://github.com/owasp-modsecurity/ModSecurity-nginx >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Downloading and Extracting Nginx Version $NGINXVER" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Downloading and Extracting Nginx Version...'
sleep 1

#Download Latest Nginx Version
cd $SCRIPTPATH >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \

wget https://nginx.org/download/$NGINXVER.tar.gz >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
tar -zxf $NGINXVER.tar.gz >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Downloding and Extracting headers-more-nginx-module" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Downloding and Extracting headers-more-nginx-module...'
sleep 1

#Download and extract headers-more-nginx-module
cd /opt >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
rm -rf headers-more-nginx-module-master/ 2>&1 && \
wget https://github.com/openresty/headers-more-nginx-module/archive/master.zip >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
unzip master.zip >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
rm master.zip >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Configuring Nginx with headers-more-nginx-module and Modsecurity-nginx connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Configuring Nginx with headers-more-nginx-module and Modsecurity-nginx connector...'
sleep 1

#Configure Nginx with headers-more-nginx-module and Modsecurity-nginx connector
cd $SCRIPTPATH/$NGINXVER >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
./configure --user=www-data --group=www-data --with-pcre-jit --with-debug --with-http_ssl_module --with-http_realip_module --with-http_geoip_module --with-http_auth_request_module --add-module=/opt/headers-more-nginx-module-master --add-module=/opt/ModSecurity-nginx --prefix=/usr/local/nginx --conf-path=/usr/local/nginx/conf/nginx.conf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
make >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
make install >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp /opt/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Creating Necessary Directories, Symlinks and Files" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Creating Necessary Directories, Symlinks and Files...'
sleep 1

#Create necessary directories, Symlinks and files
mkdir -p /opt/aegis-waf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
mkdir -p /usr/local/nginx/conf/sites-available >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
mkdir -p /usr/local/nginx/conf/sites-enabled >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
mkdir -p /usr/local/nginx/conf/ssl >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
mkdir -p /usr/local/nginx/conf/listen >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
mkdir -p /usr/local/nginx/conf/modsecurity >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
mkdir -p /usr/local/nginx/logs/modsecurity >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp -r $SCRIPTPATH/dirstructure/opt/aegis-waf/* /opt/aegis-waf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp $SCRIPTPATH/dirstructure/usr/local/nginx/conf/modsecurity/unicode.mapping /usr/local/nginx/conf/modsecurity/unicode.mapping >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp $SCRIPTPATH/dirstructure/usr/local/nginx/conf/sites-available/default* /usr/local/nginx/conf/sites-available/ >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
/bin/chmod +x /opt/aegis-waf/scripts/*.sh >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
#/bin/ln -s /usr/local/nginx/sbin/nginx /bin/nginx && \
#/bin/ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx && \
#/bin/ln -s /usr/local/nginx/ /etc/nginx && \
/bin/ln -s /usr/local/nginx/conf/sites-available/default.conf /usr/local/nginx/conf/sites-enabled/default.conf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1


stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Backing up and Re-configuring Nginx" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Backing up and Re-configuring Nginx...'
sleep 1

#Backup /usr/local/nginx/conf/nginx.conf and replace with $SCRIPTPATH/dirstructure/usr/local/nginx/nginx.conf file
cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.ORIGINAL >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp $SCRIPTPATH/dirstructure/usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Configuring Nginx Service" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Configuring Nginx Service...'
sleep 1

#Configure Nginx service
cp $SCRIPTPATH/dirstructure/etc/systemd/system/nginx.service /etc/systemd/system/nginx.service >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
/bin/systemctl enable /etc/systemd/system/nginx.service >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Configuring Nginx with OWASP Modsecurity Core Rule Set" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Configuring Nginx with OWASP Modsecurity Core Rule Set...'
sleep 1

#configure Nginx with OWASP Modsecurity Core Rule Set
cd /opt && \
rm -rf owasp-modsecurity-crs/ 2>&1 && \
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cd owasp-modsecurity-crs/ >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp -R rules/ /usr/local/nginx/conf/ >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp /opt/owasp-modsecurity-crs/crs-setup.conf.example /usr/local/nginx/conf/crs-setup.conf >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Installing Certbot" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Installing Certbot...'
sleep 1

#Install Certbot
/usr/bin/apt-get remove certbot -y >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
/usr/bin/snap install --classic certbot >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
/bin/ln -s /snap/bin/certbot /usr/bin/certbot >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
/usr/bin/certbot --version >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Configuring Certbot" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

start_spinner 'Configuring Certbot...'
sleep 1

#Configure Certbot
mkdir -p /etc/letsencrypt >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
cp $SCRIPTPATH/dirstructure/etc/letsencrypt/cli.ini /etc/letsencrypt/cli.ini >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] Creating Diffie-Hellman (DH) Key Exchange File" >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

echo "==== WARNING ===="  | boxes -d stone -p a2v1
echo "${GREEN}The DH Key Exchange File creation process will take a VERY long time to complete (about ~10 minutes on 1 CPU Machine). ${RESET}"

start_spinner 'Creating DH Key Exchange File. Please be very patient...'
sleep 1

cd /usr/local/nginx/conf/ssl/ >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1 && \
/usr/bin/openssl dhparam -out dhparam.pem 4096 >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

stop_spinner $?

echo "[`date +%m/%d/%Y-%H:%M`] ==== FINISHED INSTALLATION ==== Ensure no errors were logged during installation" >> $SCRIPTPATH/install_log-$TIMESTAMP.log 2>&1

echo "FINISHED INSTALLATION. PLEASE REBOOT YOUR MACHINE!!" | boxes -d stone -p a2v1

echo "Take a look at the $SCRIPTPATH/install_log-$TIMESTAMP.log file for any errors"

echo "Get started creating sites by running /opt/aegis-waf/start.sh"










