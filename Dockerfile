#官方php镜像
FROM php:7.2.19-fpm-alpine3.10

#官方安装拓展方式

RUN apk add libpng libpng-devel
RUN docker-php-ext-install  pdo_mysql 

ENV TIMEZONE Asia/Shanghai

# Set environments
#RUN sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /usr/local/etc/php7/php.ini 	

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
#COPY ./nginx/ssl.default.config /etc/nginx/conf.d/
COPY ./nginx/nginx.conf /etc/nginx/


ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
