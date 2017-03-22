FROM php:7.1.3-fpm-alpine
MAINTAINER Clay Lua <czeeyong@gmail.com>

ENV HOME /root

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base

RUN apk add --no-cache icu-dev
RUN apk upgrade --update && apk add \
    coreutils \
    freetype-dev \
    libjpeg-turbo-dev \
    libltdl \
    libmcrypt-dev \
    libpng-dev \
    && docker-php-ext-configure intl\
    && docker-php-ext-install -j$(nproc) iconv mcrypt json gd pdo mysqli intl opcache pdo pdo_mysql  mbstring \
    && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-freetype-dir=/usr/include/freetype2 \
    --with-png-dir=/usr/include \
    --with-jpeg-dir=/usr/include \
    && docker-php-ext-enable gd.so iconv.so intl.so json.so mcrypt.so mysqli.so opcache.so pdo.so 




# Expose PHP-FPM port
        EXPOSE 9000
