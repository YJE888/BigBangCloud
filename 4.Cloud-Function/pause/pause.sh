#!/bin/bash
if [ $1 = "-h" ] || [ $1 = "--help" ]
then                     
        echo -e "Usage : ./pause.sh {NS} {POD_NAME}"
        exit 2           
fi 

NS=$1
PID=$2
HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})
PNAME=$(kubectl get pod -n ${NS} | grep -w ${PID} | cut -d " " -f 1)
NODE=$(kubectl get pods ${PNAME} -n ${NS} -o jsonpath={.spec.nodeName})
CID=$(kubectl get pods -n ${NS} ${PNAME} -o jsonpath={.status.containerStatuses['?(@.name=="main")'].containerID} | rev | cut -c -64 | rev)
IMGID=$(ssh root@${NODE} "docker images | grep -w ^bigbangcloud-repo.co.kr/${NS}/conpause | column -t | cut -d ' ' -f 5;exit;")
CONFIG=/home/ehostdev/ext-volume/.kube/${NS}.config

#하버 이미지 존재 여부 확인
chk=$(curl -X 'GET'   "https://${HOST}/api/v2.0/projects/${NS}/repositories/conpause/artifacts?page=1&page_size=10&with_tag=true&with_label=fal=false&with_immutable_status=false"   -H "accept: application/json"   -H "X-Accept-Vulnerabilities: application/vnd.security.vulnerability.repter.vuln.report.harbor+json; version=1.0"   -H "authorization: Basic ${AUTH}" | grep digest)

if [ $? == 0 ]; then
    DIGEST=$(curl -X 'GET'   "https://${HOST}/api/v2.0/projects/${NS}/repositories/conpause/artifacts?page=1&page_size=10&with_tag=true&with_label=fal=false&with_immutable_status=false"   -H "accept: application/json"   -H "X-Accept-Vulnerabilities: application/vnd.security.vulnerability.repter.vuln.report.harbor+json; version=1.0"   -H "authorization: Basic ${AUTH}" | jq '.' | grep digest | tr -d '",' | awk '{print $2}')

    ssh root@${NODE} "docker commit ${CID} bigbangcloud-repo.co.kr/${NS}/conpause:pause;cat /root/repo/my_password.txt | docker login bigbangcloud-repo.co.kr --username admin --password-stdin;docker push bigbangcloud-repo.co.kr/${NS}/conpause:pause;docker logout bigbangcloud-repo.co.kr;exit;"
    curl -X 'DELETE' \
    "https://${HOST}/api/v2.0/projects/${NS}/repositories/conpause/artifacts/${DIGEST}" \
    -H "accept: application/json" \
    -H "authorization: Basic ${AUTH}" \
    -H "X-Harbor-CSRF-Token: ${TOKEN}"
    chk=$(curl -X 'GET'   "https://${HOST}/api/v2.0/projects/${NS}/repositories/conpause/artifacts?page=1&page_size=10&with_tag=true&with_label=fal=false&with_immutable_status=false"   -H "accept: application/json"   -H "X-Accept-Vulnerabilities: application/vnd.security.vulnerability.repter.vuln.report.harbor+json; version=1.0"   -H "authorization: Basic ${AUTH}" | grep digest)
    if [ $? == 0 ]; then
        kubectl delete deployments -n ${NS} ${PID}
        sleep 5
        for ((i=0; i<20; i++)); do
            kubectl get pods -n ${NS} | grep ${PNAME}
            if [ $? == 0 ]; then
                echo "언제 삭제됨"
            else
                ssh root@${NODE} "docker image rm bigbangcloud-repo.co.kr/${NS}/conpause:pause;docker image rm ${IMGID};exit"
                break
            fi
            sleep 2
            echo "deployment 삭제 실패1"
        done
    else
      echo "Image doesn't exist in harbor1"
      exit 2
    fi
    echo "디플로이먼트, 이미지 삭제 완료"
else
    ssh root@${NODE} "docker commit ${CID} bigbangcloud-repo.co.kr/${NS}/conpause:pause;cat /root/repo/my_password.txt | docker login bigbangcloud-repo.co.kr --username admin --password-stdin;docker push bigbangcloud-repo.co.kr/${NS}/conpause:pause;docker logout ehost-repo.xyz;exit;"
    
    chk=$(curl -X 'GET'   "https://${HOST}/api/v2.0/projects/${NS}/repositories/conpause/artifacts?page=1&page_size=10&with_tag=true&with_label=fal=false&with_immutable_status=false"   -H "accept: application/json"   -H "X-Accept-Vulnerabilities: application/vnd.security.vulnerability.repter.vuln.report.harbor+json; version=1.0"   -H "authorization: Basic ${AUTH}" | grep digest)
    if [ $? == 0 ]; then
      kubectl delete deployments --kubeconfig ${CONFIG} -n ${NS} ${PID}
      sleep 5
        for ((i=0; i<20; i++)); do
            kubectl get pods -n ${NS} | grep ${PNAME}
            if [ $? == 0 ]; then
                echo "언제 삭제됨"
            else
                ssh root@${NODE} "docker image rm bigbangcloud-repo.co.kr/${NS}/conpause:pause;exit;"
                break
            fi
            sleep 2
            echo "deployment 삭제 실패2"  
        done
    else
      echo "Image doesn't exist in harbor2"
      exit 2
    fi
    echo "디플로이먼트, 이미지 삭제 완료"
fi  
exit 0
