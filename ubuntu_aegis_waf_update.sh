SCRIPTPATH=$(pwd)
/bin/cp -r $SCRIPTPATH/dirstructure/opt/aegis-waf/* /opt/aegis-waf && \
/bin/chmod +x /opt/aegis-waf/scripts/*.sh && \
echo "Aegis WAF Update Complete"