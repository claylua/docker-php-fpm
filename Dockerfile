FROM php:7.2.4-fpm-alpine3.6
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
    && docker-php-ext-install -j$(nproc) iconv json gd pdo mysqli intl opcache pdo pdo_mysql mysqli pdo_mysql json mbstring \
    && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-freetype-dir=/usr/include/freetype2 \
    --with-png-dir=/usr/include \
    --with-jpeg-dir=/usr/include \
    && docker-php-ext-enable gd.so iconv.so intl.so json.so mysqli.so opcache.so pdo.so mbstring.so

# Add Memcache support

ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev
RUN apk add --no-cache --update libmemcached-libs zlib
RUN set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
    && pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
    && rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps

# Add Redis support

ENV PHPREDIS_VERSION 4.0.0

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

# Expose PHP-FPM port
        EXPOSE 9000
