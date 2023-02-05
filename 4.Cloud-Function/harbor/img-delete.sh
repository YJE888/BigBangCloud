#!/bin/bash
#####################################################
# Usage : ./img-delete.sh {NS} {IMG_Name} {TAG}     #
# config.ini 설정 필요                                #
#####################################################

if [ $1 = "-h" ] || [ $1 = "--help" ]
then
        echo -e "Usage : ./img-delete.sh {NS} {IMG_Name} {TAG}"
        exit 2
fi

NS=$1
REPO=$2
TAG=$3

HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})
TOKEN=$(awk '/^TOKEN/{print $3}' ${CONFIG_FILE})
# 이미지 삭제
curl -X DELETE \
  "https://${HOST}/api/v2.0/projects/${NS}/repositories/${REPO}/artifacts/${TAG}" \
  -H "accept: application/json" \
  -H "authorization: Basic ${AUTH}" \
  -H "X-Harbor-CSRF-Token: ${TOKEN}"

# 삭제 확인
curl -X GET \
  "https://${HOST}/api/v2.0/projects/${NS}/repositories/${REPO}/artifacts/${TAG}?page=1&page_size=10&with_tag=true&with_label=false&with_scan_overview=false&with_signature=false&with_immutable_status=false" \
  -H "accept: application/json" \
  -H "X-Accept-Vulnerabilities: application/vnd.security.vulnerability.report; version=1.1, application/vnd.scanner.adapter.vuln.report.harbor+json; version=1.0" \
  -H "authorization: Basic ${AUTH}" | grep -i "not_found"

if [ $? == 0 ]; then
  echo "SUCCESS"
else
  echo "FAIL"
fi

# Ansible을 사용하여 노드에 남아있는 이미지 삭제
# 이미지를 컨테이너에서 사용 중인지 확인
chk=`kubectl get pods -n ${NS} -o jsonpath="{.items[*].spec.containers[*].image}" | grep -w test.co.kr/${NS}/${REPO}:${TAG}`
if [ $? == 0 ]
    then
        echo "FAIL IS USED IMG 사용 중인 서비스를 종료하세요"
        exit 1
    else
        mkdir /tmp/${NS} && cp ~/harbor/ansible/* /tmp/${NS}
        echo -e "img_name=bigbangcloud-repo.co.kr/${NS}/${REPO}\nimg_tag=${TAG}" >> /tmp/${NS}/inventory
        ansible-playbook -i /tmp/${NS}/inventory /tmp/${NS}/img.yml
        if [ $? == 0 ]
          then
            rm -rf /tmp/${NS}
            echo "SUCCESS"
          else
            rm -rf /tmp/${NS}
            echo "FAIL"
        fi
fi

exit 0
