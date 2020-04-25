
From ubuntu:18.04

WORKDIR /opt
ADD change_src.sh .

# mysql envirentment set, the user is root default

ENV DATABASE minipro
ENV MYSQL_PASSWD P@55word
# 初始化数据库，建表以及导入数据操作
ENV MYSQL_INIT_FILE /init_db.sql

VOLUME /var/lib/mysql
ADD entrypoint.sh /
ADD init_db.sql /

RUN chmod +x change_src.sh\
    && chmod +x /entrypoint.sh\
    && ./change_src.sh\
    && apt-get update\
    && apt-get -y install mysql-server net-tools iputils-ping\
    && sed -i '/.*bind-address.*/cbind-address = 0.0.0.0' /etc/mysql/mysql.conf.d/mysqld.cnf


ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 3306

CMD ["mysqld_safe"]
