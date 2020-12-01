#!/bin/sh


LOGSTASH_URL="https://artifacts.elastic.co/downloads/logstash/logstash-7.9.3.zip"
ES_URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.9.3-linux-x86_64.tar.gz"
KIBANA_URL="https://artifacts.elastic.co/downloads/kibana/kibana-7.9.3-linux-x86_64.tar.gz"
FILEBEAT_URL="https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.0-linux-x86_64.tar.gz"
DEST_DIR="/usr/local/elk"
LOGSTASH_LINK_DIR="$DEST_DIR/logstash"


function install()
{
    echo "download url: $1"
    if [ -z "$1" ]; then
        echo "url must be specific"
        return
    fi
    filename=`echo $1 | awk -F"/" '{print $NF}'`
    if [ -z "$filename" ]; then
        echo "illegal url: $1"
        return
    fi
    if [ ! -f "$filename" ]; then
        echo "download $filename ..."
        `wget $1 -v`
    else
        echo "$filename already download."
    fi
    do_install $filename
}

# download package and unzip/tar package to DEST_DIR
function do_install()
{
    if [ -z "$1" ]; then
        echo "Not install package found"
        return
    fi
    # install dir name
    install_dir_name=`echo $1 | awk -F"-" '{print $1"-"$2}'`
    if [[ "$1" =~ "logstash" ]]; then
        install_dir_name=`echo $1 | awk -F".zip" '{print $1}'`
    elif [[ "$1" =~ "kibana" || "$1" =~ "filebeat" ]]; then
        install_dir_name=`echo $1 | awk -F".tar.gz" '{print $1}'`
    fi

    cmd=`echo $install_dir_name | awk -F'-' '{print $1}'`
    `which $cmd>/dev/null 2>/dev/null`
    if [ $? -eq 0 ]; then
        echo "$cmd already install..."
        return
    fi
    echo "start install $1..."
    INS_DIR="$DEST_DIR/$install_dir_name"
    if [ -d "$INS_DIR" ]; then
        echo "$INS_DIR already exists,maybe you have install it already."
    else
        echo "unzip ..."
        mkdir -p $INS_DIR
        if [[ "$1" =~ "zip" ]]; then
            unzip $1 -d $DEST_DIR > /dev/null
        else
            tar -xf $1 -C $DEST_DIR > /dev/null
        fi
    fi
    link_path=/usr/local/$cmd
    `cat ~/.bashrc | grep "$link_path"`	
    if [ $? != 0 ]; then
        echo "link logstash and set path.."
        ln -sfn $INS_DIR $link_path
        if [[ "$1" =~ "filebeat" ]]; then
            echo "export PATH="$PATH":$link_path" >> ~/.bashrc
        else
            echo "export PATH="$PATH":$link_path/bin" >> ~/.bashrc
        fi
        echo "run `source ~/.bashrc` and config file{$DEST_DIR/config}"
    fi
}


function start_install()
{
    apps=($LOGSTASH_URL $ES_URL $KIBANA_URL $FILEBEAT_URL)
    for app in ${apps[@]}; do
        install $app
    done
}

start_install
# install $FILEBEAT_URL
