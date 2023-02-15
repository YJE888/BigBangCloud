#!/bin/bash

echo "[ ${NOW_TIME} ":" ##### START! Create ${NS} Kubeconfig! ##### ]" >> ~${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
CLUSTER=kubernetes
NS=""
PWD=$(cat /home/ehostdev/harbor/repo/password.txt)
LOG_DIR=/home/ehostdev/log/kubeconfig
YAML_PATH=//home/ehostdev/ext-volume/yaml
NOW_DATE=$(date +"%y_%m_%d_")
NOW_TIME=$(date +"%y/%m/%d_%T")

# Get Parameter
if ([ $# == 0 ]) || ([ $# -eq 1 ] && [ "$1" == "-h" -o "$1" == "--help" ]); then
  echo "setup-config [<CLUSTER>] <NAMESPACE>"
  echo " CLUSTER: cluster명이며 기본값은 kubernetes이며 생략할 수 있음"
  echo " NAMESPACE: namespace. 필수값"
  exit 2
fi

if [ $# == 1 ]; then
  NS=$1
elif [ $# == 2 ]; then
  CLUSTER=$1
  NS=$2
fi

# 1단계: 네임스페이스 생성
chk=`kubectl get ns | grep ${NS}`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" Create NameSpace ${NS} ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl create ns ${NS}
else
  echo "[ ${NOW_TIME} ":" NameSpace ${NS} already exists ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

# 2단계: (사용자) 서비스 어카운트 생성. sa-user-${NS}
chk=`kubectl get sa -n ${NS} | grep sa-user-${NS}`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" Create ServiceAccount sa-user-${NS} ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl create sa sa-user-${NS} -n ${NS}

else
  echo "[ ${NOW_TIME} ":" ServiceAccount sa-user-${NS} already exists in ${NS} ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

# ?단계: 미리 생성해둔 Role yaml을 사용하여 NS에 Role 배포 (사용자 권한 정의 필요). ro-user-${NS})
chk=`kubectl get role -n ${NS} | grep user-role`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" Create Role user-role ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl apply -f ${YAML_PATH}/user-role.yaml -n ${NS}
else
  echo "[ ${NOW_TIME} ":" Role user-role already exists ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

# 3단계: 배포해둔 User-Role과 SA를 RoleBinding 후, NS에 배포. user-rb-${NS}
chk=`kubectl get rolebinding -n ${NS} | grep user-rb-${NS}`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" Create RoleBinding user-rb-${NS} ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl create rolebinding user-rb-${NS} --role=user-role --serviceaccount=${NS}:sa-user-${NS} -n ${NS}
else
  echo "[ ${NOW_TIME} ":" Rolebinding user-rb-${NS} already exists ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

# 4단계: set-cluster (클러스터정보) 사용자 kubeconfig에 적용
echo "[ ${NOW_TIME} ":" Set-Cluster in ${NS}.config ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl config set-cluster ${CLUSTER} --server=https://103.249.29.75:6443 --insecure-skip-tls-verify --kubeconfig=/home/ehostdev/.kube/${NS}.config
echo -e "\n"

# 5단계: 사용자 서비스 어카운트 Token값 가져오기
SECRET=`kubectl get secret -n ${NS} | grep sa-user-${NS} | cut -d " " -f1`
TOKEN=`kubectl describe secret ${SECRET} -n ${NS} | grep token: | cut -d ":" -f2 | tr -d " "`

# 6단계: set-credentials (사용자정보) 사용자 kubeconfig에 적용
echo "[ ${NOW_TIME} ":" Set-Credentials in ${NS}.config ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl config set-credentials sa-user-${NS} --token=${TOKEN} --kubeconfig /home/ehostdev/.kube/${NS}.config
echo -e "\n"

# 7단계: user kubeconfig에 context 생성
echo "[ ${NOW_TIME} ":" Create Context in ${NS}.config ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl config set-context context-${NS} --user=sa-user-${NS} --cluster=${CLUSTER} --namespace=${NS} --kubeconfig /home/ehostdev/.kube/${NS}.config
echo -e "\n"

# 8단계: user kubeconfig에 current-context 변경
echo "[ ${NOW_TIME} ":" Change Current-Context in ${NS}.config ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  kubectl config use-context context-${NS} --kubeconfig=/home/ehostdev/.kube/${NS}.config
echo -e "\n"

# 9단계: 테스트
chk=`kubectl get pod -n ${NS} --kubeconfig /home/ehostdev/.kube/${NS}.config`
if [ $? == 0 ]; then
  # 정상의 경우, No resources found in ${NS} namespace. 
  echo "[ ${NOW_TIME} ":" SUCCESS!! to setup ${NS} user Kubeconfig !!]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else
  # 비정상의 경우, error로 시작. 오타 또는 Forbidden 뜨는 경우.
  echo "[ ${NOW_TIME} ":" FAIL!! to setup ${NS} user Kubeconfig !!!]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

echo "[ ${NOW_TIME} ":" ##### END of setup ${NS} user kubeconfig! ##### ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
echo -e "\n"

# 10단계: Private 저장소 (Harbor) Secret 생성 및 배포
echo "[ Create private repository secret  ]"
  kubectl create secret -n ${NS} docker-registry bigbangcloud-repo.co.kr --docker-username=admin --docker-password=${PWD} --docker-server=bigbangcloud-repo.co.kr
echo -e "\n"

# 11단계: Harbor Project 생성
./home/ehostdev/harbor/create-project.sh ${NS}
echo "[ ${NOW_TIME} ":" ##### Create Harbor Project! ##### ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1

# 12단계: SSH Directroy 생성
mkdir ~/client/${NS}
echo "[ ${NOW_TIME} ":" ##### Create SSH Directory! ##### ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1

# 종료
echo "[ ${NOW_TIME} ":" ##### All Create Process is Done ##### ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
echo -e "\n"

exit 0
