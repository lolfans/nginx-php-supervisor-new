#官方php镜像
FROM php:fpm-alpine3.10

#命令越少,镜像层数越少,镜像也越小 所以&&可以适当用
RUN mkdir -p /run/nginx/ && apk add nginx

#SUPERVISOR
RUN  apk add supervisor \
	&& rm -rf /var/cache/apk/*

# composer
RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin/ --filename=composer
	
	
COPY ./supervisor/conf.d /etc/supervisor/conf.d	
COPY ./crontabs/default /var/spool/cron/crontabs/

COPY ./php/php-fpm.conf /usr/local/etc/
COPY ./php/www.conf //usr/local/etc/php-fpm.d/
COPY ./php/index.php /var/www/html/

COPY ./nginx/default.conf /etc/nginx/conf.d/
COPY ./nginx/ssl.default.config /etc/nginx/conf.d/
COPY ./nginx/nginx.conf /etc/nginx/


ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
