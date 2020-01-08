while true; do
        read -p "Do you wish to create a Diffie-Hellman(DHParam) Key Exchange File? (Enter y or Y)" yn
    case $yn in
        [Yy]* ) echo "Starting Diffie-Hellman (DHParam) Key Exchange File Creation. This process is going to take a VERY long time to complete (~10 minutes on average). Please be patient and wait for the process to complete";cd /usr/local/nginx/conf/ssl/; /usr/bin/openssl dhparam -out dhparam.pem 4096; echo "Diffie-Hellman (DHParam) Key Exchange File was created successfully as /usr/local/nginx/conf/ssl/dhparam.pem! You can now start adding sites to Nginx"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
