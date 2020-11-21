#!/bin/bash
set -eo pipefail

for i in 5.6 7.0 7.1 7.2 7.3 7.4 8.0
 do
	docker build -t apache24-php-fpm:$i -f Dockerfile.php$i .
	docker run -d --name apache24-php$i-fpm apache24-php-fpm:$i
	docker ps
	sleep 4
	docker logs apache24-php$i-fpm
	docker exec apache24-php$i-fpm pgrep apache2
	docker rm -f apache24-php$i-fpm
	docker rmi -f apache24-php-fpm:$i
done
