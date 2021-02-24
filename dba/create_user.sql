## Create a DML only user
CREATE USER 'dmluser'@'%' IDENTIFIED BY 'Password';
grant select, update, delete, insert on *.* to ecpapps@'%';
flush privileges;


## Create a read only user
CREATE USER 'readuser'@'%' IDENTIFIED BY 'Password';
grant SELECT on *.* to ecpapps@'%';
flush privileges;
