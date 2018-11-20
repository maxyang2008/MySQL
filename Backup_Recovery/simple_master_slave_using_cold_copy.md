## Server Config
### master my.cnf
```
[client]
port = 3306
socket = /data/mydb3306/mysql.sock

[mysqld]
basedir = /usr/local/mysql
datadir = /data/mydb3306
server_id = 1
port = 3306
collation-server=latin1_german1_ci
socket = /data/mydb3306/mysql.sock

log_error = /data/mydb3306/3306.err
log_bin = mysqlbin
binlog_format = row

# master - slave related
gtid-mode = ON
enforce-gtid-consistency = ON
binlog-checksum = CRC32
master-verify-checksum = 1
[root@mysql-dev ~]# cat /etc/my3307.cnf 
[client]
port = 3307
socket = /data/mydb3307/mysql.sock
```

### slave my.cnf
```
[mysqld]
basedir = /usr/local/mysql
datadir = /data/mydb3307
server_id = 2
port = 3307
collation-server=latin1_german1_ci
socket = /data/mydb3307/mysql.sock

log_error = /data/mydb3307/3307.err
log_bin = mysqlbin

# master - slave related
gtid-mode = ON
enforce-gtid-consistency = ON
binlog-checksum = CRC32
slave-sql-verify-checksum = 1
skip-slave-start = true

relay-log = /data/mydb3307/relay-log
relay-log-index = /data/mydb3307/relay-log-index
relay-log-info-file = /data/mydb3307/relay-log.info
master-info-repository = table
relay-log-info-repository = table
relay-log-recovery = ON
```

## useful command
```sh
# create replication user
grant replication slave on *.* to 'repl'@'%' identified by 'oracle';

# show replication related variable
show variables like "%gtid%";
show variables like '%gtid_next%';
show global variables like '%uuid%';

# set master database connection info
CHANGE MASTER TO MASTER_HOST='mysql-dev',MASTER_PORT=3306,MASTER_USER='repl',MASTER_PASSWORD='oracle',MASTER_AUTO_POSITION=1;

# start replication
START SLAVE;

# see slave run status, this should run on slave node
SHOW SLAVE STATUS\G

# get a uuid for slave server
select uuid()
```