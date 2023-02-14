#!/bin/bash
 
SERVICE="jupyter-notebook"
 
case "$1" in
    start)
        echo "[ jupyter-notebook starting ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then 
                echo "$SERVICE start in progress"
                jupyter notebook --allow-root --ip=0.0.0.0 --port=8888 &
                exit
        else
                echo "jupyter-notebook is still running, do not have to start process"
        fi
        ;;
     stop)
        echo "[ jupyter-notebook stoping ]"
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
        echo "[ jupyter-notebook status ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then
                echo "$SERVICE stopped"
        else
		jupyter notebook list

        fi
        ;;
  restart)
        echo "[ jupyter-notebook restart ]"
        chk=`pgrep -f $SERVICE`
        if [ -z $chk ]
        then
                echo "$SERVICE stopped, start the $SERVICE"
                jupyter notebook --allow-root --ip=0.0.0.0 --port=8888 &
                exit
        else
                PIDs=`ps -ef | grep $SERVICE | grep -v 'grep' | awk '{print $2}'`
                kill -9 $PIDs >/dev/null 2>&1
                echo "$SERVICE restart in progress"
                sleep 5
                jupyter notebook --allow-root --ip=0.0.0.0 --port=8888 &
                exit
        fi
        ;;
        *)
        echo "Usage: $0 {start|stop|status|restart}"
        ;;
esac
