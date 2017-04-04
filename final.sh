#!/bin/bash
sudo apt-get install -y mysql-server
sudo /opt/mysql/bin/mysql-conf setup
sudo apt-get update
sudo apt-get install mysql-server
