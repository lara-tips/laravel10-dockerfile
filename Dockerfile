FROM --platform=linux/amd64 php:8.2-apache-buster

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions @composer-2.6.5 bcmath mbstring pdo_mysql sodium mysqli zip exif pcntl gd memcached 

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libonig-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install mbstring
RUN docker-php-ext-enable intl mbstring

RUN docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install pdo pdo_mysql

RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install nodejs
RUN node -v

RUN apt-get install -y libmagickwand-dev libmagickcore-dev
RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick

COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
RUN sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf