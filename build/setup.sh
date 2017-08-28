#!/bin/bash
set -eo pipefail

# Enable PHP and Apache 2.4 PPAs
add-apt-repository -y ppa:ondrej/apache2 
add-apt-repository -y ppa:ondrej/php 

# Update installed packages
apt-get -y update 
apt-get -y dist-upgrade 

# Install Apache 2.4 and PHP
apt-get -y install apache2 php$PHP_VERSION-fpm php$PHP_VERSION-mysql php$PHP_VERSION-common php-apcu php-geoip \
	php-imagick php-igbinary php-memcached php-redis php$PHP_VERSION-bcmath php$PHP_VERSION-dba \
	php$PHP_VERSION-enchant php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-intl \
	php$PHP_VERSION-json php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xml \
	php$PHP_VERSION-xmlrpc php-pear php$PHP_VERSION-zip php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring 

# Install mod_cloudflare
wget https://www.cloudflare.com/static/misc/mod_cloudflare/ubuntu/mod_cloudflare-xenial-amd64.latest.deb \
-O /tmp/mod_cloudflare.deb 
dpkg -i /tmp/mod_cloudflare.deb 
rm /tmp/mod_cloudflare.deb 

# Enable modules
a2enmod proxy_fcgi setenvif rewrite headers mime expires 
a2enconf php$PHP_VERSION-fpm 

# Configure logs
a2disconf other-vhosts-access-log 
rm -rf /var/www/* 
chown app:app /var/www 
ln -sf /dev/stdout /var/log/apache2/access.log 
ln -sf /dev/stderr /var/log/apache2/error.log 

# Add Docker's network to trusted IPs, in case there's a proxy in front of Apache
echo 'CloudFlareRemoteIPTrustedProxy 172.16.0.0/12' > /etc/apache2/conf-enabled/cloudflare.conf 

# Change max execution time to 180 seconds
sed -ri 's/(max_execution_time =) ([2-9]+)/\1 180/' /etc/php/$PHP_VERSION/fpm/php.ini 

# Max memory to allocate for each php-fpm process
sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php/$PHP_VERSION/fpm/php.ini 

# Set the timezone - This is my default
sed -ri 's/;(date.timezone =)/\1 Europe\/Copenhagen/' /etc/php/$PHP_VERSION/fpm/php.ini 

# Install default conf
mv /build/apache2/apache2.conf /etc/apache2/apache2.conf
a2dissite 000-default

# Install Dockerize
wget -qO - https://github.com/jwilder/dockerize/releases/download/v0.5.0/dockerize-linux-amd64-v0.5.0.tar.gz \
	| tar zxf - -C /usr/local/bin

# Cleanup
/usr/local/sbin/cleanup.sh
chmod -v +x /etc/my_init.d/* /etc/service/*/run
