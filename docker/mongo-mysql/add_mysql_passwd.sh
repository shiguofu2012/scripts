#!/bin/bash

# start msyql
service mysql start
mysql < chpasswd.sql
service mysql restart
mysql < chpasswd.sql
