#!/bin/bash
NS=$POD_NAMESPACE
POD=$POD_NAME

RESULT="null"
IP=`curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/services/pushgateway-service | jq .status.loadBalancer.ingress[].ip | sed 's/"//g'`

python3 /bb_cloud/metric.py -g ${IP} &

while [ ${RESULT} == "null" ]
do
        RESULT=`curl -s --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/${NS}/pods/${POD} | jq .status.containerStatuses[] | jq 'select(.name == "main")' | jq .state.terminated.exitCode`
        
        if [ ${RESULT} == "0" ]; then
                echo -e "Main Container is Terminated"
                sleep 3
                break
            else
                echo -e "Main Container is still Running "
                sleep 3
        fi
done

echo -e "Process is Done"

exit 0
