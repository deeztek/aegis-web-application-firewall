SCRIPTPATH=$(pwd)
/bin/cp -r $SCRIPTPATH/dirstructure/opt/aegis-waf/* /opt/aegis-waf && \
/bin/chmod +x /opt/aegis-waf/scripts/*.sh && \
/bin/cp $SCRIPTPATH/dirstructure/etc/letsencrypt/cli.ini /etc/letsencrypt/cli.ini && \
echo "Aegis WAF Update Complete"