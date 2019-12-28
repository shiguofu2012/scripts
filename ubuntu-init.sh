#!/bin/bash

SYS_PACKAGES=( "python" "mysql-server" "python-pip" "libmysqlclient-dev"
    "python3-pip" "git" "net-tools" "redis" "openssl" "libssl-dev" )
PIP_PACKAGES=( "mysql" "redis" )


function check_apt_source()
{
    RET=`cat /etc/apt/sources.list | grep 'mirrors.aliyun.com'`
    if [ -z "$RET" ]; then
        return 0
    fi
    return 1
}

function change_apt_source()
{
    check_apt_source
    if [ $? -eq 1 ]; then
        echo "the source has been changed"
        return
    fi
    urls=(
        "deb http://mirrors.aliyun.com/ubuntu/ distribute main restricted universe multiverse",
        "deb-src http://mirrors.aliyun.com/ubuntu/ distribute main restricted universe multiverse",
        "deb http://mirrors.aliyun.com/ubuntu/ distribute-security main restricted universe multiverse",
        "deb-src http://mirrors.aliyun.com/ubuntu/ distribute-security main restricted universe multiverse",
        "deb http://mirrors.aliyun.com/ubuntu/ distribute-updates main restricted universe multiverse",
        "deb-src http://mirrors.aliyun.com/ubuntu/ distribute-updates main restricted universe multiverse",
        "deb http://mirrors.aliyun.com/ubuntu/ distribute-backports main restricted universe multiverse",
        "deb-src http://mirrors.aliyun.com/ubuntu/ distribute-backports main restricted universe multiverse",
        "deb http://mirrors.aliyun.com/ubuntu/ distribute-proposed main restricted universe multiverse",
        "deb-src http://mirrors.aliyun.com/ubuntu/ distribute-proposed main restricted universe multiverse"
        )
    CODE=`lsb_release -c | awk -F':' '{print $2}'`
    if [ -f "/etc/apt/sources.list" ]; then 
        echo "save the old sources.list to sources.list.bak"
        `mv /etc/apt/sources.list /etc/apt/sources.list.bak`
    fi
    OLD_IFS=$IFS
    IFS=","
    for url in ${urls[@]}; do
        if [ ! -f "/etc/apt/sources.list" ]; then
            echo ${url/distribute/$CODE} > /etc/apt/sources.list
        else
            echo ${url/distribute/$CODE} >> /etc/apt/sources.list
        fi
    done
    IFS=$OLD_IFS
    `apt-get update`
    echo "Done."
}


function install_sys_packages()
{
    for package in ${SYS_PACKAGES[@]}; do
        exists=`which $package`
        if [ -z $exists ]; then
            echo "install package, $package"
            apt-get install $package -y
        fi
    done
}


function change_pip_source()
{
    if [ ! -d ~/.pip ]; then
        echo "mkdir ~/.pip"
        mkdir -p ~/.pip
    fi
    if [ ! -f ~/.pip/pip.conf ]; then
        echo "create file ~/.pip/pip.conf..."
        echo "[global]\nindex-url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pip/pip.conf
    else
        echo "~/.pip/pip.conf exists, maybe you have change it"
    fi
}


function install_pip_packages()
{
    for package in ${PIP_PACKAGES[@]}; do
        pip install $package
    done
}


function installJDK()
{
    `cd /opt && wget http://image.shiguofu.cn/static/jdk1.8.0_144.tar.xz`
    echo "decompress file..."
    cd /opt && xz -z jdk1.8.0_144.tar.xz
    cd /opt && tar -xvf jdk1.8.0_144.tar
    echo "export JAVA_HOME=/opt/jdk1.8.0_144" >> ~/.bashrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
    echo 'export CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> ~/.bashrc
    source ~/.bashrc
}


change_apt_source
install_sys_packages
change_pip_source
install_pip_packages
