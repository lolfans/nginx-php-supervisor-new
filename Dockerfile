FROM php:fpm-alpine3.10
#FROM nginx:1.16-alpine
RUN mkdir -p /run/nginx/
RUN apk add nginx
