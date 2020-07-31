#!/bin/bash

# 系统依赖包列表
LIBDEPS=( "perl" "readline-devel" "pcre-devel" "openssl-devel" "gcc" "perl" \
    "libuuid-devel" "wget" "git" "mariadb" "mariadb-server" "lua-devel" "unzip")
# resty-http/luasocket for dashboard
LUADEPS=( "luafilesystem" "lua-resty-timer" "binaryheap" "lrandom" "penlight" \
    "lua-resty-dns-client" "lua-resty-jwt" "luacrypto" "lua-resty-hmac" "lua-resty-http" \
    "luasocket" )
# 依赖包安装目录
INSTALL_DIR=/usr/local
# mysql password root
MYSQL_PASSWORD=P@55word
TMP=/tmp/orange-tmp


if [ ! -d "$TMP" ]; then
    mkdir -p $TMP
fi


function output()
{
    echo "[INFO] `date +\"%Y-%m-%d %H:%M:%S\"` " $1
}


function mysql_isrunning()
{
    sqlp=`ps aux | grep -v grep | grep 'mysqld'`
    if [ -z "$sqlp" ]; then
        output "Mysql is not running"
        return 1
    else
        output "Mysql is running"
        return 0
    fi
}


function install_deps()
{
    for package in ${LIBDEPS[@]}
    do
        output "start install $package..."
        yum install $package -y > /dev/null 2 > /dev/null
        if [ $? != 0 ]; then
	    output "$package intall failed please install it later"
            return 1
	fi
        output "$package install Done."
    done
    # start mysql if mysql is not running
    mysql_isrunning
    if [ $? != 0 ]; then
        service mariadb start
    fi
}


function config_mysql()
{
    mysql_isrunning
    if [ $? != 0 ]; then
        output "Mysql is not running, now start..."
        service mariadb start
        if [ $? != 0 ]; then
            output "Mysql start failed, Abort."
            return
        fi
    fi 
    # set password, init no password 
    mysql -e "set password for 'root'@'localhost'=password('$MYSQL_PASSWORD');flush privileges;" > /dev/null 2> /dev/null
    if [ $? != 0 ]; then
        output "mysql already config. Please Check the orange database."
        return
    fi
    # check orange database is created or not
    check_ret=`mysql -uroot -p$MYSQL_PASSWORD -e "select * from information_schema.SCHEMATA where SCHEMA_NAME='orange'"`
    if [ -z "$check_ret" ]; then
        # create orange database and create user orange for orange
        output "create database 'orange'..."
        orange_sql_init="CREATE DATABASE IF NOT EXISTS orange CHARACTER SET utf8 COLLATE utf8_general_ci;CREATE USER 'orange'@'%' IDENTIFIED BY 'orange';GRANT ALL PRIVILEGES ON orange.* TO 'orange'@'%'; FLUSH PRIVILEGES;"
        mysql -uroot -p$MYSQL_PASSWORD -e "$orange_sql_init"
        output "create database 'orange' Done."
    else
        output "database orange already created."
    fi
    # import orange sql
    orange_sql=$TMP/orange/install/orange-master.sql
    if [ -f "$orange_sql" ]; then
        output "import sql: $orange_sql..."
        mysql -uroot -p$MYSQL_PASSWORD orange < $orange_sql
        output "import sql $orange_sql Done."
    else
        output $orange_sql, "not found orange sql file."
        output "orange mysql table not import, please do it later."
    fi
    output "Mysql config Done."
}


function install_openresty()
{
    which openresty > /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        output "Openresty alread installed, ignore."
    else
        RESTYPACKAGE=openresty-1.15.8.3.tar.gz
        dir=$INSTALL_DIR/$RESTYPACKAGE
        if [ ! -f "$dir" ]; then
            `cd $INSTALL_DIR && wget https://openresty.org/download/openresty-1.15.8.3.tar.gz`
            output "download openresty Done."
            if [ ! -f "$INSTALL_DIR/$RESTYPACKAGE" ]; then
                output "Download openresty failed"
                return
            fi
        fi
        cd $INSTALL_DIR && tar -xvf openresty-1.15.8.3.tar.gz > /dev/null
        output "Start build openresty..."
        cd $INSTALL_DIR && \
        cd openresty-1.15.8.3 && \
        ./configure  --prefix=/usr/local/openresty \
                     --with-http_stub_status_module \
                     --with-http_v2_module \
                     --with-http_ssl_module \
            	 --with-luajit \
            	 --without-http_redis2_module \
            	 --with-http_iconv_module > /dev/null &&\
        gmake > /dev/null && gmake install > /dev/null && \
        ln -snf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx && \
        ln -snf /usr/local/openresty/bin/openresty /usr/bin/openresty && \
        ln -snf /usr/local/openresty/bin/resty /usr/bin/resty && \
        ln -snf /usr/local/openresty/bin/opm /usr/bin/opm
        output "Openresty install Done."
    fi
}


function install_lor()
{
    LOR_DIR=/usr/local/lor
    if [ -d "$LOR_DIR" ];then
        output "lor already installed ignore."
    else
	output "start install lor..."
        if [ ! -d "$TMP/lor" ]; then
            cd $TMP && \
            git clone https://github.com/sumory/lor.git > /dev/null
        fi
        if [ $? != 0 ]; then
            output "Download lor failed..."
            return
        fi
        cd $TMP/lor && \
        make install > /dev/null
        ln -snf /usr/local/bin/lord /usr/bin/lord
        output "lord install Done."
    fi
}


function install_orange()
{
    # After this, maybe we should change the "lua_package_path" field of the
    # config file "/usr/local/orange/conf/nginx.conf"
    which orange > /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        output "orange already installed"
    else
        ORANGE_TMP=$TMP/orange
        if [ ! -d "$ORANGE_TMP" ]; then
            cd $TMP && \
            git clone https://github.com/sumory/orange.git
        fi
        cd $ORANGE_TMP && make install
        config_mysql
    fi
}


function install_luarocks()
{
    which luarocks > /dev/null 2> /dev/null
    if [ $? == 0 ]; then
        output "luarocks alread installed, ignore."
    else
        output "start install luarocks ..."
        rocks_package=luarocks-3.3.1.tar.gz
        file_path=$INSTALL_DIR/$rocks_package
        if [ !  -f "$file_path" ]; then
            cd $INSTALL_DIR && \
            wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
        fi
        if [ $? != 0 ]; then
            output "Download luarocks failed"
            return
        fi
        cd $INSTALL_DIR && \
        tar -xvf luarocks-3.3.1.tar.gz > /dev/null && \
        cd luarocks-3.3.1 && \
        ./configure > /dev/null && make > /dev/null && sudo make install > /dev/null
        output "install luarocks Done."
    fi
}


function install_luapackage()
{
    which luarocks > /dev/null 2> /dev/null
    if [ $? != 0 ]; then
        output "luarocks command not found, luapackage not install.."
        return
    fi
    for package in ${LUADEPS[@]}
    do
        check_ret=`luarocks list | grep $package`
        if [ -z "$check_ret" ]; then
            output "install lua package: $package..."
            luarocks install $package > /dev/null 2> /dev/null
            if [ $? != 0 ]; then
                output "install lua package failed: $package, please install it later"
            else
                output "install lua package $package Done."
            fi
        fi
    done
}


function do_install()
{
    install_deps
    # some package install failed, abort
    if [ $? != 0 ]; then
        return
    fi
    install_luarocks
    install_luapackage
    install_openresty
    install_lor
    install_orange
}


do_install
