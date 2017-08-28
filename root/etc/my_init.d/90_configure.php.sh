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

# Configure mpm_event
dockerize -template /app/mpm_event.tmpl > /etc/apache2/mods-available/mpm_event.conf

# Configure default site
COUNT=`find  /etc/apache2/sites-enabled/ -type f`
if [[ $COUNT -eq 0 ]] && [[ $GENERATE_DEFAULT_VHOST != "false" ]]
 then 
	dockerize -template /app/000-default.tmpl > /etc/apache2/sites-enabled/000-default.conf
fi
