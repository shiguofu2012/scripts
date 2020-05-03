#!/bin/bash


function change_apt_source()
{
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
    # CODE=`lsb_release -c | awk -F':' '{print $2}'`
    CODE=`cat /etc/lsb-release | grep CODENAME | awk -F'=' '{print $2}'`
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


function change_pip_source()
{
    if [ ! -d ~/.pip ]; then
        echo "mkdir ~/.pip"
        mkdir -p ~/.pip
    fi
    if [ ! -f ~/.pip/pip.conf ]; then
        echo "create file ~/.pip/pip.conf..."
        echo "[global]" > ~/.pip/pip.conf
        echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf
    else
        echo "~/.pip/pip.conf exists, maybe you have change it"
    fi
}


change_apt_source
change_pip_source
