# MySQL 5.7 locking test

## windows #1
start transaction;
select * from t1 for update;


## windows #2
start transaction;
select * from t1 for update; # will see the second session hangs. there will be a timeout according to innodb_lock_wait_timeout setting.