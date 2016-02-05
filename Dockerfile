FROM php:5.6.17-fpm
MAINTAINER Clay Lua <czeeyong@gmail.com>

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
        vim git curl wget build-essential python-software-properties bzip2\
        libfreetype6-dev libtidy-dev\
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev libicu-dev g++ \
        && docker-php-ext-configure intl\
        && docker-php-ext-install -j$(nproc) iconv mcrypt json gd  tidy pdo mysql mysqli intl opcache\
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-enable gd.so iconv.so intl.so json.so mcrypt.so mysql.so mysqli.so opcache.so pdo.so tidy.so


# Expose PHP-FPM port
        EXPOSE 9000
