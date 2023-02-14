#!/bin/bash
 
SERVICE="jupyter-lab"
 
case "$1" in
    start)
        echo "[ jupyter-lab starting ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then 
                echo "$SERVICE start in progress"
                jupyter lab --allow-root --ip=0.0.0.0 --port=8889 &
                exit
        else
                echo "jupyter-lab is still running, do not have to start process"
        fi
        ;;
     stop)
        echo "[ jupyter-lab stoping ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then
                echo "$SERVICE stopped"
        else
                PIDs=`ps -ef | grep $SERVICE | grep -v 'grep' | awk '{print $2}'`
                kill -9 $PIDs >/dev/null 2>&1
                echo "$SERVICE stop done"
        fi
        ;;
   status)
        echo "[ jupyter-lab status ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then
                echo "$SERVICE stopped"
        else
                echo "$SERVICE is running"
        fi
        ;;
  restart)
        echo "[ jupyter-lab restart ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then
                echo "$SERVICE stopped, start the $SERVICE"
                jupyter lab --allow-root --ip=0.0.0.0 --port=8889 &
                exit
        else
                PIDs=`ps -ef | grep $SERVICE | grep -v 'grep' | awk '{print $2}'`
                kill -9 $PIDs >/dev/null 2>&1
                echo "$SERVICE restart in progress"
                sleep 5
                jupyter lab --allow-root --ip=0.0.0.0 --port=8889 &
                exit
        fi
        ;;
        *)
        echo "Usage: $0 {start|stop|status|restart}"
        ;;
esac
