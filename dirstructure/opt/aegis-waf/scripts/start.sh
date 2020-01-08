#!/bin/bash
# Aegis Bash Menu

while true
do
PS3='Please Select Option: '
options=("Create DHParam File" "Create HTTP/HTTPS Site and provide SSL Certificate and Key" "Create HTTP/HTTPS Site and provide SSL Certificate and Key Paths" "Create HTTP/HTTPS Site and Request Lets Encrypt Certificate" "Delete Site" "Request Lets Encrypt Certificate Only" "Test Nginx Configuration" "Restart Nginx" "Check Nginx Status" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Create DHParam File")
            /opt/aegis-waf/scripts/create_dhparam.sh
            break
            ;;
        "Create HTTP/HTTPS Site and provide SSL Certificate and Key")
            /opt/aegis-waf/scripts/create_http_https_site_static_cert.sh
            break
            ;;
        "Create HTTP/HTTPS Site and provide SSL Certificate and Key Paths")
            /opt/aegis-waf/scripts/create_http_https_site_path_cert.sh
            break
            ;;
         "Create HTTP/HTTPS Site and Request Lets Encrypt Certificate")
            /opt/aegis-waf/scripts/create_http_https_site_certbot_cert.sh
            break
            ;;
        "Delete Site")
            /opt/aegis-waf/scripts/delete_site.sh
            break
            ;;
        "Request Lets Encrypt Certificate Only")
            /opt/aegis-waf/scripts/request_certbot_cert.sh
            break
            ;;
        "Test Nginx Configuration")
             /etc/init.d/nginx configtest
             break
            ;;
        "Restart Nginx")
            /bin/systemctl restart nginx
            break
            ;;
        "Check Nginx Status")
            /bin/systemctl status nginx
            break
            ;;
        "Exit")
            echo "Exiting...."
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
done
