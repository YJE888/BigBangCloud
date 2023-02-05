#!/bin/bash
################################################
# Usage : ./create-project.sh {NS}             #
# harbor project 생성 스크립트                    #
# config.ini 설정 필요                           #
################################################
if [ $1 = "-h" ] || [ $1 = "--help" ]
then
        echo -e "Usage : ./create-project.sh {NS}"
        exit 2
fi

NS=$1
HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})
TOKEN=$(awk '/^TOKEN/{print $3}' ${CONFIG_FILE})
curl -X POST \
  "https://${HOST}/api/v2.0/projects" \
  -H "accept: application/json" \
  -H "X-Resource-Name-In-Location: false" \
  -H "authorization: Basic ${AUTH}" \
  -H "Content-Type: application/json" \
  -H "X-Harbor-CSRF-Token: ${TOKEN}" \
  -d '{
  "project_name": "'${NS}'",
  "public": false
}'

exit 0
