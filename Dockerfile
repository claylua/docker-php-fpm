FROM php:7.4-fpm-buster
MAINTAINER Clay Lua <clay@twopiz.com>

ENV HOME /root


# Container containing php-fpm and php-cli to run and interact with eZ Platform and other Symfony projects
#
# It has two modes of operation:
# - (run.sh cmd) [default] Reconfigure eZ Platform/Publish based on provided env variables and start php-fpm
# - (bash|php|composer) Allows to execute composer, php or bash against the image

# Set defaults for variables used by run.sh
ENV COMPOSER_HOME=/root/.composer

# Get packages that we need in container
RUN apt-get update -q -y \
    && apt-get install -q -y --no-install-recommends \
        ca-certificates \
        curl \
        acl \
        sudo \
	cron \
	wget \
	screen \
# Disable expired Let's Encrypt certificate
    && sed -i '/mozilla\/DST_Root_CA_X3.crt/ s/./!&/' /etc/ca-certificates.conf \
    && update-ca-certificates --verbose \
# Needed for the php extensions we enable below
    && apt-get install -q -y --no-install-recommends \
        libfreetype6 \
        libjpeg62-turbo \
        libxpm4 \
        libpng16-16 \
        libicu63 \
        libxslt1.1 \
        libmemcachedutil2 \
        libzip4 \
        imagemagick \
        libonig5 \
        libpq5 \ 
# git & unzip needed for composer, unless we document to use dev image for composer install
# unzip needed due to https://github.com/composer/composer/issues/4471
        unzip \
        git \
# packages useful for dev
        less \
        mariadb-client \
        vim \
        wget \
        tree \
        gdb-minimal \
    && rm -rf /var/lib/apt/lists/*

# Install and configure php plugins
RUN set -xe \
    && buildDeps=" \
        $PHP_EXTRA_BUILD_DEPS \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxpm-dev \
        libpng-dev \
        libicu-dev \
        libxslt1-dev \
        libmemcached-dev \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
        libmagickwand-dev \
        libpq-dev \
    " \
	&& apt-get update -q -y && apt-get install -q -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
# Extract php source and install missing extensions
    && docker-php-source extract \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-xpm=/usr/include/ --enable-gd-jis-conv \
    && docker-php-ext-install exif gd mbstring intl xsl zip mysqli pdo_mysql pdo_pgsql pgsql soap bcmath \
    && docker-php-ext-enable opcache \
    && cp /usr/src/php/php.ini-production ${PHP_INI_DIR}/php.ini \
    \
# Install imagemagick
    && for i in $(seq 1 3); do pecl install -o imagick && s=0 && break || s=$? && sleep 1; done; (exit $s) \
    && docker-php-ext-enable imagick 

RUN cd /tmp \
	&& curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_7.4.ini


# Set timezone
RUN echo "UTC+8" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata


# Create Composer directory (cache and auth files) & Get Composer
RUN mkdir -p $COMPOSER_HOME \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Needed for docker-machine
RUN usermod -u 1000 www-data
RUN chown -R www-data:www-data /home/

EXPOSE 9000
