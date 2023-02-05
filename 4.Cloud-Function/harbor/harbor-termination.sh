#!/bin/bash
####################################################################
# Usage : ./harbor-termination.sh {NS}                             #
# jq package required                                              #
# 접속 및 계정 정보가 들어있는 config.ini 파일이 필요함                      #
# 고객 해지 시 모든 image 삭제 및 project 삭제 스크립트                     #
####################################################################
if [ $1 = "-h" ] || [ $1 = "--help" ]
then
        echo -e "Usage : ./harbor-termination.sh {NS}"
        exit 2
fi
echo "##### START harbor-termination.sh! #####"

NS=$1
HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})
TOKEN=$(awk '/^TOKEN/{print $3}' ${CONFIG_FILE})

mkdir -p /tmp/${NS} && cd /tmp/${NS}
# 프로젝트에 들어있는 이미지 명을 가져옴
curl -X GET \
  "https://${HOST}/api/v2.0/projects/${NS}/repositories?page=1&page_size=10" \
  -H "accept: application/json" \
  -H "authorization: Basic ${AUTH}" | jq "." | awk '/name/ {print $2}' | tr -d '",' | sort | sed 's:.*/::' > ${NS}.json

# 이미지명을 읽어 RepoDelete()를 돌리며 순차적으로 이미지 삭제 진행
cat ${NS}.json

RepoDelete() {
    for repo in `cat ${NS}.json`;
    do
        curl -X DELETE \
        "https://${HOST}/api/v2.0/projects/${NS}/repositories/${repo}" \
        -H "accept: application/json" \
        -H "authorization: Basic ${AUTH}" \
        -H "X-Harbor-CSRF-Token: ${TOKEN}"
    done
}

RepoDelete $repo

# Project 삭제
curl -X DELETE \
  "https://${HOST}/api/v2.0/projects/${NS}" \
  -H "accept: application/json" \
  -H "X-Is-Resource-Name: false" \
  -H "authorization: Basic ${AUTH}" \
  -H "X-Harbor-CSRF-Token: ${TOKEN}"

cd ../ && rm -rf ${NS}

echo "##### END harbor-termination.sh! #####"
exit 0
