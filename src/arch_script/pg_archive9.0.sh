#!/bin/bash
. ~/arch_script/pg_archive9.0.conf

insert_arch_remote_log()
{
psql -E -q -A -t -h $CONTROL_DB_IP -p $CONTROL_DB_PORT -U $CONTROL_DB_USER -d $CONTROL_DB_NAME -c "insert into $CONTROL_DB_SCHEMA.arch_remote_log (db_id,ssh_ip,ssh_port,ssh_user,full_path,create_time,status,wal_size_mb) values ('$LOC_UUID','$RMT_IP','$RMT_PORT','$RMT_USER','$RMT_ROOT_PATH$RMT_RELATIVE_PATH$XLOG_NAME',now(),'$STATUS',$WAL_BYTES);"
}

insert_arch_local_log()
{
psql -E -q -A -t -h $CONTROL_DB_IP -p $CONTROL_DB_PORT -U $CONTROL_DB_USER -d $CONTROL_DB_NAME -c "insert into $CONTROL_DB_SCHEMA.arch_local_log (db_id,full_path,create_time,status,wal_size_mb) values ('$LOC_UUID','$LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME',now(),'$STATUS',$WAL_BYTES);"
}

control_db_srv_check()
{
psql -E -q -A -t -h $CONTROL_DB_IP -p $CONTROL_DB_PORT -U $CONTROL_DB_USER -d $CONTROL_DB_NAME -c "select now()||' control_db_srv_check.';"
if [ $? -ne 0 ]; then
MESSAGE="control_db_srv_check , failed_can_continue_at_this_point . Database : -h $CONTROL_DB_IP -p $CONTROL_DB_PORT -U $CONTROL_DB_USER -d $CONTROL_DB_NAME ."
echo -e $MESSAGE
RESULT=11
NAGIOS_RETURN=2
write_nagios_file
exit $RESULT
fi
}

archive_switch_check()
{
SWITCH=`psql -E -q -A -t -h $CONTROL_DB_IP -p $CONTROL_DB_PORT -U $CONTROL_DB_USER -d $CONTROL_DB_NAME -c "select switch from $CONTROL_DB_SCHEMA.arch_db_info where id='$LOC_UUID';"`
if [ $SWITCH == "start" ]; then
echo -e "archive_switch_status: $SWITCH"
elif [ $SWITCH == "stop" ]; then
echo -e "archive_switch_status: $SWITCH"
RESULT=0
NAGIOS_RETURN=2
MESSAGE="status=3,handwork_stop_can_not_continue_at_this_point.remote and local"
write_nagios_file
exit $RESULT
elif [ $SWITCH == "pause" ]; then
echo -e "archive_switch_status: $SWITCH"
RESULT=12
NAGIOS_RETURN=2
MESSAGE="status=2,handwork_pause_can_continue_at_this_point.remote and local"
write_nagios_file
exit $RESULT
else
echo -e "archive_switch_status: $SWITCH"
RESULT=13
NAGIOS_RETURN=2
MESSAGE="status=4,switch_check_unknown_can_continue_at_this_point.remote and local"
write_nagios_file
exit $RESULT
fi
}

write_nagios_file()
{
if [ $NAGIOS == on ]; then
echo -e "$NAGIOS_RETURN\n$MESSAGE\n`date +%F%T`" >$NAGIOS_RESULT_FILE 2>&1
else
echo -e "NAGIOS is not on."
fi
}

SWITCH="unknown"
RESULT=1
NAGIOS_RETURN=3
MESSAGE="status=2,failed_can_continue_at_this_point.remote and local"
DATE=`date +%Y%m%d`
control_db_srv_check
LOC_UUID=`psql -E -q -A -t -h $LOC_DB_IP -p $LOC_DB_PORT -U $LOC_DB_USER -d $LOC_DB_NAME -c "select uuid from $LOC_DB_SCHEMA.fingerprint where id=1;"|grep -v "^$"`
WAL_BYTES=`psql -E -q -A -t -h $LOC_DB_IP -p $LOC_DB_PORT -U $LOC_DB_USER -d $LOC_DB_NAME -c "select wal_size_mb from $LOC_DB_SCHEMA.fingerprint where id=1;"|grep -v "^$"`
LOC_RELATIVE_PATH=$LOC_UUID/$DATE/
RMT_RELATIVE_PATH=$LOC_UUID/$DATE/
RMT_ARCH_STAT1=1
RMT_ARCH_STAT2=1
RMT_ARCH_STAT3=1
archive_switch_check

for path_info in `psql -E -q -A -t -h $CONTROL_DB_IP -p $CONTROL_DB_PORT -U $CONTROL_DB_USER -d $CONTROL_DB_NAME -c "select t2.ssh_ip,t2.ssh_port,t2.ssh_user,t2.root_path from $CONTROL_DB_SCHEMA.arch_db_info t1,$CONTROL_DB_SCHEMA.arch_path_info t2,$CONTROL_DB_SCHEMA.arch_path_map t3 where t1.id=t3.db_id and t2.id=t3.path_id and t1.id='$LOC_UUID' and t2.active_status='true' and t3.active_status='true' order by priority desc;"|grep -v "^$"`
do
RMT_IP=`echo -e $path_info|awk -F "|" '{print $1}'`
RMT_PORT=`echo -e $path_info|awk -F "|" '{print $2}'`
RMT_USER=`echo -e $path_info|awk -F "|" '{print $3}'`
RMT_ROOT_PATH=`echo -e $path_info|awk -F "|" '{print $4}'`

ssh -p $RMT_PORT $RMT_USER@$RMT_IP ". ~/.bash_profile;test -d $RMT_ROOT_PATH"
RMT_ARCH_STAT1=$?
if [ $RMT_ARCH_STAT1 -ne 0 ]; then
MESSAGE="failed_can_continue_at_this_point. Directory:$RMT_ROOT_PATH not exists in Host:$RMT_USER@$RMT_IP , please Check it!"
echo -e $MESSAGE
STATUS="false"
insert_arch_remote_log
RESULT=2
NAGIOS_RETURN=2
continue
fi
ssh -p $RMT_PORT $RMT_USER@$RMT_IP ". ~/.bash_profile;test -d $RMT_ROOT_PATH$RMT_RELATIVE_PATH || mkdir -p $RMT_ROOT_PATH$RMT_RELATIVE_PATH"
RMT_ARCH_STAT2=$?
if [ $RMT_ARCH_STAT2 -ne 0 ]; then
MESSAGE="failed_can_continue_at_this_point. Directory:$RMT_RELATIVE_PATH can't created in $RMT_USER@$RMT_IP:$RMT_ROOT_PATH , please Check it!"
echo -e $MESSAGE
STATUS="false"
insert_arch_remote_log
RESULT=3
NAGIOS_RETURN=2
continue
fi
scp -C -P $RMT_PORT $LOC_PGDATA$XLOG_FULL_PATH $RMT_USER@$RMT_IP:$RMT_ROOT_PATH$RMT_RELATIVE_PATH$XLOG_NAME
RMT_ARCH_STAT3=$?
if [ $RMT_ARCH_STAT3 -ne 0 ]; then
MESSAGE="failed_can_continue_at_this_point. Command error: scp -C -P $RMT_PORT $LOC_PGDATA$XLOG_FULL_PATH $RMT_USER@$RMT_IP:$RMT_ROOT_PATH$RMT_RELATIVE_PATH$XLOG_NAME, please Check it!"
echo -e $MESSAGE
STATUS="false"
insert_arch_remote_log
RESULT=4
NAGIOS_RETURN=2
continue
fi
STATUS="true"
RMT_ARCH_STAT1=0
RMT_ARCH_STAT2=0
RMT_ARCH_STAT3=0
RESULT=0
NAGIOS_RETURN=0
MESSAGE="status=0,success.remote"
insert_arch_remote_log
break
done

if [ $RMT_ARCH_STAT1 -ne 0 ] || [ $RMT_ARCH_STAT2 -ne 0 ] || [ $RMT_ARCH_STAT3 -ne 0 ]; then
  if [ -d $LOC_ARCH_DIR ]; then
    if [ -d $LOC_ARCH_DIR$LOC_RELATIVE_PATH ]; then
    cp $LOC_PGDATA$XLOG_FULL_PATH $LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME
      if [ $? -ne 0 ]; then
      MESSAGE="failed_can_continue_at_this_point. Command error: cp $LOC_PGDATA$XLOG_FULL_PATH $LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME, please Check it!"
      echo -e $MESSAGE
      STATUS="false"
      RESULT=6
      NAGIOS_RETURN=2
      insert_arch_local_log
      else
      STATUS="true"
      RESULT=0
      NAGIOS_RETURN=1
      MESSAGE="status=1,success.local"
      insert_arch_local_log
      fi
    else
    mkdir -p $LOC_ARCH_DIR$LOC_RELATIVE_PATH
    cp $LOC_PGDATA$XLOG_FULL_PATH $LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME
      if [ $? -ne 0 ]; then
      MESSAGE="failed_can_continue_at_this_point. Command error: cp $LOC_PGDATA$XLOG_FULL_PATH $LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME, please Check it!"
      echo -e $MESSAGE
      STATUS="false"
      RESULT=7
      NAGIOS_RETURN=2
      insert_arch_local_log
      else  
      STATUS="true"
      RESULT=0
      NAGIOS_RETURN=1
      MESSAGE="status=1,success.local"
      insert_arch_local_log
      fi
    fi
  else
  mkdir -p $LOC_ARCH_DIR$LOC_RELATIVE_PATH
  cp $LOC_PGDATA$XLOG_FULL_PATH $LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME
    if [ $? -ne 0 ]; then
    MESSAGE="failed_can_continue_at_this_point. Command error: cp $LOC_PGDATA$XLOG_FULL_PATH $LOC_ARCH_DIR$LOC_RELATIVE_PATH$XLOG_NAME, please Check it!"
    echo -e $MESSAGE
    STATUS="false"
    RESULT=8
    NAGIOS_RETURN=2
    insert_arch_local_log
    else  
    STATUS="true"
    RESULT=0
    NAGIOS_RETURN=1
    MESSAGE="status=1,success.local"
    insert_arch_local_log
    fi
  fi
fi

write_nagios_file
return $RESULT

# -- 变量解释
# LOC_RELATIVE_PATH 本地归档相对目录
# RMT_RELATIVE_PATH 远程归档相对目录
# RMT_ARCH_STAT1 远程归档操作状态1
# RMT_ARCH_STAT2 远程归档操作状态2
# RMT_ARCH_STAT3 远程归档操作状态3
# RMT_IP 远程归档服务器IP
# RMT_PORT 远程归档服务器PORT
# RMT_USER 远程归档服务器USER
# RMT_ROOT_PATH 远程归档服务器根目录
# NAGIOS 返回值定义 0ok 1warning 2critical 3unknown
# MESSAGE nagios需要的消息分为4类消息
# NAGIOS返回值 0 status=0,success.remote
# NAGIOS返回值 1 status=1,success.local
# NAGIOS返回值 1 status=2,handwork_pause_can_continue_at_this_point.remote and local
# NAGIOS返回值 2 status=2,failed_can_continue_at_this_point.remote and local
# NAGIOS返回值 2 status=3,handwork_stop_can_not_continue_at_this_point.remote and local
# NAGIOS返回值 2 status=4,switch_check_unknown_can_continue_at_this_point.remote and local
# NAGIOS返回值 2 错误消息

#Author : Digoal zhou
#Email : digoal@126.com
#Blog : http://blog.163.com/digoal@126/