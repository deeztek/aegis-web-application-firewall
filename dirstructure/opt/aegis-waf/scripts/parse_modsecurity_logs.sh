#!/bin/bash

#Ensure Script is run as root and if not exit
if [ `id -u` -ne 0 ]; then
      echo "==== ERROR ===="  | boxes -d stone -p a2v1
      echo "This script must be executed as root, Exiting..."
      exit 1
   fi

#Ensure necessary packages are installed
apt install jq -y

INPUTLOGPATH="/usr/local/nginx/logs/modsecurity"
OUTPUTLOGPATH="/home/dedwards"

#GET INPUTS
read -p "Enter a the site name for which to parse modsecurity logs: "  SITE


#cat $INPUTLOGPATH/$SITE/$SITE_audit.log | jq -r '[.EdgeStartTimestamp, .EdgeEndTimestamp, .ClientDeviceType, .ClientRequestUserAgent, .ClientIP, .ClientRequestHost, .OriginResponseStatus, .ClientRequestURI, .ClientRequestReferer, .OriginIP, .SecurityLevel, .WAFAction, .WAFFlags, .WAFMatchedVar, .WAFProfile, .WAFRuleID, .WAFRuleMessage, .EdgeResponseStatus, .EdgeServerIP, .ClientRequestMethod, .ClientRequestPath, .ClientASN] | @csv' > /home/dedwards/modsecurity_output.csv

echo "Looking for Modsecurity logs at $INPUTLOGPATH/$SITE/${SITE}_audit.log"

cat $INPUTLOGPATH/$SITE/${SITE}_audit.log | jq -r '[.transaction.unique_id, .transaction.client_ip, .transaction.time_stamp, .transaction.host_ip, .transaction.host_port, .transaction.request.method, .transaction.request.uri, .transaction.request.headers.Host, .transaction.response.http_code, .transaction.details.ruleId, .transaction.details.match, .transaction.details.data] | @csv' > $OUTPUTLOGPATH/${SITE}_modsecurity_output.csv
