
From ubuntu:18.04

WORKDIR /opt
ADD change_src.sh .

VOLUME /var/lib/mongodb

RUN chmod +x change_src.sh\
    && ./change_src.sh\
    && apt-get update\
    && apt-get -y install mongodb net-tools iputils-ping\
    && sed -i '/.*bind_ip.*/cbind_ip = 0.0.0.0' /etc/mongodb.conf

EXPOSE 27017

CMD [ "mongod", "-f", "/etc/mongodb.conf" ]
