#!/bin/bash

chown -R $MAGENTO_USER:$WEBSERVER_USER /var/www/html
chown -R $MAGENTO_USER:root /home/$MAGENTO_USER

supervisord -n -c /etc/supervisord.conf