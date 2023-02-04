## Cloud-Function
### 1) Jupyter Notebook / Tensorboard
- 조건 1 : Web 서버에 스크립트 배치
- 조건 2 : Web 서버에 cloudflare-dns-main 폴더 배포
- 조건 3 : Web 서버에 python3 & jq 설치 필요
- 참고파일 : harbor/config.ini

##### 1. Cert_Install.sh
- 인증서 생성을 위한 스크립트 (사용자 NS내 Issuer / Secret 배포)
##### 2. Cname_Create.sh
- 도메인의 CNAME 생성 및 DNS Record 등록
##### 3. Cert_Confirm.sh
- Ingress, SVC 배포 시, 발생하는 tls 요청으로 인한 인증서 생성/상태 확인
##### 4. Delete.sh
- 서비스 삭제 시, 삭제 스크립트

### 2) Kubeconfig
- 웹서버에서 공유디렉터리 (/ext-volume/user-info)에 파일 생성/삭제 동작 
- HA Proxy에서 파일시스템의 변화 감지 후, admin권한 config로 sa, role, rolebinding, config 생성.
- 공유 디렉터리의 사용자 kubeconfig를 사용하여 사용자 NS 내부 리소스 관리

* create_kubeconfig.sh (생성)
* delete_kubeconfig.sh (삭제)

### 3) Private Repository(Harbor)
조건 : harbor구성, 인증설정, docker daemon.json 설정, harbor password 설정(my_password.txt)
참조파일 : harbor/config.ini (=고유값,ID/PW 등 포함), my_password.txt

1. create-project.sh
- 프로젝트 생성(=NS), 사용자 고유 공간
2. push.sh
- 사용자 이미지 태그변경, harbor에 image push
3. img-delete.sh
- 사용자 프로젝트 내부 이미지 삭제
4. harbor-termination.sh
- 사용자저장소삭제(=탈퇴)
5. daemon.json 파일에 내용 추가
  "insecure-registries": ["{harbor-address or domain"]
6. pause.sh
- 컨테이너 일시정지. 사용중인컨테이너 이미지를 저장

### 4) GPU 모니터링 리소스 수집(Deprecated)
배포 위치 : (각 GPU노드) mkdir -p /etc/monitoring
배포 파일 : gpu_metrics_exporter, main_process_check
조건 : 서비스 컨테이너 이미지에 python3, nvidia-ml-py, prometheus_client 설치
1. gpu_metrics_exporter
- 참조: https://github.com/ajeetraina/nvidia-prometheus-stats
- python2버전을 python3에 맞게 코드변경함.  GPU메트릭 발생
2. main_process_check
- 메인컨테이너 체크하여 메인컨테이너 종료 시, 메트릭수집 컨테이너도 종료하도록 지시

### 5) 회원탈퇴 관련
- 각 워커/GPU노드에 사용자가 생성하고 다운로드한 컨테이너 이미지 삭제 필요
- 수행 스크립트 경로: (WebServ) /ehostdev/home/harbor/repo
- 신규 워커노드/GPU노드 추가 시, 웹서버 /ehostdev/home/harbor/repo/node.txt 수정필요
- 신규 워커노드/GPU노드 추가 시, 워커노드 /root/repo/node_img_delete.sh 파일 추가필요
