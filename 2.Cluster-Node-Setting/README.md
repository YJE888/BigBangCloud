## Kubernetes Cluster-Node-Setting
### 1) Cluster Node 설정
  - 노드에 OS용 디스크를 제외한 추가 디스크가 존재 해야 됨 (추가 디스크는 /Docker-Volume 으로 설정)
  - /Docker-Volume 의 Overlay 부분의 root dir 용량 설정 필요
  - Worker와 GPU의 Docker daemon.json 파일의 형태가 다르므로 주의
  - Volume Deployment가 배포되는 노드에 Taint 및 Label 설정
    - Labels: ex) role=data-transfer
    - Taints : ex) role=data-transfer:NoSchedule
  - GPU노드 Taint 및 Label 설정
    - Labels : ex) role=gpu, gpu=3090
    - Taints : ex) role=gpu:NoSchedule
&nbsp;

### 2) Hide Process
  - 참고 : https://github.com/gianlucaborello/libprocesshider
  - Deployment의 보이지 않아도 될 프로세스 숨기는 용도로 사용
  - 모든 Worker 와 GPU 노드에 배포 및 설치 필요
  - 사전에 설치해야될 패키지 : gcc
&nbsp;

### 3) Ceph-CSI
  - 쿠버네티스 노드에서 Ceph 볼륨을 사용하기 위해 설치

### 4) NFS-Client
  - *NFS Client 패키지 설치*
```
yum -y install nfs-utils libnfsdimap
systemctl enable rpcbind
systemctl start rpcbind
```
&nbsp;

  - *NFS Server의 마운트 포인트 확인*
```
showmount -e {NFS Server IP}
```
&nbsp;

  - *NFS 볼륨 마운트*
```
mkdir -p {NFS에 마운트할 로컬 디렉토리 경로 및 이름 입력}
mount {NFS Server IP}:/{NFS Dir Name} {Local Dir Name}
```
&nbsp;

  - *마운트 확인*
```
mount | grep {Local Dir Name}
```
&nbsp;

  - *마운트 영구 적용을 위한 fstab 설정*
```
vi /etc/fstab
{NFS Server IP}:/{NFS Dir Name} {Local Dir Name} nfs rw,sync,hard,intr 0 0
```

  
