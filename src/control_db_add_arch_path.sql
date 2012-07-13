-- psql -h 127.0.0.1 arch arch
insert into arch_db_info (id,idc,platform,software,version,vip,port,create_time,active_status,switch,alias) values ('09e9f16f-ad78-4c89-bedd-37aab5477d68','HangZhouSanDun','x86_64','PostgreSQL','9.0.4','192.168.1.100',5432,now(),'true','start','DIGOAL_TESTDB');

insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (1,'192.168.1.61',22,'arch','/sto1_dg1_part1/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (2,'192.168.1.61',22,'arch','/sto1_dg2_part1/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (3,'192.168.1.61',22,'arch','/sto1_dg2_part2/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (4,'192.168.1.61',22,'arch','/sto1_dg2_part3/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (5,'192.168.1.61',22,'arch','/sto1_dg2_part4/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (6,'192.168.1.61',22,'arch','/sto1_dg3_part1/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (7,'192.168.1.61',22,'arch','/sto1_dg3_part2/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (8,'192.168.1.61',22,'arch','/sto1_dg3_part3/archive/',now(),'true');
insert into arch_path_info (id,ssh_ip,ssh_port,ssh_user,root_path,create_time,active_status) values (9,'192.168.1.61',22,'arch','/sto1_dg3_part4/archive/',now(),'true');

insert into arch_path_map (id,db_id,path_id,priority,active_status,create_time) values (1,'09e9f16f-ad78-4c89-bedd-37aab5477d68',2,2,'true',now());
insert into arch_path_map (id,db_id,path_id,priority,active_status,create_time) values (2,'09e9f16f-ad78-4c89-bedd-37aab5477d68',5,1,'true',now());

-- # Author : Digoal zhou
-- # Email : digoal@126.com
-- # Blog : http://blog.163.com/digoal@126/