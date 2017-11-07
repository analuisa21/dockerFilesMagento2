#!/bin/bash

chown -R $MAGENTO_USER:www-data/var/www/html
chown -R $MAGENTO_USER:root /home/$MAGENTO_USER

supervisord -n -c /etc/supervisord.conf