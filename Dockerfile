FROM php:7.4-fpm
MAINTAINER Clay Lua <czeeyong@gmail.com>

ENV HOME /root

RUN apt-get update && apt-get install -y \
                bison \
                libcurl4-openssl-dev \
                libedit-dev \
                libonig-dev \
                libsodium-dev \
                libsqlite3-dev \
                libssl-dev \
                libxml2-dev \
                zlib1g-dev \
            libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) iconv gd mysqli intl opcache mbstring xml soap

EXPOSE 9000
