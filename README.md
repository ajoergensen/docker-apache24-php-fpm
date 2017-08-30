Apache 2.4 with PHP FPM
=======================

An image with Apache 2.4 and PHP installed from [Ondřej Surý's PPA](https://launchpad.net/~ondrej) for up to date packages.

[phpinfo();](https://ajoergensen.github.io/docker-apache24-php-fpm/phpinfo.html)

#### Why use this image?

- Latest PHP and Apache packages
- Apache and php-fpm is running as user app, fixing a lot of permission headaches
- UID and GID for user app can be changed (See below)

#### Limitations

The configuration does not support SSL out of the box as I usually stick [nginx](https://github.com/ajoergensen/docker-nginx-libressl) in front of any Apache instances I might need.

### Usage

#### Tags

This image is available in three flavors: `5.6`, `7.0`, `7.1` corresponding to the PHP version.

#### Environment

##### General

- `VIRTUAL_HOST`: Sets the ServerName for the default vhost. Only needed if you do not provide your own vhost "site" config
- `SERVER_ADMIN`: Email address for the ServerAdmin variable
- `GENERATE_DEFAULT_VHOST_CONFIG`: By default a basic vhost configuration using the to variables above is generated. Use this switch to disable (true/false)
- `CHOWN_WWWDIR`: Change owner of `/var/www` to `$PUID`:`$PGID`. Default is true, disable if your document root is elsewhere or there is a large number of files in the directory
- `PUID`: Changes the uid of the app user, default 911
- `PGID`: Changes the gid of the app group, default 911
- `SMTP_HOST`: Change the SMTP relay server used by ssmtp (sendmail)
- `SMTP_USER`: Username for the SMTP relay server
- `SMTP_PASS`: Password for the SMTP relay server
- `SMTP_PORT`: Outgoing SMTP port, default 587
- `SMTP_SECURE`: Does the SMTP server requires a secure connection, default TRUE
- `SMTP_TLS`: Use STARTTLS, default TRUE (if SMTP_TLS is FALSE and SMTP_SECURE is true, SMTP over SSL will be used)
- `SMTP_MASQ`: Masquerade outbound emails using this domain, default empty

##### PHP/FPM configuration

- `PHP_SESSION_SAVE_HANDLER`: Sets `session.save_handler`. Default is `files`
- `PHP_SESSION_SAVE_PATH`: Sets the path for saving sessions. Default is `/var/lib/php/sessions`. Use the full URI for Redis or Memcached: `tcp://10.133.14.9:6379?auth=yourverycomplexpasswordhere`
- `PHP_SESSION_GC_DIVISOR`: Sets [session.gc_divisor](https://php.net/manual/en/session.configuration.php#ini.session.gc-divisor). Default is 100
- `PHP_SESSION_GC_PROPABILITY`: Sets [session.gc_probability](https://php.net/manual/en/session.configuration.php#ini.session.gc-probability). Default is 0 if session handler is `files` otherwise 1.
- `FPM_MAX_CHILDREN`: Default is 5
- `FPM_START_SERVER`: Default is 2
- `FPM_MIN_SPARE_SERVERS`: Default is 1
- `FPM_MAX_SPARE_SERVERS`: Default is 2
- `FPM_ERROR_LOG`: Sets the error log of php-fpm. Default is `/dev/fd/2` (stdout)

##### Apache worker configuration

This image uses the [event worker](https://httpd.apache.org/docs/2.4/mod/event.html)

- `MPM_START_SERVERS`: Default is 2
- `MPM_MIN_SPARE_THREADS`: Default is 25
- `MPM_MAX_SPARE_THREADS`: Default is 75
- `MPM_THREADLIMIT`: Default is 64
- `MPM_THREADS_PER_CHILD`: Default is 25
- `MPM_MAX_REQUEST_WORKERS`: Default is 150
- `MPM_MAX_CONNECTIONS_PER_CHILD`: Default is 0

#### Volumes

`/var/www` is defined as a volume; provide your own vhost configuration by adding ```-v ./conf.d:/etc/apache2/site-enabled:ro```.

