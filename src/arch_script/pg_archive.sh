#!/bin/bash
export XLOG_FULL_PATH=$1
export XLOG_NAME=$2

. ~/arch_script/pg_archive9.0.sh >>~/arch_script/log/pg_archive9.0.log 2>&1
return $?

# postgresql.conf配置
# archive_command = '. ~/arch_script/pg_archive.sh %p %f'


#Author : Digoal zhou
#Email : digoal@126.com
#Blog : http://blog.163.com/digoal@126/
