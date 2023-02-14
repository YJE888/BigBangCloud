#!/bin/bash
NS=$1
PNAME=$2
CNAME=${NS}"-"${PNAME}

#사용자도메인 Cname 생성 및 DNS등록 조회

echo -e "#### Install jq package ####"
yum -y install bind-utils > /dev/null 2>&1

chk=`which dig`
if [ $? == 0 ]
then
        echo -e "bind install Success"
else
        echo -e "bind install Fail"
fi

/home/ehostdev/jupyter/cloudflare-dns/cf-dns.sh -d ehostcloud.xyz -t CNAME -n ${CNAME} -c ehostcloud.xyz -l 1 -x y

for ((i=0; i<5; i++)); do
        nslookup ${CNAME}.ehostcloud.xyz
        if [ $? == 0 ]
        then
                echo " DNS Registration Success "
		break
        else
                echo " DNS 등록 실패 "
        fi
        sleep 3
done

exit 0
