FROM php:7.4.1-fpm-alpine3.11
MAINTAINER Clay Lua <czeeyong@gmail.com>

ENV HOME /root

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base

RUN apk add --no-cache icu-dev
RUN apk add --update --no-cache g++ gcc libxslt-dev

# GD installation

RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        freetype \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        jpeg-dev \
        libjpeg \
        libjpeg-turbo-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN NUMPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NUMPROC} gd

RUN apk upgrade --update && apk add \
libzip-dev \
    coreutils \
    freetype-dev \
    libjpeg-turbo-dev \
    libltdl \
    libmcrypt-dev \
    libpng-dev \
oniguruma-dev \ 
    && docker-php-ext-configure intl\
    && docker-php-ext-install -j$(nproc) iconv gd mysqli intl opcache mbstring soap zip \
    && docker-php-ext-enable gd.so iconv.so intl.so mysqli.so opcache.so mbstring.so 

# add ssmtp mail functionality
RUN apk add ssmtp

RUN echo "root=postmaster" >> /etc/ssmtp/ssmtp.conf && \
    echo "mailhub=mail.domain.com:25" >> /etc/ssmtp/ssmtp.conf && \
    echo "hostname=`hostname`" >> /etc/ssmtp/ssmtp.conf && \
    echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf


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
