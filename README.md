**About**

Aegis WAF provides a Nginx reverse-proxy with libmodsecurity (Modsecurity 3.x) with OWASP Modsecurity Core Rule Set (CRS) and Certbot (Let's Encrypt Certificates) support.

**Requirements**

You must ensure that you allow BOTH incoming **TCP/80** and **TCP/443** to your Aegis WAF machine.

**Installation**

Aegis WAF can be easily installed in your existing Ubuntu 18.04 server machine by utilizing the included **ubuntu_aegis_waf_install.sh** script. The script requires that you have a fully updated Ubuntu 18.04 server installation.

**Quick script install and run instructions**

Git clone the Aegis WAF repository:

`sudo git clone https://github.com/deeztek/aegis-web-application-firewall.git`

This will clone the repository and create a aegis-waf directory in the directory you ran the git clone command from.

Change to the aegis-waf directory:

`cd aegis-web-application-firewall/`

Run the script as root:

`bash ubuntu_aegis_waf_install.sh`

The script will install all required components and install Aegis WAF on the /opt/aegis-waf directory

**Getting Started**

Start creating sites by running the **/opt/aegis-waf/scripts/start.sh** script

**Notes**

New sites will be created under /usr/local/nginx/conf/sites-enabled. By default Modsecurity, automatic redirection from HTTP to HTTPS  and HSTS are disabled.

Enable Modsecurity by uncommenting the following section in BOTH corresponding HTTP and HTTPS .conf files:

`modsecurity on;`

`modsecurity_rules_file /usr/local/nginx/conf/modsecurity/THE-SITE_modsecurity.conf;`


Enable HTTP to HTTPS automatic redirection by uncommenting the following section in the corresponding site HTTP ONLY .conf file:

`return 301 https://$host$request_uri;`

Enable HSTS by uncommenting the following section in the corresponding site HTTPS ONLY .conf file (Exercise caution before enabling HSTS for your site because it will commit your site to serve HTTPS only content. Ensure the site works as desired before enabling):

`add_header Strict-Transport-Security "max-age=31536000; preload";`

**Documentation**

Coming soon...

**Support**

Support can be obtained by visiting our Aegis WAF Forums at:

[https://forums.deeztek.com/viewforum.php?f=33](https://forums.deeztek.com/viewforum.php?f=33)

**Updating**

If Aegis WAF Git directory does NOT exist, git clone the Aegis WAF repository:

`sudo git clone https://github.com/deeztek/aegis-web-application-firewall.git`

If Aegis WAF Git directory exists, change to the existing aegis-waf git directory and git pull the Aegis WAF repository:

`cd /path/to/aegis-web-application-firewall`
`sudo git pull https://github.com/deeztek/aegis-web-application-firewall.git`

This will clone all the changes to the aegis-web-application-firewall directory.

Run the update script as root:

`bash ubuntu_aegis_waf_update.sh`

