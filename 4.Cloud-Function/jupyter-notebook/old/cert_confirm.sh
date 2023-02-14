#!/bin/bash

# 인증서 최종 생성 및 적용 확인

NS=$1

echo -e "${BLUE}#### Check Certificate status ####${NC}"
sleep 10
chk=`kubectl get -n ${NS} certificate | grep True`
if [ $? == 0 ]
then
        echo -e "  Certificate status is ${GREEN}TRUE${NC}"
else
        echo -e "  Certificate status is ${RED}Fail${NC}"
fi

exit 0
