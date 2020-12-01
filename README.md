# scripts
一些环境初始化的脚本


1. ubuntu-init.sh
更改ubuntu的系统源并安装一些基本的系统包python/pyhon-pip，并更新pip的源为阿里云的
```shell
sh ubuntu-init.sh

```

2. install_orange.sh

安装orange网关的脚本，执行

```shell
sh install_orange.sh
```

3. install_elk.sh

安装filebeat/logstash/es/kibana（配置文件需要自己配置）

```shell
sh install_elk.sh
```

默认安装在/usr/local/elk目录下， 可以修改脚本变量DEST_DIR来改变

