## Create a DML only user
CREATE USER 'ecpapps'@'%' IDENTIFIED BY 'Password';
grant select, update, delete, insert on *.* to ecpapps@'%';
flush privileges;


## Create a read only user
CREATE USER 'ecpread'@'%' IDENTIFIED BY 'Password';
grant SELECT on *.* to ecpapps@'%';
flush privileges;
