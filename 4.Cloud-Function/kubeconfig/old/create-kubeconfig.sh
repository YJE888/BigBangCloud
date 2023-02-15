#!/bin/bash

echo "##### START of Setup kubeconfig! #####"
CLUSTER=kubernetes
NS=""
PWD=$(cat /home/ehostdev/harbor/repo/password.txt)

# Get parameter
if ([ $# == 0 ]) || ([ $# -eq 1 ] && [ "$1" == "-h" -o "$1" == "--help" ]); then
  echo "setup-config [<CLUSTER>] <NAMESPACE>"
  echo " CLUSTER: cluster명이며 기본값은 kubernetes이며 생략할 수 있음"
  echo " NAMESPACE: namespace. 필수값임"
  exit 2
fi

if [ $# == 1 ]; then
  NS=$1
elif [ $# == 2 ]; then
  CLUSTER=$1
  NS=$2
fi

# check user and create if not

# Switch to kubernetes-admin context
#kubectl config use-context kubernetes-admin@kubernetes

# Create namespace if not exists
chk=`kubectl get ns | grep ${NS}`
if [ $? == 1 ]; then
  echo "[ Create namespace ${NS} ]"
  kubectl create ns ${NS}
else
  echo "[ namespace ${NS} already exists ]"
fi
echo -e "\n"

# Create service account if not exists
chk=`kubectl get sa -n ${NS} | grep sa-${NS}`
if [ $? == 1 ]; then
  echo "[ Create serviceaccount sa-${NS} ]"
  kubectl create sa sa-${NS} -n ${NS}

else
  echo "[ serviceaccount sa-${NS} already exists in ${NS} ]"
fi
echo -e "\n"

# Create view service account if not exists (for downward API)

chk=`kubectl get sa -n ${NS} | grep downward-sa`
if [ $? == 1 ]; then
  echo "[ Create serviceaccount downward-sa ]"
  kubectl create sa downward-sa -n ${NS}

else
  echo "[ serviceaccount downward-sa already exists in ${NS} ]"
fi
echo -e "\n"

# Create role 
chk=`kubectl get role -n ${NS} | grep ro-sa-${NS}`
if [ $? == 1 ]; then
  echo "[ Create role ro-sa-${NS} ]"
  kubectl create role ro-sa-${NS} --verb=get --verb=list --verb=watch --resource=pods -n ${NS}
else
  echo "[ role ro-sa-${NS} already exists ]"
fi
echo -e "\n"

# Create rolebinding: admin role for sa to created namespace
chk=`kubectl get rolebinding -n ${NS} | grep rb-sa-${NS}`
if [ $? == 1 ]; then
  echo "[ Create rolebinding rb-sa-${NS} ]"
  kubectl create rolebinding rb-sa-${NS} --clusterrole=admin --serviceaccount=${NS}:sa-${NS} -n ${NS}
else
  echo "[ rolebinding rb-sa-${NS} already exists ]"
fi
echo -e "\n"

# Create rolebinding: view clusterrole for sa to client's namespace (for downward API)
chk=`kubectl get clusterrolebinding -n ${NS} | grep crb-downward-sa-${NS}`
if [ $? == 1 ]; then
  echo "[ Create clusterrolebinding crb-downward-sa-${NS} ]"
  kubectl create clusterrolebinding crb-downward-sa-${NS} --clusterrole=view --serviceaccount=${NS}:downward-sa -n ${NS}
else
  echo "[ clusterrolebinding crb-downward-sa-${NS} already exists ]"
fi

# Get token of the serviceaccount
secret=`kubectl get secret -n ${NS} | grep sa-${NS} | cut -d " " -f1`
TOKEN=`kubectl describe secret ${secret} -n ${NS} | grep token: | cut -d ":" -f2 | tr -d " "`

# Cluster info
echo "[ Create cluster info in kubeconfig ]"
  kubectl config set-cluster ${CLUSTER} --server=https://103.212.223.200:6443 --insecure-skip-tls-verify --kubeconfig=/home/ehostdev/.kube/${NS}.config
echo -e "\n"

# Create user
chk=`kubectl config view | grep "name: sa-{NS}"`
if [ $? == 1 ]; then
  echo "[ Create user sa-${NS} in kubeconfig ]"
  kubectl config set-credentials sa-${NS} --token=${TOKEN}
  kubectl config set-credentials sa-${NS} --token=${TOKEN} --kubeconfig /home/ehostdev/.kube/${NS}.config
else
  echo "[ User sa-${NS} already exists in kubeconfig ]"
fi
echo -e "\n"

# Create context
chk=`kubectl config view | grep "name: ${NS}"`
if [ $? == 1 ]; then
  echo "[ Create context ${NS} ]"
  kubectl config set-context ${NS} --user=sa-${NS} --cluster=${CLUSTER} --namespace=${NS}
  kubectl config set-context ${NS} --user=sa-${NS} --cluster=${CLUSTER} --namespace=${NS} --kubeconfig /home/ehostdev/.kube/${NS}.config
else
  echo "[ Context ${NS} already exists in kubeconfig ]"
fi
echo -e "\n"

# Current-context info
echo "[ Create current-context info in kubeconfig ]"
  kubectl config set-context ${NS} --cluster=${CLUSTER} --namespace=${NS} --user=sa-${NS} --kubeconfig=/root/.kube/${NS}.config
  kubectl config use-context ${NS} --kubeconfig=/home/ehostdev/.kube/${NS}.config
echo -e "\n"

# Create Private Repo Secret
echo "[ Create private repository secret  ]"
  kubectl create secret -n ${NS} docker-registry ehost-repo.xyz --docker-username=admin --docker-password=${PWD} --docker-server=ehost-repo.xyz
echo -e "\n"

# Test
current=`kubectl config current-context`
#kubectl config use-context ${NS}
kubectl get all -n ${NS}
if [ $? == 0 ]; then
  echo "SUCCESS to setup kubeconfig !!!"
else
  echo "FAIL to setup kubeconfig !!!"
fi
echo -e "\n"

echo "##### END of setup kubeconfig! #####"\

# Create harbor project
cd /home/ehostdev/harbor/
./create-project.sh ${NS}

echo "##### END of create Harbor project! #####"\

# Create ssh directroy
mkdir ~/client/${NS}

#Create Volume Directory
ssh root@nfs "mkdir /ext-volume/${NS};chmod 777 /ext-volume/${NS};exit;"

echo "##### END of create NFS volume directory! #####"\

exit 0
