#!/bin/bash

echo "[ ${NOW_TIME} ":" ##### START! DELETE ${NS} Kubeconfig! ##### ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
NS=$1
TOKEN=$(awk '/^CLUSTER/{print $3}' ${CONFIG_FILE})
APISERVER=$(kubectl cluster-info | grep "Kubernetes" | awk -F ' ' '{print $7}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

if ([ $# == 0 ]) || ([ $# -eq 1 ] && [ "$1" == "-h" -o "$1" == "--help" ]); then
  echo "setup-config <NAMESPACE>"
  echo " NAMESPACE: namespace. 필수값"
  exit 2
fi

# 1단계: Context 확인 및 변경 (admin으로)
echo "[ ${NOW_TIME} ":" Switch Current-Context ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
chk=`kubectl config current-context | grep kubernetes-admin@kubernetes`
if [ $? == 1 ]; then
  kubectl config use-context kubernetes-admin@kubernetes
  echo "[ ${NOW_TIME} ":" the current-context changed kubernetes-admin@kubernetes.]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else
  echo "[ ${NOW_TIME} ":" kubernetes-admin@kubernetes is the current-context.]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

# 2단계: 사용자 RoleBinding 삭제
echo "[ ${NOW_TIME} ":" Delete Rolebinding ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
chk=`kubectl get rolebinding | grep user-rb-${NS}`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" RoleBinding user-rb-${NS} already deleted ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else
  kubectl delete rolebindings -n ${NS} user-rb-${NS}
fi
echo -e "\n"

# 3단계: 사용자 서비스 어카운트 삭제
echo "[ ${NOW_TIME} ":" Delete ServiceAccount ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
chk=`kubectl get sa -n ${NS}  | grep user-sa-${NS}`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" user-sa-${NS} already deleted ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else  
  kubectl delete sa -n ${NS} user-sa-${NS}
fi
echo -e "\n"

# 4단계: 사용자 Role 삭제
echo "[ ${NOW_TIME} ":" Delete Role ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
chk=`kubectl get role -n ${NS} | grep user-role`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" Role user-role already deleted ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else
  kubectl delete role -n ${NS} user-role
fi
echo -e "\n"

# 5단계: 사용자 네임스페이스 삭제
echo "[ ${NOW_TIME} ":"  Delete NameSpace ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
chk=`kubectl get ns | grep ${NS}`
if [ $? == 1 ]; then
  echo "[ ${NOW_TIME} ":" ${NS} already deleted ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else 
  kubectl delete ns ${NS}&
  echo "[ ${NOW_TIME} ":" ${NS} is deleting ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  sleep 5
  chk=`kubectl get ns ${NS} -o jsonpath='{.status.phase}'`
    if [ $chk == Terminating ]; then
      kubectl get namespace ${NS} -o json | jq '.spec = {"finalizers":[]}' > /home/ehostdev/temp/${NS}-temp.json
      echo "[ ${NOW_TIME} ":" making temp.json is Done ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
      curl -k -X PUT --insecure "${APISERVER}/api/v1/namespaces/${NS}/finalize" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      --data-binary @/home/ehostdev/temp/${NS}-temp.json
      rm -rf /home/ehostdev/temp/${NS}-temp.json
      echo "[ ${NOW_TIME} ":" deleting temp.json is Done ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
    else
      echo "[ ${NOW_TIME} ":" ${NS} is Deleted ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
    fi
fi
echo -e "\n"

# 주석시작 (예전코드)
: << "END" 
# /root/.kube/config 파일에서 sa-${NS} 내용 삭제
echo "[ Delete user ]======================================================="
chk=`kubectl config view | grep sa-${NS}`
if [ $? == 1 ]; then
  echo "sa-${NS} already delete" 
else
  kubectl config unset users.sa-user-${NS}
fi
echo -e "\n"

# /root/.kube/config 파일에서 ${NS} context 내용 삭제
echo "[ Delete context ]===================================================="
chk=`kubectl config view | grep ${NS}`
if [ $? == 1 ]; then
  echo "${NS} context already delete"
else
  kubectl config delete-context context-${NS}
fi
END #주석끝

# 6단계: 사용자 kubeconfig 파일 삭제 (/home/ehostdev/.kube/${NS}.config) 및 삭제 확인
echo "[ ${NOW_TIME} ":" Try to delete User Kubeconfig! ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
  cd /home/ehostdev/.kube
  rm -f ${NS}.config


ls /home/ehostdev/.kube/${NS}.config > /dev/null 2>&1
if [ $? == 0 ]; then
  echo "[ ${NOW_TIME} ":" FAIL!! delete Kubeconfig !!! ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
else
  echo "[ ${NOW_TIME} ":" SUCCESS!! delete Kubeconfig done !!! ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
fi
echo -e "\n"

# 7단계: SSH 디렉터리 삭제
echo "[ ${NOW_TIME} ":" Delete User SSH Directory! ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
rm -rf ~/client/${NS}

# 8단계: Private 저장소 (Harbor) 및 프로젝트 삭제
echo "[ ${NOW_TIME} ":" Delete User Private Repository! ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
/home/ehostdev/harbor/harbor-termination.sh ${NS}

# 종료
echo "[ ${NOW_TIME} ":" ##### All Delete Process is Done ##### ]" >> ${LOG_DIR}/${NOW_DATE}_create_kconfig.log 2>&1
echo -e "\n"

exit 0
