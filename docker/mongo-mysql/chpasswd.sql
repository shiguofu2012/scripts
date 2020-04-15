
use mysql;
update user set plugin="mysql_native_password" where User='root';
update user set Host='%' where User='root';
set password for 'root'@'%'='P@55word';
flush privileges;
