#!/bin/bash


#purge
apt purge apache2* php* zip mariadb-server* -y


#tmp delete
rm -rf /tmp/wp/*

# remove wordpress
apt purge wordpress* -y

# remove expect
apt remove -y expect

# autoremove
apt autoremove -y
