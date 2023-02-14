#!/bin/bash
NS=$1
PNAME=$2

STATUS=`kubectl get -n ${NS} certificate | grep "${NS}-${PNAME}-jn" | awk '{print $2}'`
if [ -z ${STATUS} ]; then
    echo "JN Certificate Not Found"
    exit 2
else
    if [ ${STATUS} == "False" ]; then
        echo -e "JN Certificate status is Fail"
        exit 2
    else
        echo -e "JN Certificate status is Success"
    fi
fi
exit 0
