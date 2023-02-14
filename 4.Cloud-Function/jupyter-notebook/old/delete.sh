#!/bin/bash
NS=$1
PNAME=$2
CNAME=${NS}"-"${PNAME}
EMAIL=$(awk '/^Email/{print $3}' ${CONFIG_FILE})
KEY=$(awk '/^Key/{print $3}' ${CONFIG_FILE})
SERVICE_KEY=$(awk '/^Service-Key/{print $3}' ${CONFIG_FILE})
SSLIDURL=$(awk '/^SSLIDURL/{print $3}' ${CONFIG_FILE})
DNSID=`curl -X GET "https://api.cloudflare.com/client/v4/zones/593cbb3824f9a5103c6de94d008fd42a/dns_records?type=CNAME&name=${CNAME}.ehostcloud.xyz&content=ehostcloud.xyz&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" -H "X-Auth-Email: ${EMAIL}" -H "X-Auth-Key: ${KEY}" -H "Content-Type: application/json" | grep id | cut -d '"' -f 6`
SSLID=`curl -X GET "${SSLIDURL}" -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" | jq '.' | grep -B 10 "${CNAME}" | grep '"id"' | cut -d '"' -f4`

#인증서,DNS, Ingress, Service 삭제

chk=`kubectl get certificate -n ${NS} --no-headers | wc -l`
if [ ${chk} -gt 1 ]
then
     echo -e " originissuer remainning "
else
     echo -e " delete originissuer, service-key "
     kubectl delete originissuers -n ${NS} prod-issuer
     kubectl delete secrets -n ${NS} service-key
fi
#ehostcloud-tls secret 삭제 시 certificate도 삭제되므로 certificate 개수 확인 후 ehostcloud-tls secret을 삭제해야됨
kubectl delete ingress -n ${NS} ${PNAME}-ingress
kubectl delete service -n ${NS} ${PNAME}-service
kubectl delete secrets -n ${NS} ${PNAME}-ehostcloud-tls

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/593cbb3824f9a5103c6de94d008fd42a/dns_records/${DNSID}" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" > /dev/null 2>&1
curl -X DELETE "https://api.cloudflare.com/client/v4/certificates/${SSLID}" \
     -H "X-Auth-User-Service-Key: ${SERVICE_KEY}" > /dev/null 2>&1

if [ $? == 0 ]
then
        echo -e "  Delete status is ${GREEN}TRUE${NC}"
else
        echo -e "  Delete status is ${RED}FALSE${NC}"
fi
exit 0
