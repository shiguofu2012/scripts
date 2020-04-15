FROM ubuntu:18.04

WORKDIR /opt
# sys apt-get source change to aliyun
ADD change_src.sh .
ADD requirements.txt .
ADD install_deps.sh .
RUN mkdir -p /var/app\
    && echo "net.core.somaxconn = 2048" >> /etc/sysctl.conf\
    && mkdir -p /run/sshd\
    && mkdir -p ~/.ssh\
    && chmod +x change_src.sh\
    && ./change_src.sh\
    && apt-get install net-tools iputils-ping ssh sudo -y\
    && apt-get install python python-pip libmysqlclient-dev git nginx -y\
    && pip install -r requirements.txt\
    && chmod +x install_deps.sh\
    && ./install_deps.sh\
    && echo "#!/bin/bash\n\
service nginx start\n\
/usr/sbin/sshd -D" > /opt/start.sh\
    && chmod +x /opt/start.sh

# 增加ssh key，用于ssh
ADD authorized_keys /root/.ssh/
ADD service.shiguofu.cn.conf /etc/nginx/sites-enabled/
EXPOSE 80
EXPOSE 22


# 可通过ssh root@localhost -p 222登录
