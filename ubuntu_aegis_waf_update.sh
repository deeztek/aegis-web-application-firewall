SCRIPTPATH=$(pwd)
/bin/cp -r $SCRIPTPATH/dirstructure/opt/aegis-waf/* /opt/aegis-waf && \
/bin/chmod +x /opt/aegis-waf/scripts/*.sh && \
/bin/grep -qxF 'deploy-hook = systemctl reload nginx' /etc/letsencrypt/cli.ini || echo -e 'deploy-hook = systemctl reload nginx' >> /etc/letsencrypt/cli.ini
echo "Aegis WAF Update Complete"