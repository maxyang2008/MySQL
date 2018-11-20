## full backup:
* most simple one
```
#!/bin/bash

date > bak.log
innobackupex \
  --defaults-file=/etc/my.cnf \
  --user=root \
  --password='password' \
  --no-timestamp  \
  /FCPNFS/mysql_backup/prddb02/full_back/tmp \
  2>> bak.log
date >> bak.log
```

* if you need a compressed one, use tar stream
```
#!/bin/bash
date > bak.log

nohup innobackupex \
  --defaults-file=/etc/my.cnf \
  --stream=xbstream \
  --user=root \
  --password='password' \
  --no-timestamp \
  /data/backup/data/full_back/20181120 \
  2>> bak.log \
  | gzip > /data/backup/data/full_back/20181120/full.tar.gz

date > bak.log
```

* if you need a faster one, use xbstream stream
```
#!/bin/bash
date > bak.log

nohup innobackupex \
  --defaults-file=/etc/my.cnf \
  --stream=xbstream \
  --user=root \
  --password='password' \
  --no-timestamp \
  /data/backup/data/full_back/20181120 \
  2>> bak.log \
  | gzip > /data/backup/data/full_back/20181120/full.tar.gz

date > bak.log
```

## full backup restore:
* step1
```
innobackupex \
  --defaults-file=/etc/my.cnf \
  --apply-log \
  /FCPNFS/mysql_backup/prddb02/full_back/tmp
```

* step2
```
innobackupex \
  --defaults-file=/etc/my.cnf  \
  --copy-back \
  /FCPNFS/mysql_backup/prddb02/full_back/tmp
```

* note
If you are using --stream options when making a backup, you should first manually extract gzipped file to tmp directory using using the following command:
(choose xbstream or tar command based on which stream type you used when doing backup)
```
gunzip -c /mysql_backup/incr_backup/20181119_191045.tar.gz \
  | xbstream -x -  # xbstream command is contained in xtrabackup install directory

gunzip -c /mysql_backup/incr_backup/20181119_191045.tar.gz \
  | tar -xv -
```