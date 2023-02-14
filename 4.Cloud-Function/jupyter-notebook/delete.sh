#!/bin/bash
NS=$1
PNAME=$2
JN=${PNAME}"-jn"
TB=${PNAME}"-tb"
JUPYTER=${NS}"-"${PNAME}"-jn"
TENSOR=${NS}"-"${PNAME}"-tb"
EMAIL=$(awk '/^Email/{print $3}' ${CONFIG_FILE})
KEY=$(awk '/^Auth-Key/{print $3}' ${CONFIG_FILE})
SERVICE_KEY=$(awk '/^Service-Key/{print $3}' ${CONFIG_FILE})
ZONEID=$(awk '/^ZONEID/{print $3}' ${CONFIG_FILE})
DOMAIN=$(awk '/^DOMAIN/{print $3}' ${CONFIG_FILE})
CONFIG=/home/ehostdev/ext-volume/.kube/${NS}.config

#ehostcloud-tls secret 삭제 시 certificate도 삭제되므로 certificate 개수 확인 후 bigbangcloud-tls secret을 삭제해야됨
kubectl delete ingress -n ${NS} --kubeconfig ${CONFIG} ${PNAME}-ingress
kubectl delete service -n ${NS} --kubeconfig ${CONFIG} ${JN}-service
kubectl delete service -n ${NS} --kubeconfig ${CONFIG} ${TB}-service
kubectl delete secrets -n ${NS} --kubeconfig ${CONFIG} ${JUPYTER}-bigbangcloud-tls
kubectl delete secrets -n ${NS} --kubeconfig ${CONFIG} ${TENSOR}-bigbangcloud-tls

#Jupyter 삭제
DNSID=`curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${JUPYTER}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${KEY}" -H "Content-Type: application/json" | grep id | cut -d '"' -f 6`
SSLID=`curl -X GET "https://api.cloudflare.com/client/v4/certificates?zone_id=${ZONEID}" -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" | jq '.' | grep -B 10 "${JUPYTER}" | grep '"id"' | cut -d '"' -f4`

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records/${DNSID}" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" > /dev/null 2>&1
curl -X DELETE "https://api.cloudflare.com/client/v4/certificates/${SSLID}" \
     -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" > /dev/null 2>&1

# 삭제 확인
curl -X GET "https://api.cloudflare.com/client/v4/certificates?zone_id=${ZONEID}" \
     -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" | grep -o ${SSLID}

if [ $? == 0 ]
then
        echo -e "  Origin CA Delete status is FALSE"
else
        echo -e "  Origin CA Delete status is TRUE"
fi

curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${JUPYTER}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${KEY}" -H "Content-Type: application/json" | grep -o ${DNSID}

if [ $? == 0 ]
then
        echo -e "  CNAME Delete status is FALSE"
else
        echo -e "  CNAME Delete status is TRUE"
fi

#Tensor 삭제
DNSID=`curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${TENSOR}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${KEY}" -H "Content-Type: application/json" | grep id | cut -d '"' -f 6`
SSLID=`curl -X GET "https://api.cloudflare.com/client/v4/certificates?zone_id=${ZONEID}" -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" | jq '.' | grep -B 10 "${TENSOR}" | grep '"id"' | cut -d '"' -f4`
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records/${DNSID}" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" > /dev/null 2>&1
curl -X DELETE "https://api.cloudflare.com/client/v4/certificates/${SSLID}" \
     -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" > /dev/null 2>&1


# 삭제 확인
curl -X GET "https://api.cloudflare.com/client/v4/certificates?zone_id=${ZONEID}" \
     -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" | grep -o ${SSLID}

if [ $? == 0 ]
then
        echo -e "  Origin CA Delete status is FALSE"
else
        echo -e "  Origin CA Delete status is TRUE"
fi

curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${TENSOR}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${KEY}" -H "Content-Type: application/json" | grep -o ${DNSID}

if [ $? == 0 ]
then
        echo -e "  CNAME Delete status is FALSE"
else
        echo -e "  CNAME Delete status is TRUE"
fi

exit 0
