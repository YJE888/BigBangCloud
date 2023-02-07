#!/bin/bash
NS=$1
PNAME=$2
CID=$3
YMD=`date +%y-%m-%d`
datetime=`date +%H`"-00"
# pod의 CID를 사용하여 변경분이 작성되는 UpperDir로 이동하여 home이 생성되었는지 확인
cd $(docker inspect ${CID} --format='{{.GraphDriver.Data.UpperDir}}')
chk=`ls -l home`
if [ $? == 0 ]; then
    # 년월일 디렉토리가 있는지 확인 후 없다면 생성
    if [ -d /backup-volume/${YMD} ]; then
        echo "${YMD} dir exists"
    else
        mkdir /backup-volume/${YMD}
    fi
    # 년월일 디렉토리 아래 특정 시간의 디렉토리가 있는지 확인 후 없다면 생성(ex. 06-00)
    if [ -d /backup-volume/${YMD}/${datetime} ]; then
        echo "${datetime} dir exists"
    else
        mkdir /backup-volume/${YMD}/${datetime}
    fi
    # 시간 디렉토리 아래 NS와 Pod이름으로 생성된 디렉토리가 있는지 확인 후 없다면 생성
    if [ -d /backup-volume/${YMD}/${datetime}/${NS}/${PNAME} ]; then
        echo "${PNAME} dir exists"
    else
        mkdir -p /backup-volume/${YMD}/${datetime}/${NS}/${PNAME}
    fi
    # 위에서 만든 경로에 home 디렉토리 
    cp -r ./home /backup-volume/${YMD}/${datetime}/${NS}/${PNAME}

else
    echo "백업 대상이 없음"
fi

exit 0
