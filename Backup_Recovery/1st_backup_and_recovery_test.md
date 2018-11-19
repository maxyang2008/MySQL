# preparation
## install xtrabackup from Percona
```sh
wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.12/binary/tarball/percona-xtrabackup-2.4.12-Linux-x86_64.libgcrypt145.tar.gz

cd /usr/local/
tar -zxvf percona-xtrabackup-2.4.12-Linux-x86_64.libgcrypt145.tar.gz
mv percona-xtrabackup-2.4.12-Linux-x86_64 percona-xtrabackup

vi ~/.bash_profile
add
export PATH=/usr/local/percona-xtrabackup/bin:$PATH
```

## install depedency module
```sh
yum install perl-Digest-MD5
yum install perl-DBD-MySQL
```

## edit my.cnf
edit my.cnf file, add following options, in order xtrabackup can read mysql port and socket file localtion
```
[client]
port = 3306
socket = /tmp/mysql.sock
```

# Full level backup and recovery
## run full back
```sh
bash /mysql_backup/scripts/full_back.sh
```
and check the logfile to ensure backup run successfully

## full backup restore
### uncompress backup tar.gz file
```sh
mkdir -p /mysql_backup/full_backup/restore/full # create a stage directory
cd /mysql_backup/full_backup/restore/full
tar -zxvf /mysql_backup/full_backup/20181119_174256.tar.gz # extract compressed backup file
```

### prepare backupset 
apply log to stage directory
```sh
innobackupex --apply-log /mysql_backup/full_backup/restore/full
```

### restore backup
```sh
innobackupex --defaults-file=/etc/my.cnf --copy-back --rsync /mysql_backup/full_backup/restore/full
chown -R mysql.mysql /data/mydb
```

### startup database
启动数据库
/etc/init.d/mysqld start

设置数据库为只读状态
```sql
FLUSH TABLES WITH READ LOCK;
SET GLOBAL read_only = 1;
```

# inc backup and recovery
## run full backup and inc backup
```sh
bash /mysql_backup/scripts/inc_back.sh	# full backup
# do transaction 1
bash /mysql_backup/scripts/inc_back.sh	# 1st time inc backup
# do transaction 2
bash /mysql_backup/scripts/inc_back.sh  # 2nd time inc backup
# do transaction 3
```
and check the logfile to ensure backup run successfully

# inc backup restore
## full backup restore
```sh
mkdir -p /mysql_backup/full_backup/restore/full
cd /mysql_backup/full_backup/restore/full
tar -zxvf /mysql_backup/full_backup/20181119_190949.tar.gz
# caution! this step use --redo-only option to prevent from doing automatic rollback
innobackupex --apply-log --redo-only /mysql_backup/full_backup/restore/full
```

## 1st inc backup restore
```sh
mkdir -p /mysql_backup/incr_backup/restore/inc/1
cd /mysql_backup/incr_backup/restore/inc/1
## caution! inc backup use STREAM_TYPE="xbstream" option
gunzip -c /mysql_backup/incr_backup/20181119_191045.tar.gz | xbstream -x -
# caution! this step use --redo-only option to prevent from doing automatic rollback
innobackupex --apply-log --redo-only /mysql_backup/full_backup/restore/full --incremental-dir=/mysql_backup/incr_backup/restore/inc/1
```

## 2nd inc backup restore
```sh
mkdir -p /mysql_backup/incr_backup/restore/inc/2
cd /mysql_backup/incr_backup/restore/inc/2
gunzip -c /mysql_backup/incr_backup/20181119_191115.tar.gz | xbstream -x -
# caution! this step(last inc backup) do not use --redo-only option to do the final restore
innobackupex --apply-log /mysql_backup/full_backup/restore/full --incremental-dir=/mysql_backup/incr_backup/restore/inc/2 
```

## copy back 
```sh
innobackupex --defaults-file=/etc/my.cnf --copy-back --rsync /mysql_backup/full_backup/restore/full
chown -R mysql.mysql /data/mydb
```

## startup database
/启动数据库
/etc/init.d/mysqld start

设置数据库为只读状态
```sql
FLUSH TABLES WITH READ LOCK;
SET GLOBAL read_only = 1;
```

#### reference
for recovery:
https://www.cnblogs.com/waynechou/p/xtrabackup_backup.html#_label1