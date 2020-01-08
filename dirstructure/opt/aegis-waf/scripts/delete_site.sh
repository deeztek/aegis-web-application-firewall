#!/bin/bash

#GET INPUTS
read -p "Enter a site name to permanently delete: "  SITE

#START DELETING
echo "Removing Nginx logs directory"
#Remove Nginx logs directory
/bin/rm -rf /usr/local/nginx/logs/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error while removing Nginx Logs Directory. Error was $?
fi

echo "Removing Modsecurity logs directory"
#Remove Modsecurity logs directory
/bin/rm -rf /usr/local/nginx/logs/modsecurity/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error while removing Modsecurity Logs Directory. Error was $?
fi

echo "Removing sites-available .conf file(s)"
#Remove sites-available .conf file
/bin/rm -rf /usr/local/nginx/conf/sites-available/${SITE}.conf
/bin/rm -rf /usr/local/nginx/conf/sites-available/${SITE}-ssl.conf

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error removing sites-available .conf file. Error was $?
fi

echo "Removing sites-enabled .conf file(s)"
#Remove sites-enabled .conf file
/bin/rm -rf /usr/local/nginx/conf/sites-enabled/${SITE}.conf
/bin/rm -rf /usr/local/nginx/conf/sites-enabled/${SITE}-ssl.conf

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error removing sites-enabled .conf file. Error was $?
fi

echo "Removing listen directory"
#Remove listen directory
/bin/rm -rf /usr/local/nginx/conf/listen/$SITE

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error removing listen Directory. Error was $?
fi

echo "Removing Modsecurity .conf file"
#Remove Modsecurity .conf file
/bin/rm -rf /usr/local/nginx/conf/modsecurity/${SITE}_modsecurity.conf

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error removing Modsecurity .conf file. Error was $?
fi

echo "Removing certificate .pem file"
#Remove certificate .pem file
/bin/rm -rf /usr/local/nginx/conf/ssl/${SITE}.pem

if [ $? -eq 0 ]; then
    echo Done
else
        echo There was an error removing .pem file. Error was $?
fi

echo "Removing key .key file"
#Remove key .key file
/bin/rm -rf /usr/local/nginx/conf/ssl/${SITE}.key

if [ $? -eq 0 ]; then
    echo Done. Reload Nginx for changes to take effect!
else
        echo There was an error removing .key file. Error was $?
fi
