FROM ubuntu:18.04

WORKDIR /opt
# sys apt-get source change to aliyun
ADD change_src.sh .
# change mysql password
ADD add_mysql_passwd.sh .
ADD chpasswd.sql .
RUN mkdir -p /var/app\
    && mkdir -p /run/sshd\
    && mkdir -p ~/.ssh\
    && chmod +x change_src.sh\
    && chmod +x add_mysql_passwd.sh\
    && ./change_src.sh\
    && apt-get install net-tools iputils-ping ssh -y\
    && apt-get install mongodb ssh mysql-server -y\
    && ./add_mysql_passwd.sh\
    && echo "#!/bin/bash\n\
sed -i '/.*bind_ip.*/cbind_ip = 0.0.0.0' /etc/mongodb.conf\n\
sed -i '/.*bind-address.*/cbind-address = 0.0.0.0' /etc/mysql/mysql.conf.d/mysqld.cnf\n\
service mongodb start\n\
service mysql start\n\
/usr/sbin/sshd -D" > /opt/start.sh\
    && chmod +x /opt/start.sh
# 增加ssh key，用于ssh
ADD authorized_keys /root/.ssh/
EXPOSE 3306
EXPOSE 27017
EXPOSE 22


# 编译成功后运行
# docker run -d -p 27017:27017 -p 3306:3306 -p 222:22 [tag] sh /opt/start.sh
# 如果需要数据库的文件到宿主机，增加-v选项映射目录到宿主机
# 可通过ssh root@localhost -p 222登录
