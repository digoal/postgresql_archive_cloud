#!/bin/bash
# PATH中必须包含mutt, psql等用到的命令.
. ~/.bash_profile

# 多个邮件用空格隔开
EMAIL="digoal@126.com"

echo -e `date +%F\ %T` >/tmp/report_archive.log
echo -e /tmp/report_archive.log >>/tmp/report_archive_history.log

echo -e "1. Summary Report:\n" >>/tmp/report_archive.log
psql -h 127.0.0.1 arch arch -c "select t3.storage_nodes_cnt,t4.db_nodes_cnt,round(t1.total_size_gb,0) total_size_gb,round(t2.used_size_gb) used_size_gb,trunc((t2.used_size_gb/t1.total_size_gb)*100,2)||'%' USED_RATIO from 
(select sum(size_mb)/1024 total_size_gb from arch_path_info) t1,
(select sum(wal_size_mb)/1024 used_size_gb from arch_remote_log) t2,
(select count(*) storage_nodes_cnt from arch_path_info) t3,
(select count(*) db_nodes_cnt from arch_db_info) t4
;" >>/tmp/report_archive.log

echo -e "2. Weekly Report:\n" >>/tmp/report_archive.log
psql -h 127.0.0.1 arch arch -c "select date(create_time),round(sum(wal_size_mb)/1024) size_gb from arch_remote_log where create_time >= current_date-7 and create_time<current_date group by date(create_time) order by date(create_time);" >>/tmp/report_archive.log

echo -e "3. Abnormal Report:\n" >>/tmp/report_archive.log
psql -h 127.0.0.1 arch arch -c "select db_id,ssh_ip,ssh_port,ssh_user,wal_size_mb,create_time,full_path from arch_remote_log where create_time>=current_date-1 and status is false order by create_time;" >>/tmp/report_archive.log

echo -e "4. Local Report:\n" >>/tmp/report_archive.log
psql -h 127.0.0.1 arch arch -c "select db_id,wal_size_mb,create_time,status,full_path from arch_local_log;" >>/tmp/report_archive.log

cat /tmp/report_archive.log|mutt -s "`date +$F` SanDun Storage Cloud Report" $EMAIL


#Author : Digoal zhou
#Email : digoal@126.com
#Blog : http://blog.163.com/digoal@126/