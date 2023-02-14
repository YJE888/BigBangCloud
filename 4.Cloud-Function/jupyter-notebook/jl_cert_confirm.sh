#!/bin/bash
NS=$1
PNAME=$2

STATUS=`kubectl get -n ${NS} certificate | grep "${NS}-${PNAME}-jl" | awk '{print $2}'`
if [ -z ${STATUS} ]; then
    echo "JL Certificate Not Found"
    exit 2
else
    if [ ${STATUS} == "False" ]; then
        echo -e "JL Certificate status is Fail"
        exit 2
    else
        echo -e "JL Certificate status is Success"
    fi
fi
exit 0
