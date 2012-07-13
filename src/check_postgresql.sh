#!/bin/bash

if [ $# -ne 2 ]; then
echo -e "Usage : $prog \$1 \$2 "
exit 2
fi

DB_PORT=$2

# 监控数据库是否开启, 未开启表示集群已切换, 返回值0
nohup echo -e "q"|telnet -e "q" 127.0.0.1 $DB_PORT >/dev/null 2>&1
if [ $? -ne 0 ]; then
echo -e "`date +%F%T`\nPostgreSQL -p $DB_PORT not run in this node"
exit 0
fi

# 检查归档输出日志
check_archive()
{
test -f /tmp/pgarchive.nagios_$DB_PORT
if [ $? -ne 0 ]; then
RESULT=2
MESSAGE="`date +%F%T`\n/tmp/pgarchive.nagios_$DB_PORT not exist."
echo -e $MESSAGE
return $RESULT
fi

find /tmp/pgarchive.nagios_$DB_PORT -mmin -45|grep "pgarchive.nagios_$DB_PORT"
if [ $? -ne 0 ]; then
RESULT=2
MESSAGE="`date +%F%T`\nPostgreSQL -p $DB_PORT archive timeout."
echo -e $MESSAGE
return $RESULT
fi

RESULT=`head -n 1 /tmp/pgarchive.nagios_$DB_PORT`
cat /tmp/pgarchive.nagios_$DB_PORT
return $RESULT
}

# See how we were called.
case "$1" in
  check_archive)
        check_archive
        ;;
  *)
        echo $"Usage: $prog {check_archive} port"
        exit 1
esac

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