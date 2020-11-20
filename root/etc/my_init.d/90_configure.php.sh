#!/bin/bash
set -x

shopt -s nocasematch
: ${GENERATE_DEFAULT_VHOST:="true"}
: ${PHP_SESSION_SAVE_HANDLER:="files"}

if [[ $PHP_SESSION_SAVE_HANDLER == "files" ]]
 then
	export PHP_SESSION_GC_PROPABILITY=0
 else
	export PHP_SESSION_GC_PROPABILITY=1
fi

# Configure php-fpm pool
mkdir -p  /etc/php/${PHP_VERSION}/fpm/pool.d/
dockerize -template /app/php-fpm-pool.tmpl > /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Configure PHP sessions
dockerize -template /app/php-session.tmpl > /etc/php/${PHP_VERSION}/fpm/conf.d/99-sessions.ini

# Configure PHP upload limits
dockerize -template /app/php-upload.tmpl > /etc/php/${PHP_VERSION}/fpm/conf.d/99-upload.ini

# Configure mpm_event
dockerize -template /app/mpm_event.tmpl > /etc/apache2/mods-available/mpm_event.conf

# Configure mod_remoteip
MRIP_CONF="/etc/apache2/conf.d/remoteip.conf"
if [[ "${MOD_REMOTEIP}" == "CLOUDFLARE" ]]
then
	echo "RemoteIPHeader CF-Connecting-IP" > $MRIP_CONF
	for ip in `curl https://www.cloudflare.com/ips-v4`; do echo "RemoteIPTrustedProxy $ip" >> $MRIP_CONF ; done
	for ip in `curl https://www.cloudflare.com/ips-v6`; do echo "RemoteIPTrustedProxy $ip" >> $MRIP_CONF ; done
	echo "RemoteIPInternalProxy 172.16.0.0/12" >> $MRIP_CONF
elif [[ "${MOD_REMOTEIP}" == "DEFAULT" ]]
then
	echo "RemoteIPHeader X-Forwarded-For" >> $MRIP_CONF
	echo "RemoteIPInternalProxy 172.16.0.0/12" >> $MRIP_CONF
fi

# Configure default site
COUNT=`find  /etc/apache2/sites-enabled/ -type f | wc -l`
if [[ $COUNT -eq 0 ]] && [[ $GENERATE_DEFAULT_VHOST != "false" ]]
 then 
	dockerize -template /app/000-default.tmpl > /etc/apache2/sites-enabled/000-default.conf
fi
