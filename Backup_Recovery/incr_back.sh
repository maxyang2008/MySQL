#!/bin/sh

# MySQL端口
PORT='3306'

# 备份用户
USER='backuser'
PAWD='backuser'
MYSQL_CONFIG_FILE="/etc/my.cnf"
STREAM_TYPE="xbstream"
# 备份路径
BASEDIR="/mysql_backup/incr_backup"
LSNDIR="/mysql_backup/lsndir"
BACKUP_COMMAND="innobackupex"

function getTiming() {
    start=$1
    end=$2
    start_s=$(echo $start | cut -d '.' -f 1)
    start_ns=$(echo $start | cut -d '.' -f 2)
    end_s=$(echo $end | cut -d '.' -f 1)
    end_ns=$(echo $end | cut -d '.' -f 2)
    time=$(( ( 10#$end_s - 10#$start_s ) * 1000 + ( 10#$end_ns / 1000000 - 10#$start_ns / 1000000 ) ))
    echo "$time ms"
}

# 备份过程->LOG文件
TIME=`date +%Y%m%d_%H%M%S`
LOG_DIR="${BASEDIR}/incr_log"
LOGFILE="${LOG_DIR}/${TIME}info.log"
STARTTIME=`date +%Y%m%d_%H%M%S`
# 判断lsn目录是否存在
if [[ ! -d "${LSNDIR}" ]]; then
    mkdir -p ${LSNDIR}
fi

# 判断存放日志的目录是否存在
if [[ ! -d ${LOG_DIR} ]]; then
    mkdir -p ${LOG_DIR}
fi

# 开始备份
IS_MYSQL_START=`netstat -anultp |grep ${PORT} |grep -v grep | grep LISTEN | wc -l`
if [[ ${IS_MYSQL_START} -ne 1 ]]; then
    echo "${STARTTIME}: [ERROR]: the mysql(port:${PORT}) server is stop, please start it." | tee -a ${LOGFILE}
    exit 1
fi

# 判断备份命令是否安装，如果没有提醒用户安装
which ${BACKUP_COMMAND}
if [[ $? -ne 0 ]]; then
   echo "${STARTTIME}: [ERROR]: can not find the back command: ${BACKUP_COMMAND}, please install it first. " | tee -a ${LOGFILE}
   exit 1
fi

echo "********************start time:${STARTTIME}*********************" | tee -a ${LOGFILE}

TIME_START=$(date +%s.%N)
# 备份命令
${BACKUP_COMMAND} --defaults-file=${MYSQL_CONFIG_FILE}  \
             --user=${USER}                             \
             --password=${PAWD}                         \
             --no-timestamp                             \
             --incremental                              \
             --incremental-basedir=${LSNDIR}            \
             --extra-lsndir=${LSNDIR}                   \
             --stream=${STREAM_TYPE}                    \
             ${BASEDIR} 2>> ${LOGFILE}|gzip > ${BASEDIR}/${TIME}.tar.gz

# judge success
if [[ $? -ne 0 ]];then
   echo "${STARTTIME}: [ERROR]: mysql increment backup error." | tee -a ${LOGFILE}
   exit 1
else
   echo "${STARTTIME}: [INFO]: mysql increment backup successfully." |tee -a ${LOGFILE}
fi

# 结束备份
STOPTIME=`date +%Y%m%d_%H%M%S`
TIME_END=$(date +%s.%N)
echo "********************stop time:${STOPTIME}*********************" | tee -a ${LOGFILE}
RUNTIME=$(getTiming ${TIME_START} ${TIME_END})
echo "increment back use time: ${RUNTIME} " | tee -a ${LOGFILE}

