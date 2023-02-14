#!/bin/bash
 
SERVICE="tensorboard"
LOGDIR="$2"
 
case "$1" in
    start)
        echo "[ tensorboard starting ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then 
                echo "tensorboard starting"
                tensorboard --logdir=$LOGDIR --host=0.0.0.0 --port=6006 &
                exit
        else 
                echo "tensorboard is still running, do not have to start process"
        fi
        ;;
     stop)
        echo "[tensorboard stoping ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        chk=`pgrep -f $SERVICE | wc -l`
        if [ $chk -eq 2 ]
	       then
                PIDs=`ps -ef | grep $SERVICE | grep -v 'grep' | awk '{print $2}'`
                kill -9 $PIDs >/dev/null 2>&1
                echo "$SERVICE stop done"
	       else
                echo "$SERVICE stopped"

        fi
        ;;
   status)
        echo "[ tensorboard status ]"
        chk=`pgrep -f $SERVICE | wc -l`
        if [ $chk -eq 2 ]
        then
                echo "$SERVICE is running"
        else
                echo "$SERVICE stopped"
        fi
        ;;
        *)
        echo "Usage: $0 {start|stop|status} {log-dir}"
        ;;
esac
