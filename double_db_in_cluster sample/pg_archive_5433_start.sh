#!/bin/bash
export XLOG_FULL_PATH=$1
export XLOG_NAME=$2

. ~/arch_script/pg_archive_5433.sh >>~/arch_script/log/pg_archive_5433.log 2>&1
return $?

# postgresql.conf配置
# archive_command = '. ~/arch_script/pg_archive_5433_start.sh %p %f'

#Author : Digoal zhou
#Email : digoal@126.com
#Blog : http://blog.163.com/digoal@126/