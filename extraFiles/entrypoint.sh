#!/bin/bash

chown -R $MAGENTO_USER:www-data/var/www/html
chown -R $MAGENTO_USER:$MAGENTO_USER /home/$MAGENTO_USER

supervisord -n -c /etc/supervisord.conf
