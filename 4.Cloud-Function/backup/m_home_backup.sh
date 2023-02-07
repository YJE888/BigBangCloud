# 마스터 노드에 위치해야됨
#!/bin/bash
#ns 리스트 생성
kubectl get ns --no-headers | awk '{print $1}' | grep -v "^admin$" | grep -v "^ceph-csi$" | grep -v "^cert-manager$" | grep -v "^default$" | grep -v "^ingress-nginx$" | grep -v "^kube-node-lease$" | grep -v "^kube-public$" | grep -v "^kube-system$" | grep -v "^metallb-system$" | grep -v "^monitoring$" | grep -v "^origin-ca-issuer$" | grep -v "^dcgm-exporter$" > ns.txt
for NS in `cat ns.txt`
do
    kubectl get deployments.apps -n $NS --no-headers | awk '{print $1}' | grep -v "\-upload" > pod.txt
    for DEPLOYMENT in `cat pod.txt`
    do
        PNAME=$(kubectl get pod -n ${NS} | grep -w ${DEPLOYMENT} | cut -d " " -f 1)
        NODE=$(kubectl get pods ${PNAME} -n ${NS} -o jsonpath={.spec.nodeName})
        CID=$(kubectl describe pod ${PNAME} -n ${NS} | grep "Container ID" | rev | cut -c -64 | rev)
        ssh root@${NODE} "sh /root/script/w_backup.sh ${NS} ${PNAME} ${CID};exit;"
    done
done
# 상단에서 생성됐던 파일 삭제
rm -rf /root/script/ns.txt
rm -rf /root/script/pod.txt

exit 0
