#!/bin/bash
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password msr@123123'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password msr@123123'
sudo apt-get -y install mysql-server mysql-client
