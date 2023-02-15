#!/bin/bash

echo "##### DELETE of Setup kubeconfig! #####"
NS=$1
TOKEN=$(awk '/^CLUSTER/{print $3}' ${CONFIG_FILE})
APISERVER=$(kubectl cluster-info | grep "Kubernetes" | awk -F ' ' '{print $7}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

if ([ $# == 0 ]) || ([ $# -eq 1 ] && [ "$1" == "-h" -o "$1" == "--help" ]); then
  echo "setup-config <NAMESPACE>"
  echo " NAMESPACE: namespace. 필수값임"
  exit 2
fi

echo "[ Switch current-context ]============================================"
chk=`kubectl config current-context | grep kubernetes-admin@kubernetes`
if [ $? == 1 ]; then
  kubectl config use-context kubernetes-admin@kubernetes
else
  echo "kubernetes-admin@kubernetes is the current-context."
fi
echo -e "\n"

echo "[ Delete role ]======================================================="
chk=`kubectl get role | grep ro-sa-${NS}`
if [ $? == 1 ]; then
  echo "role ro-sa-${NS} already delete"
else
  kubectl delete role ro-sa-${NS}
fi
echo -e "\n"

echo "[ Delete rolebinding clusterrolebinding ]================================================"
chk=`kubectl get rolebinding | grep rb-sa-${NS}`
if [ $? == 1 ]; then
  echo "Rolebinding rb-sa-${NS} already delete"
else
  kubectl delete rolebindings -n ${NS} rb-sa-${NS}
fi
echo -e "\n"

chk=`kubectl get clusterrolebinding | grep crb-downward-sa-${NS}`
if [ $? == 1 ]; then
  echo "Rolebinding crb-downward-sa-${NS} already delete"
else
  kubectl delete rolebindings -n ${NS} crb-downward-sa-${NS}
fi
echo -e "\n"

echo "[ Delete serviceaccount ]============================================="
chk=`kubectl get sa -n ${NS}  | grep sa-${NS}`
if [ $? == 1 ]; then
  echo "sa-${NS} already delete"
else  
  kubectl delete sa -n ${NS} sa-${NS}
fi
echo -e "\n"

chk=`kubectl get sa -n ${NS}  | grep downward-sa`
if [ $? == 1 ]; then
  echo "downward-sa already delete"
else  
  kubectl delete sa -n ${NS} downward-sa
fi
echo -e "\n"

echo "[ Delete namespace ]=================================================="
chk=`kubectl get ns | grep ${NS}`
if [ $? == 1 ]; then
  echo "${NS} already delete"
else 
  kubectl delete ns ${NS}&
  echo "${NS} is deleting" && sleep 5
  chk=`kubectl get ns ${NS} -o jsonpath='{.status.phase}'`
    if [ $chk == Terminating ]; then
      kubectl get namespace ${NS} -o json | jq '.spec = {"finalizers":[]}' > /home/ehostdev/temp/${NS}-temp.json
      echo "making temp.json is done"
      curl -k -X PUT --insecure "${APISERVER}/api/v1/namespaces/${NS}/finalize" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      --data-binary @/home/ehostdev/temp/${NS}-temp.json
      rm -rf /home/ehostdev/temp/${NS}-temp.json
      echo "deleting temp.json is done"
    else
      echo "${NS} is deleted"
    fi
fi
echo -e "\n"


# /root/.kube/config 파일에서 sa-${NS} 내용 삭제
echo "[ Delete user ]======================================================="
chk=`kubectl config view | grep sa-${NS}`
if [ $? == 1 ]; then
  echo "sa-${NS} already delete"
else
  kubectl config unset users.sa-${NS}
fi
echo -e "\n"

# /root/.kube/config 파일에서 ${NS} context 내용 삭제
echo "[ Delete context ]===================================================="
chk=`kubectl config view | grep ${NS}`
if [ $? == 1 ]; then
  echo "${NS} context already delete"
else
  kubectl config delete-context ${NS}
fi

# # /root/.kube/${NS}.config 파일 삭제
cd /home/ehostdev/.kube
rm -f ${NS}.config


#삭제확인
ls /home/ehostdev/.kube/${NS}.config > /dev/null 2>&1
if [ $? == 0 ]; then
  echo "Fail to delete kubeconfig !!!"
else
  echo "SUCCESS to delete kubeconfig !!!"
fi
echo -e "\n"

# Delete ssh directory
rm -rf ~/client/${NS}

# Delete volume Directory
#ssh root@nfs "cd /ext-volume && rm -rf ${NS};exit;"

/home/ehostdev/harbor/harbor-termination.sh ${NS}

exit 0
