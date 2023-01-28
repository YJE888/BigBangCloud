## Cloud-Application
#### k8s 클러스터 내 필요한 어플리케이션 설치
### 1) MetalLB
  - 로드밸런서를 통해 Public IP 를 External IP로 로 할당(Mode : L2 또는 BGP)
&nbsp;

### 2) nvidia-plugin
  - nvidia gpu를 사용 가능하도록 plug-in 배포
&nbsp;

### 3) nginx-ingress
  - URL(+SSL) - Jupyter notebook, Jupyter Lab, Tensor Board 서비스 접속 시 사용
&nbsp;

### 4) Helm
  - 필요 시 사용
&nbsp;

### 5) Monitoring / Prometheus / Grafana
  - 모니터링 메트릭 수집기(대시보드 포함)
  - 전제 조건 : NFS Server & CephFS 설치 / CSI 설치 필수
&nbsp;

### 6) Monitoring / Push-gateway
  - Push 방식 메트릭 수집용 Proxy
&nbsp;

### 7) Cert-Manager
  - 인증서 생성 및 관리
&nbsp;

### 8) Origin-CA-Issuer
  - 인증서 Sign, Issuer(발급자) 사용
&nbsp;

### 9) Ceph-CSI
  - CephFS 를 사용하기 위해 K8S와의 연동
&nbsp;
