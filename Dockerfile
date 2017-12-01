FROM php:7.0.25-apache

MAINTAINER "Ricardo Ruiz Cruz"

ENV SERVER_NAME		"localhost"
ENV WEBSERVER_USER	"www-data"
ENV MAGENTO_USER	"magento2"
ENV CURRENT_USER_UID	"1001"
ENV MAGENTO_GROUP       "2000"

RUN apt-get update
RUN apt-get install wget apt-utils tcl build-essential -y
RUN apt-get install libmcrypt-dev libicu-dev libxml2-dev libxslt1-dev libfreetype6-dev \
    libjpeg62-turbo-dev libpng12-dev git vim openssh-server ocaml expect -y
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install -j$(nproc) bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl json ldap mbstring mcrypt mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets spl standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip
RUN pecl install xdebug && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.collect_params   = 4" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.collect_vars = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.dump_globals = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.dump.SERVER = REQUEST_URI" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.show_local_vars = on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.cli_color = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN useradd -u ${CURRENT_USER_UID} -m -d /home/${MAGENTO_USER} -s /bin/bash ${MAGENTO_USER} && usermod -g www-data ${MAGENTO_USER} 
RUN mkdir /home/$MAGENTO_USER/.ssh
RUN wget https://www.dotdeb.org/dotdeb.gpg && \
    apt-key add dotdeb.gpg
RUN cat /etc/*release*
ADD extraFiles/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN apt-get install  openssh-server supervisor redis-server nano vim mysql-client -y && apt-get install -y apache2 \
    && a2enmod rewrite \
    && a2enmod proxy \
    && a2enmod proxy_fcgi
RUN 	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN echo 'magento2:123456' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN passwd ${MAGENTO_USER} -d
RUN chown -R ${MAGENTO_USER}:${WEBSERVER_USER} /var/www/html
RUN chown -R ${MAGENTO_USER}:root /home/$MAGENTO_USER
RUN groupmod -g ${MAGENTO_GROUP} www-data
ADD extraFiles/php.ini /usr/local/etc/php
RUN su ${MAGENTO_USER}
EXPOSE 22 80 443
