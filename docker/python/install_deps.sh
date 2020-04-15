#!/bin/bash

# 安装自己封装的微信库
function install_wechatutil()
{
  echo "git clone https://github.com/shiguofu2012/wechat.git..."
  `cd /opt && git clone "https://github.com/shiguofu2012/wechat.git"`
  echo "install wechat..."
  cd /opt/wechat && python setup.py install
}


# 商品搜索用到lucene
function install_jdk()
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

# 淘宝客sdk
function install_tbk_sdk()
{
    cd /opt
    wget http://shiguofu.cn/static/taobao-sdk-PYTHON-auto_1538200427090-20181025.zip
    unzip taobao-sdk-PYTHON-auto_1538200427090-20181025.zip
}


install_wechatutil
