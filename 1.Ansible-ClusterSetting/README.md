## 1.Ansible-ClusterSetting
참고 (https://github.com/chhanz/k8s-preinstall-ansible-playbook.git)

### 1) Ansible 설치 및 설정
*필요한 패키지 설치*
```
yum install -y epel-release \
ansible \
net-tools \
git
```
&nbsp;
  
*설정 코드 동기화 및 Inventory(노드정보) 파일 수정*<br />
  - inventory 파일에 호스트 정보 기입
```
git clone https://github.com/YJE888/BigBangCloud.git
cd
vi inventory
```
&nbsp;
  
*file 내용 수정*
  - /etc/hosts 에 들어갈 파일 수정
  - /etc/docker/daemon.json 파일 수정
```
vi files/hosts
vi files/daemon.json
```
&nbsp;

### 2) SSH Key 생성 및 배포
*키 생성 후 모든 노드에 키 배포*
```
ssh-keygen \
ssh-copy-id root@{IP}
```
&nbsp;

### 3) Ansible-Playbook 실행
```
ansible-playbook -i inventory non-gpu-preinstall.yaml
```
*Ansible Fingerprint 접속 오류 발생 시 환경변수 지정하여 해결*
```
"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."

export ANSIBLE_HOST_KEY_CHECKTING=False
```
&nbsp;

### 4) GPU Driver 설치 Ansible-Playbook 관련
참고 (https://galaxy.ansible.com/nvidia/nvidia_driver)
*ansible-galaxy 를 사용하여 다운로드*
```
ansible-galaxy install nvidia.nvida_driver
```
&nbsp;
*설치된 경로로 이동 후 인벤토리 수정*
```
vi /root/.ansible/roles/nvidia.nvida_driver/tests/inventory
[gpu]
gpu ansible_hosts={IP}

[gpu:vars]
ansible_ssh_user={ID}
ansible_ssh_pass={PASSWORD}
```

&nbsp;
*playbook 실행 및 GPU Driver 설치*
```
cd /root/.ansible/roles/nvidia.nvidia_driver/
ansible-playbook -i tests/inventory.yml tests/playbook.yml

# GPU Driver 설치 후, ansible-playbook으로 gpu-preinstall.yaml을 실행하여 nvidia-docker2, daemon.json 재설정
ansible-playbook -i inventory gpu-preinstall.yaml
```
&nbsp;
### 5) CEPH Preinstall 실행
*CEPH Cluster를 구성할 노드들의 inventory, hosts 파일 수정*</br>
  - ceph 디렉토리의 inventory, hosts 파일에 ceph 클러스터의 ip, hosts명에 맞게 정보 수정</br>

&nbsp;
*ansible-playbook 실행*
```
cd ceph
ansible-playbook -i inventory ceph-preinstall.yaml
```



