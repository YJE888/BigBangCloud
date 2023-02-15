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

chk=`kubectl get ns | grep group-${NS}`
if [ $? == 1 ]; then
  echo "[ Create namespace group-${NS} ]"
  kubectl create ns group-${NS}
  kubectl label ns group-${NS} kind=group
else
  echo "[ namespace group-${NS} already exists ]"
fi
echo -e "\n"

# Create Private Repo Secret
echo "[ Create private repository secret  ]"
  kubectl create secret -n ${NS} docker-registry bigbangcloud-repo.co.kr --docker-username=admin --docker-password=${PWD} --docker-server=bigbangcloud-repo.co.kr
echo -e "\n"

echo "##### END of setup kubeconfig! #####"\

# Create harbor project
cd /home/ehostdev/harbor/
./create-project.sh group-${NS}

echo "##### END of create Harbor project! #####"\

# Create ssh directroy
mkdir ~/client/group-${NS}

exit 0
