## 1.Ansible-ClusterSetting
참고 (https://github.com/chhanz/k8s-preinstall-ansible-playbook.git)

1) Ansible 설치 및 설정
- 필요한 패키지 설치
  ```
  yum install -y epel-release \
  ansible \
  net-tools \
  git
  ```
- 설정 코드 동기화 및 Inventory(노드정보) 파일 수정
  ```
  git clone https://github.com/YJE888/BigBangCloud.git
  cd 
  vi inventory
  ```
