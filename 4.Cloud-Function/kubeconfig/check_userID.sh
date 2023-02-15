#!/bin/bash

# HA Proxy에서 실행시켜놓을 스크립트. 파일시스템 변화감지 후, 가입/탈퇴 수행
# nohup, & 실행할 것

MONITOR_PATH=/ext-volume/user-id
SCRIPT_PATH=/ext-volume/script
LOG_PATH=/ext-volume/inotify.log
EVENT=create,delete

inotifywait -e $EVENT -s -m --exclude ".*" "$MONITOR_PATH" | 
while read dir event file;
do
    if [ $event == "CREATE" ]; then
        chk=`ls $MONITOR_PATH | grep $file`
        if [ $? == 1 ]; then
            $SCRIPT_PATH/create_kubeconfig.sh $file
            echo "[$(date +"%y_%m_%d_%T") ":" CREATE "$file"]" >> $LOG_PATH
        else
            echo "[$(date +"%y_%m_%d_%T") ":" "$file" exist ]" >> $LOG_PATH
    elif [ $event == "DELETE" ]; then
        chk=`ls $MONITOR_PATH | grep $file`
        if [ $? == 0 ]; then
            $SCRIPT_PATH/delete_kubeconfig.sh $file
            echo "[$(date +"%y_%m_%d_%T") ":" DELETE "$file"]" >> $LOG_PATH
        else
            echo "[$(date +"%y_%m_%d_%T") ":" "$file" doesn't exist ]" >> $LOG_PATH
done

exit 0
