create role fingerprint nosuperuser nocreatedb nocreaterole noinherit login encrypted password 'fingerprint密码略';
create database fingerprint with owner fingerprint template template0 encoding 'UTF8' ;
\c fingerprint fingerprint
create schema fingerprint authorization fingerprint;
create table fingerprint (id int ,uuid text not null,wal_size_mb bigint not null,create_time timestamp without time zone,primary key (id));

-- # Author : Digoal zhou
-- # Email : digoal@126.com
-- # Blog : http://blog.163.com/digoal@126/