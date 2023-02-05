#!/bin/bash
#####################################################
# Usage : ./copy-img.sh {NS} {IMG_Name} {TAG}       #
# config.ini 설정 필요                                #
#####################################################

if [ $1 = "-h" ] || [ $1 = "--help" ]
then
        echo -e "Usage : ./copy-img.sh {NS} {IMG_Name} {TAG}"
        exit 2
fi

NS=$1
REPO=$2
TAG=$3
IMG_NAME=${NS}"-"${REPO}
HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})
TOKEN=$(awk '/^TOKEN/{print $3}' ${CONFIG_FILE})

# share 프로젝트에서 이미지가 있는지 확인
curl -X GET \
  "https://${HOST}/api/v2.0/projects/share/repositories/${IMG_NAME}/artifacts/${TAG}/tags?page=1&page_size=10&with_signature=false&with_immutable_status=false" \
  -H "accept: application/json" \
  -H "authorization: Basic ${AUTH}" | grep -i "not_found" > /dev/null 2>&1

# 이미지가 없다면 share 프로젝트로 이미지 복사 진행
if [ $? == 0 ]; then
    curl -X POST \
      "https://${HOST}/api/v2.0/projects/share/repositories/${IMG_NAME}/artifacts?from=${NS}%2F${REPO}%3A${TAG}" \
      -H "accept: application/json" \
      -H "authorization: Basic ${AUTH}" \
      -H "X-Harbor-CSRF-Token: ${TOKEN}" \
      -d ""
else
    echo "Image exist"
fi

# 이미지 정상 복사 
curl -X GET \
  "https://${HOST}/api/v2.0/projects/share/repositories/${IMG_NAME}/artifacts/${TAG}/tags?page=1&page_size=10&with_signature=false&with_immutable_status=false" \
  -H "accept: application/json" \
  -H "authorization: Basic ${AUTH}" | grep -i "not_found" > /dev/null 2>&1

if [ $? == 0 ]; then
  echo "Image copy fail"
else
  echo "Image copy success"
fi

exit 0
