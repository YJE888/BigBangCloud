#!/bin/bash
#####################################################
# Usage : ./copy-img-delete.sh {NS} {IMG_Name} {TAG}#
# config.ini 설정 필요                                #
#####################################################

if [ $1 = "-h" ] || [ $1 = "--help" ]
then
        echo -e "Usage : ./copy-img-delete_new.sh {NS} {IMG_Name} {TAG}"
        exit 2
fi

NS=$1
REPO=$2
TAG=$3
IMG_NAME=${NS}"-"${REPO}
HOST=$(awk '/^HOST/{print $3}' ${CONFIG_FILE})
AUTH=$(awk '/^AUTH/{print $3}' ${CONFIG_FILE})
TOKEN=$(awk '/^TOKEN/{print $3}' ${CONFIG_FILE})

# 이미지 삭제
curl -X DELETE \
  "https://${HOST}/api/v2.0/projects/share/repositories/${IMG_NAME}/artifacts/${TAG}" \
  -H "accept: application/json" \
  -H "authorization: Basic ${AUTH}" \
  -H "X-Harbor-CSRF-Token: ${TOKEN}"

# 이미지 존재 유무 
curl -X GET \
  "https://${HOST}/api/v2.0/projects/share/repositories/${IMG_NAME}/artifacts/${TAG}/tags?page=1&page_size=10&with_signature=false&with_immutable_status=false" \
  -H "accept: application/json" \
  -H "authorization: Basic ${AUTH}" | grep -i "not_found" > /dev/null 2>&1

if [ $? == 0 ]; then
  echo "Copy image deletion success"
else
  echo "Copy image deletion fail"
fi
exit 0
