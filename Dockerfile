#官方php镜像
FROM php:7.2.19-fpm-alpine3.10

#官方安装拓展方式
RUN docker-php-ext-install  pdo_mysql \
&& docker-php-ext-install  tokenizer \
#&& docker-php-ext-install  mongodb 

#命令越少,镜像层数越少,镜像也越小 所以&&可以适当用
#NGINX
RUN mkdir -p /run/nginx/ && apk add nginx

#SUPERVISOR
RUN  apk add supervisor \
	&& rm -rf /var/cache/apk/*

#COMPOSER 
RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin/ --filename=composer
	
	
COPY ./supervisor/conf.d /etc/supervisor/conf.d	
COPY ./crontabs/default /var/spool/cron/crontabs/

COPY ./php/index.php /var/www/html/

COPY ./nginx/default.conf /etc/nginx/conf.d/
COPY ./nginx/ssl.default.config /etc/nginx/conf.d/
COPY ./nginx/nginx.conf /etc/nginx/


ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
