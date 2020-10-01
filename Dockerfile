FROM alpine:3.10

MAINTAINER lolfans <313273766@qq.com>

RUN echo '@community https://mirrors.aliyun.com/alpine/v3.10/community' >> /etc/apk/repositories

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk update && apk upgrade && apk add \
	    	gnu-libiconv@community \
	    	php7-curl@community \
	    	php7@community \
	    	php7-dev@community \
	    	php7-apcu@community \
	    	php7-bcmath@community \
	    	php7-xmlwriter@community \
	    	php7-ctype@community \
	    	php7-curl@community \
	    	php7-exif@community \
	    	php7-iconv@community \
	    	php7-intl@community \
	    	php7-json@community \
	    	php7-mbstring@community\
	    	php7-opcache@community \
	    	php7-openssl@community \
	    	php7-pcntl@community \
	    	php7-pdo@community \
	    	php7-mysqlnd@community \
	    	php7-mysqli@community \
	    	php7-pdo_mysql@community \
	    	php7-pdo_pgsql@community \
	    	php7-phar@community \
	    	php7-posix@community \
	    	php7-session@community \
	    	php7-xml@community \
	    	php7-simplexml@community \
	    	php7-mcrypt@community \
	    	php7-xsl@community \
	    	php7-zip@community \
	    	php7-zlib@community \
		php7-dom@community \
	    	php7-redis@community\
	    	php7-tokenizer@community \
	    	php7-gd@community \
		php7-fileinfo@community \
		php7-zmq@community \
		php7-memcached@community \
		php7-xmlreader@community \
		php7-fpm@community \
		&& rm -rf /var/cache/apk/*

# Environments
ENV TIMEZONE            Asia/Shanghai
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M
ENV COMPOSER_ALLOW_SUPERUSER 1

#Alpine System Time
RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
	&& apk del tzdata

#Php.ini Setting
RUN	sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini && \
	sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
	sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini && \
	sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
	sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
	sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php7/php.ini

#Composer install
RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin/ --filename=composer

#SUPERVISOR Install And Edit Setting
RUN apk add supervisor && rm -rf /var/cache/apk/*
COPY ./supervisor/conf.d /etc/supervisor/conf.d	
COPY ./crontabs/default /var/spool/cron/crontabs/

#Php Base Setting
COPY ./php/php-fpm.conf /etc/php7/
COPY ./php/www.conf /etc/php7/php-fpm.d/

#Nginx
RUN apk add nginx && mkdir -p /run/nginx
#Nginx Base Setting
COPY ./nginx/default.conf /etc/nginx/conf.d/
COPY ./nginx/nginx.conf /etc/nginx/

WORKDIR /var/www/html/

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisord.conf"]
