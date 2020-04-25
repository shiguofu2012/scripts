#!/bin/bash


function force_stop_mysql()
{
    r=`ps aux | grep -v grep | grep 'mysql' | awk -F '\n' '{print $1}' | awk '{print $2}'`
    if [ -n "$r" ]; then
        for pid in ${r}
        do
            echo "kill mysql daemon, $pid..."
            kill -9 $pid
        done
    else
        echo "mysql stopped"
    fi
}


if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysqld --initialize-insecure
    service mysql start
    mysql -e "update mysql.user set plugin='mysql_native_password' where User='root';
        update mysql.user set Host='%' where User='root';flush privileges;
        set password for 'root'@'%'='$MYSQL_PASSWD';flush privileges;"
    if [ ! -z "$DATABASE" ]; then
        SQL="create database if not exists $DATABASE default charset=utf8;"
        echo "$SQL"
        mysql -uroot -p$MYSQL_PASSWD -e "$SQL"
    fi
    if [ ! -z "$MYSQL_INIT_FILE" ]; then
        mysql -uroot -p$MYSQL_PASSWD $DATABASE < $MYSQL_INIT_FILE
    fi
    service mysql stop
    force_stop_mysql
else
    echo "Done..."
fi
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld -R



exec "$@"
