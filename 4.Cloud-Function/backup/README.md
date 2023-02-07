## /home 디렉토리와 etcd 백업
### 전제 조건
- 각 노드들(worker, gpu)에 NFS /backup-volume 에 마운트 필요함(해당 경로에 백업 파일들이 쌓이게 됨)
- Master 노드의 /root/backup/home_backup/m_home_backup.sh 경로에 위치
- Worker 노드의 /root/backup/home_backup/w_home_backup.sh 경로에 위치

#### Master 노드) 클러스터 운영/관리와 관련된 신규 NS가 추가 될 경우, `m_home_backup.sh` 중 아래 명령어 부분에 추가된 NS명 내용 추가
```
kubectl get ns --no-headers | awk '{print $1}' | grep -v "^admin$" | grep -v "^ceph-csi$" | grep -v "^cert-manager$" | grep -v "^default$" | grep -v "^ingress-nginx$" | grep -v "^kube-node-lease$" | grep -v "^kube-public$" | grep -v "^kube-system$" | grep -v "^metallb-system$" | grep -v "^monitoring$" | grep -v "^origin-ca-issuer$" | grep -v "^dcgm-exporter$" > ns.txt
```

#### Master 노드) 사용자 컨테이너의 /home backup 용도의 Crontab 설정
```
0 */6 * * * /root/script/home_backup.sh > /root/script/backup.sh.log 2>&1
```

#### Master 노드) etcd 백업을 위한 전제조건 및 Crontab 설정
- *etcdctl 설치 필요*
```
15 15 * * * /root/script/etcd/etcd_backup.sh >> /root/script/etcd/etcd.sh.log 2>&1
```
