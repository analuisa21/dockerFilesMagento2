FROM php:7.0.25-apache

MAINTAINER "Ricardo Ruiz Cruz"

ENV SERVER_NAME		"localhost"
ENV WEBSERVER_USER	"nginx"
ENV MAGENTO_USER	"magento2"

RUN apt-get update
RUN apt-get install apt-utils -y
ADD extraFiles/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug \
	&& echo "zend_extension=\"/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.collect_params   = 4" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.collect_vars = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.dump_globals = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.dump.SERVER = REQUEST_URI" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.show_local_vars = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.cli_color = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN useradd -m -d /home/${MAGENTO_USER} -s /bin/bash ${MAGENTO_USER} && usermod -g www-data ${MAGENTO_USER} 
RUN mkdir /home/$MAGENTO_USER/.ssh
RUN apt-get install supervisor nano vim mysql-client -y && apt-get install -y apache2 \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi
RUN service apache2 restart
RUN 	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN passwd ${MAGENTO_USER} -d
EXPOSE 80 443