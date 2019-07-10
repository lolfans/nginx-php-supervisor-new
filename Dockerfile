#官方php镜像
FROM php:7.2.19-fpm-alpine3.10

#官方安装拓展方式
#RUN docker-php-ext-install  pdo_mysql 
#&& docker-php-ext-install  tokenizer \
#&& docker-php-ext-install  mongodb


RUN   echo '@community http://mirrors.aliyun.com/alpine/latest-stable/community' >> /etc/apk/repositories 
ENV TIMEZONE Asia/Shanghai

RUN apk update \
	&& apk upgrade \
	&& apk add \
	php7-redis@community\
	php7-tokenizer@community \
	php7-gd@community \
	php7-mongodb@community \
	php7-fileinfo@community \
	php7-zmq@community \
	php7-memcached@community \
	php7-fpm@community \
	php7-xmlreader@community \
 	&& cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
	&& apk del tzdata \
    && rm -rf /var/cache/apk/*
	
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
