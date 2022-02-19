#!/bin/bash


#purge
apt purge apache2* php* zip mariadb-server* -y


#tmp delete
rm -rf /tmp/wp

# autoremove
apt autoremove -y 
