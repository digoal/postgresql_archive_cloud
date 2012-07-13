create role arch nosuperuser login encrypted password '密码略';
create tablespace tbs_arch owner arch location '地址略';
create database arch with owner arch template template0 encoding='UTF8' tablespace tbs_arch;
\c arch arch
create schema arch authorization arch;
create table arch_db_info (id uuid,idc text,platform text,software text,version text,vip inet,port int,switch text,create_time timestamp without time zone,modify_time timestamp without time zone,active_status boolean,alias text not null,primary key (id));
create unique index uk_db_info_1 on arch_db_info (idc,vip,port);
create unique index uk_db_info_2 on arch_db_info (alias);

create table arch_path_info (id int,ssh_ip inet,ssh_port int,ssh_user text,root_path text,create_time timestamp without time zone,modify_time timestamp without time zone,active_status boolean,size_mb bigint,primary key (id));
create unique index uk_path_info_1 on arch_path_info (ssh_ip,ssh_port,root_path);

create table arch_path_map (id int,db_id uuid,path_id int,priority int,active_status boolean,create_time timestamp without time zone,modify_time timestamp without time zone,primary key (id));
create unique index uk_path_map_1 on arch_path_map (db_id,path_id);
alter table arch_path_map add constraint fk_path_1 foreign key (db_id) references arch_db_info(id);
alter table arch_path_map add constraint fk_path_2 foreign key (path_id) references arch_path_info(id);

create table arch_remote_log (db_id uuid,ssh_ip inet,ssh_port int,ssh_user text,full_path text,wal_size_mb bigint,create_time timestamp without time zone,status boolean,delete boolean);

create table arch_local_log (db_id uuid,full_path text,wal_size_mb bigint,create_time timestamp without time zone,status boolean,delete boolean);

-- # Author : Digoal zhou
-- # Email : digoal@126.com
-- # Blog : http://blog.163.com/digoal@126/