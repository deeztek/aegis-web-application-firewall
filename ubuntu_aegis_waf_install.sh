#!/bin/bash

#The script below assumes you have a fully installed and updated Ubuntu 18.04 server 

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

#Set Latest Nginx Version as of 12/26/2019
NGINXVER=1.17.9

#Script Debug Set Variables. Do not enable unless you are troubleshooting


#Install boxes
apt install boxes -y

echo "Aegis WAF Installation" | boxes -d stone -p a2v1
echo "During installation a $SCRIPTPATH/install_log-$TIMESTAMP.log log file will be created. It's highly recommended that you open a separate shell window and tail that file in order to view progress of the installation and/or any errors that may occur."

while true; do
    read -p "Do you wish to continue the installation of Aegis WAF? (Enter y or Y. Warning!! Entering n or N will exit this script and the installation will stop!)" yn
    case $yn in
        [Yy]* ) echo "[`date +%m/%d/%Y-%H:%M`] Starting Aegis WAF Installation. View progress at $SCRIPTPATH/install_log-$TIMESTAMP.log" >> $SCRIPTPATH/install_log-$TIMESTAMP.log; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done




#START CONFIGURATION

echo "Starting Installation... View progress of installation and/or any errors in $SCRIPTPATH/install_log-$TIMESTAMP.log file located in the path you started this script"
echo "==== STARTING INSTALLATION ====" >> $SCRIPTPATH/install_log-$TIMESTAMP.log


echo "[`date +%m/%d/%Y-%H:%M`] STEP 1 OF 11. Installing Prerequisites" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Install prerequisites
/usr/bin/apt install -y \
build-essential \
libpcre3 \
libpcre3-dev \
libssl-dev \
libtool \
autoconf \
apache2-dev \
libxml2-dev \
libcurl4-openssl-dev \
libgeoip-dev \
libgeoip1 \
libmaxminddb-dev \
libmaxminddb0 \
libyajl-dev \
libyajl2 \
liblmdb-dev \
automake \
pkgconf \
haveged \
unzip \
unrar \
sendemail \
libio-socket-ssl-perl \
libnet-ssleay-perl \
perl \
cifs-utils \
rar 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 1 OF 11: $ERR, occurred while installing prerequisites" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 1 OF 11. Completed installing prerequisites" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 2 OF 11. Cloning and building Modsecurity" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Clone and Build Modsecurity
cd /opt && \
/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity && \
cd ModSecurity && \
/usr/bin/git checkout v3.0.4 && \
sh build.sh && \
/usr/bin/git submodule init && \
/usr/bin/git submodule update && \
./configure && \
make && \
make install 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log



ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 2 OF 11: $ERR, occurred while cloning and building Modsecurity" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 2 OF 11. Completed cloning and building Modsecurity" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 3 OF 11. Cloning Modsecurity Nginx Connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Clone Modsecurity Nginx Connector
cd /opt && \
/usr/bin/git clone https://github.com/SpiderLabs/ModSecurity-nginx.git 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 3 OF 11: $ERR, occurred while cloning Modsecurity Nginx Connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 3 OF 11. Completed cloning Modsecurity Nginx Connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi


echo "[`date +%m/%d/%Y-%H:%M`] STEP 4 OF 11. Downloading and Extracting Nginx Version $NGINXVER" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Download Latest Nginx Version
cd $SCRIPTPATH && \
/usr/bin/wget http://nginx.org/download/nginx-$NGINXVER.tar.gz && \
/bin/tar -zxf nginx-$NGINXVER.tar.gz 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 4 OF 11: $ERR, occurred during downloading and extracting Nginx Version $NGINXVER" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 4 OF 11. Completed downloading and extracting Nginx Version $NGINXVER" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 5 OF 11. Downloding and Extracting headers-more-nginx-module" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Download and extract headers-more-nginx-module
cd /opt && \
/usr/bin/wget https://github.com/openresty/headers-more-nginx-module/archive/master.zip && \
/usr/bin/unzip master.zip && \
/bin/rm master.zip 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 5 OF 11: $ERR, occurred while downloading and extracting headers-more-nginx-module" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 5 OF 11. Completed and extracting headers-more-nginx-module" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 6 OF 11. Configuring Nginx with headers-more-nginx-module and Modsecurity-nginx connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Configure Nginx with headers-more-nginx-module and Modsecurity-nginx connector
cd $SCRIPTPATH/nginx-$NGINXVER && \
./configure --user=www-data --group=www-data --with-pcre-jit --with-debug --with-http_ssl_module --with-http_realip_module --with-http_geoip_module --add-module=/opt/headers-more-nginx-module-master --add-module=/opt/ModSecurity-nginx --prefix=/usr/local/nginx --conf-path=/usr/local/nginx/conf/nginx.conf && \
make && \
make install && \
/bin/cp /opt/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log


ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 6 OF 11: $ERR, occurred while configuring Nginx with headers-more-nginx-module and Modsecurity-nginx connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 6 OF 11. Completed configuring Nginx with headers-more-nginx-module and Modsecurity-nginx-connector" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 7 OF 11. Creating Necessary Directories, Symlinks and Files" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Create necessary directories, Symlinks and files
/bin/mkdir -p /opt/aegis-waf && \
/bin/mkdir -p /usr/local/nginx/conf/sites-available && \
/bin/mkdir -p /usr/local/nginx/conf/sites-enabled && \
/bin/mkdir -p /usr/local/nginx/conf/ssl && \ 
/bin/mkdir -p /usr/local/nginx/conf/listen && \ 
/bin/mkdir -p /usr/local/nginx/conf/modsecurity && \
/bin/mkdir -p /usr/local/nginx/logs/modsecurity && \
/bin/cp -r $SCRIPTPATH/dirstructure/opt/aegis-waf/* /opt/aegis-waf && \
/bin/cp $SCRIPTPATH/dirstructure/usr/local/nginx/conf/modsecurity/unicode.mapping /usr/local/nginx/conf/modsecurity/unicode.mapping && \
/bin/cp $SCRIPTPATH/dirstructure/usr/local/nginx/conf/sites-available/default* /usr/local/nginx/conf/sites-available/ && \
/bin/chmod +x /opt/aegis-waf/scripts/*.sh && \
#/bin/ln -s /usr/local/nginx/sbin/nginx /bin/nginx && \
#/bin/ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx && \
#/bin/ln -s /usr/local/nginx/ /etc/nginx && \
/bin/ln -s /usr/local/nginx/conf/sites-available/default.conf /usr/local/nginx/conf/sites-enabled/default.conf 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log


ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 7 OF 11: $ERR, occurred while creating necessary directories, symlinks and files" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 7 OF 11. Completed creating necessary directories, symlinks and files" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 8 OF 11. Backing up and Re-configuring Nginx" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Backup /usr/local/nginx/conf/nginx.conf and replace with $SCRIPTPATH/dirstructure/usr/local/nginx/nginx.conf file
/bin/cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.ORIGINAL && \
/bin/cp $SCRIPTPATH/dirstructure/usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 8 OF 11: $ERR, occurred while backing and re-configuring Nginx" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 8 OF 11. Completed backing up and re-configiring Nginx" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 9 OF 11. Configuring Nginx Service" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Configure Nginx service
/bin/cp $SCRIPTPATH/dirstructure/etc/systemd/system/nginx.service /etc/systemd/system/nginx.service && \
/bin/systemctl enable /etc/systemd/system/nginx.service 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 9 OF 11: $ERR, occurred while configuring Nginx Service" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 9 OF 11. Completed configuring Nginx Service" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 10 OF 11. Configuring Nginx with OWASP Modsecurity Core Rule Set" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#configure Nginx with OWASP Modsecurity Core Rule Set
cd /opt/ && \
/usr/bin/git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git && \
cd owasp-modsecurity-crs/ && \
/bin/cp -R rules/ /usr/local/nginx/conf/ && \
/bin/cp /opt/owasp-modsecurity-crs/crs-setup.conf.example /usr/local/nginx/conf/crs-setup.conf 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 10 OF 11: $ERR, occurred while Configuring Nginx with OWASP Modsecurity Core Rule Set" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 10 OF 11. Completed Configuring Nginx with OWASP Modsecurity Core Rule Set" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "[`date +%m/%d/%Y-%H:%M`] STEP 11 OF 11. Installing Certbot" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

#Install Certbot
/usr/bin/add-apt-repository ppa:certbot/certbot -y && \
/usr/bin/apt install python-certbot-nginx -y 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log

ERR=$?
if [ $ERR != 0 ]; then
THEERROR=$(($THEERROR+$ERR))
echo "[`date +%m/%d/%Y-%H:%M`] ERROR STEP 11 OF 11: $ERR, occurred while installing Certbot" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
exit 1
else
echo "[`date +%m/%d/%Y-%H:%M`] SUCCESS STEP 11 OF 11. Completed installing Certbot" >> $SCRIPTPATH/install_log-$TIMESTAMP.log
fi

echo "==== WARNING ===="  | boxes -d stone -p a2v1
echo "Would you like for this script to create a Diffie-Hellman (D-H) Key Exchange File for you? If you choose YES the file creation process will take a VERY long time to complete (about ~10 minutes on average). If you choose NO, you MUST create a Diffie-Hellman Key Exchange File on your own before you can start adding sites to Nginx. The script /opt/aegis-waf/scripts/create_dhparam.sh can be used to create one."

while true; do
    read -p "Do you want this script to create a Diffie-Hellman (D-H) Key Exchange File for you? Enter Y or y:" yn
    case $yn in
        [Yy]* ) echo "[`date +%m/%d/%Y-%H:%M`] STEP 11 OF 11: Creating Diffie-Hellman (D-H) Key Exchange File" >> $SCRIPTPATH/install_log-$TIMESTAMP.log; echo "Creating Diffie-Hellman (D-H) Key Exchange File. Please be VERY patient and wait for the process to complete..."; cd /usr/local/nginx/conf/ssl/ 2>> $SCRIPTPATH/install_log-$TIMESTAMP.log; /usr/bin/openssl dhparam -out dhparam.pem 4096; echo "Diffie-Hellman (D-H) Key Exchange File Creation is complete!"; echo "[`date +%m/%d/%Y-%H:%M`] SUCESS STEP 11 OF 11: Completed Creating Diffie-Hellman (D-H) Exchange File" >> $SCRIPTPATH/install_log-$TIMESTAMP.log; break;;
        [Nn]* ) echo "[`date +%m/%d/%Y-%H:%M`] STEP 11 OF 11: Skipping Creating Diffie-Hellman (D-H) Key Exchange File" >> $SCRIPTPATH/install_log-$TIMESTAMP.log; echo "Skipping Creating Diffie-Hellman (D-H) Key Exchange File. You must run the /opt/aegis-waf/scripts/create_dhparam.sh script before you can start adding sites to Nginx"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "[`date +%m/%d/%Y-%H:%M`] ==== FINISHED INSTALLATION ==== Ensure no errors were logged during installation" >> $SCRIPTPATH/install_log-$TIMESTAMP.log

echo "FINISHED INSTALLATION. PLEASE REBOOT YOUR MACHINE!!" | boxes -d stone -p a2v1

echo "Take a look at the $SCRIPTPATH/install_log-$TIMESTAMP.log file for any errors"

echo "Get started creating sites by running /opt/aegis-waf/start.sh"










