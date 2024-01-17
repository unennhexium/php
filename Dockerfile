ARG PHP_FPM_VERSION="8"

FROM php:${PHP_FPM_VERSION}-fpm
SHELL [ "bash", "-c" ]

ARG XDEBUG_VERSION="3.3.1"
ARG XDEBUG_PORT="9001"

ARG COMPOSER_VERSION="2.6.6"

ARG PHP_UNIT_VERSION="10.5.6"

ARG PHPSTAN_VERSION="1.10.55"
ARG LARASTAN_VERSION="2.8.1"
ARG PHPSTAN_EXT_INSTALLER_VERSION="1.3.1"

ARG L5_SWAGGER_VERSION="8.5.2"

# Uncomment if you want to install pgsql-related extensions
#RUN apt-get update && apt-get install -y libpq-dev \
#    && docker-php-ext-install pgsql \
#    && docker-php-ext-install pdo_pgsql

RUN pecl install xdebug-${XDEBUG_VERSION}

RUN cat <<EOT >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"
zend_extension=xdebug.so
xdebug.mode=develop,debug
xdebug.start_with_request=yes
xdebug.discover_client_host=0
xdebug.client_host=host.docker.internal
xdebug.client_port=${XDEBUG_PORT}
xdebug.log=/var/log/xdebug.log
error_reporting=E_ALL
EOT

# Change to `php.ini-production` in production
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

WORKDIR /tmp
RUN apt-get update && apt-get install -y wget git unzip \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && composer_signature="$(wget -O - https://composer.github.io/installer.sig)" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '$composer_signature') \
        { echo 'Installer verified'; } else \
        { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --version=${COMPOSER_VERSION} --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Uncomment if you want to install Laravel app with Laravel Installer
#RUN apt-get install -y git unzip \
#  composer global require laravel/installer:5.2.1

RUN composer global require phpunit/phpunit:${PHP_UNIT_VERSION}

RUN composer global require phpstan/phpstan:${PHPSTAN_VERSION} \
  && composer global config --no-plugins allow-plugins.phpstan/extension-installer true \
  && composer global require phpstan/extension-installer:${PHPSTAN_EXT_INSTALLER_VERSION} \
  && composer global require larastan/larastan:${LARASTAN_VERSION}

RUN composer global require darkaonline/l5-swagger
#RUN composer global require darkaonline/l5-swagger:${L5_SWAGGER_VERSION}

ENV PATH="$PATH:/root/.composer/vendor/bin"

RUN mkdir /var/www/api
WORKDIR /var/www/api
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php-fpm"]
EXPOSE 9000
