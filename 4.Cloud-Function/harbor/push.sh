#!/bin/bash
###################################################################
# Usage : ./push.sh {NS} {PNAME} {IMG_Name} {TAG}                 #
# 워커노드마다 my_password.txt에 harbor 패스워드 입력한 파일 필요           #
# PNAME : pod 명, NODE : 노드명, CID : Container ID                 #
###################################################################
if [ $1 = "-h" ] || [ $1 = "--help" ] 
then
	echo -e "Usage : ./push.sh {NS} {PID} {REPO} {TAG}"
	exit 2
fi

NS=$1
PID=$2
REPO=$3
TAG=$4
HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})

PNAME=$(kubectl get pod -n ${NS} | grep -w ${PID} | cut -d " " -f 1)

NODE=$(kubectl get pods ${PNAME} -n ${NS} -o jsonpath={.spec.nodeName})

CID=$(kubectl get pods -n ${NS} ${PNAME} -o jsonpath={.status.containerStatuses['?(@.name=="main")'].containerID} | rev | cut -c -64 | rev)

ssh root@${NODE} "docker commit ${CID} ${HOST}/${NS}/${REPO}:${TAG};cat /root/repo/my_password.txt | docker login ${HOST} --username admin --password-stdin;docker push ${HOST}/${NS}/${REPO}:${TAG};docker logout ${HOST};exit;"

curl -X GET \
  "https://${HOST}/api/v2.0/projects/${NS}/repositories/${REPO}/artifacts/${TAG}?page=1&page_size=10&with_tag=true&with_label=false&with_scan_overview=false&with_signature=false&with_immutable_status=false" \
  -H "accept: application/json" \
  -H "X-Accept-Vulnerabilities: application/vnd.security.vulnerability.report; version=1.1, application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0" \
  -H "authorization: Basic ${AUTH}" | grep -i "not_found"

if [ $? == 1 ]; then
  echo "SUCCESS to creating img"
else
  echo "FAIL to creating img"
fi

exit 0
