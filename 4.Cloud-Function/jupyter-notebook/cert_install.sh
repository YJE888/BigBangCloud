#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
CONFIG=/home/ehostdev/ext-volume/.kube/${NS}.config

#인증서 생성을 위한 시스템 구성 (OriginIssuer, Secret)

NS=""
SERVICE_KEY=$(awk '/^Service-Key/{print $3}' ${CONFIG_FILE})

if [ $# == 0 ]; then
        echo -e "${BLUE}shell_script.sh <namespace>${NC}"
        echo -e "${RED}<namespace>는 필수값임${NC}"
        exit 2
fi

NS=$1

chk=`kubectl get ns | grep ${NS}`
if [ $? == 0 ]
then
	echo "namespace ${NS} exists"
else
	echo -e "${RED}${NS} namespace does not exist${NC}"
	exit 2
fi

chk=`which jq > /dev/null 2>&1`
if [ $? == 0 ]
then
	echo -e " jq aleady install "
else
	echo -e " Install jq package"
	yum -y install jq > /dev/null 2>&1
fi

echo -e "${BLUE}#### Create the Secret ####${NC}"


chk=`kubectl get secret -n ${NS} | grep service-key`
if [ $? == 0 ]
then
	echo -e " Create the Secret ${GREEN}Success${NC}"
else
	echo -e " [ Create the Secret ]"
kubectl create secret generic \
    -n ${NS} service-key \
    --from-literal key=${SERVICE_KEY}
    --kubeconfig ${CONFIG}
fi

echo -e "${BLUE}#### Create the OriginIssuer ####${NC}"

chk=`kubectl get -n ${NS} originissuers.cert-manager.k8s.cloudflare.com | grep prod-issuer`
if [ $? == 0 ]
then
        echo -e "OriginIssuer already exists"
else
        echo -e "[ Create the OriginIssuer ]"
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.k8s.cloudflare.com/v1
kind: OriginIssuer
metadata:
  name: prod-issuer
  namespace: ${NS}
spec:
  requestType: OriginECC
  auth:
    serviceKeyRef:
      name: service-key
      key: key
EOF
fi

echo -e "${BLUE}#### Check OriginIssuer status ####${NC}"
chk=`kubectl get originissuer.cert-manager.k8s.cloudflare.com prod-issuer -n ${NS} -o json | jq .status.conditions | grep True`
if [ $? == 0 ]
then
        echo -e " OriginIssuer status is ${GREEN}TRUE${NC} "
else
        echo -e " OriginIssuer status is ${RED}FALSE${NC} "
fi

exit 0
