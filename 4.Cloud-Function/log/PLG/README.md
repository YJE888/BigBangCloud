###### pod가 종료되면 로그 조회가 불가능해짐
###### 로그의 용량이 10Mi를 초과(kubelet 설정)하면 전체 로그 조회가 불가능해짐

## Promtail, Loki, Grafana 설치

### Loki 설치
*loki 설치 간 nfs를 사용하므로 provisioner 설치가 필요함*
1. 저장소 추가 및 차트 다운로드
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm pull grafana/loki
tar xvfz loki-4.6.1.tgz
cd loki
```
2. value.yaml 파일 수정
```
cp values.yaml my-values.yaml
vi my-values.yaml
...
config:
  table_manager:
    retention_deletes_enabled: true 
    retention_period: 336h
...
persistence:
  enabled: true
  accessModes:
  - ReadWriteOnce
  size: 60Gi
  storageClassName: "nfs-client"
...
```
3. 배포 및 상태 확인
```
helm install loki -f my-values.yaml . -n monitoring
kubectl get pods -n monitoring
```
*error* \
prometheus에서 pod up이 되지 않으면서 `caller=tcp_transport.go:318 component="memberlist TCPTransport" msg="unknown message type" msgType=G remote={prometheus-pod IP}` 가 뜨면 아래의 설정 변경
```
loki:
  podAnnotations:
    prometheus.io/port: http-metrics    # 변경 전
    prometheus.io/scrape: true
    ---
    prometheus.io/scrape: "true"        # 변경 후
    prometheus.io/port: "3100"
```
### Promtail 설치
- Promtail은 Loki와 함께 사용할 수 있는 로그 수집기로 Prometheus에서 지원하는 기본 스크래핑 기능과 함께 사용 가능
1. 저장소 추가 및 차트 다운로드
```
helm pull grafana/promtail
tar xvfz promtail-6.8.3.tgz
cd promtail
```
2. value.yaml 파일 수정
```
cp values.yaml my-values.yaml
vi my-values.yaml
...
# 상황에 맞게 tolerations 추가
defaultVolumes:
  - name: run
    hostPath:
      path: /run/promtail
  - name: docker-vol
    hostPath:
      path: /docker-volume/containers
  - name: pods
    hostPath:
      path: /var/log/pods
  - name: docker-default
    hostPath:
      path: /var/lib/docker/containers
 defaultVolumeMounts:
  - name: run
    mountPath: /run/promtail
  - name: docker-vol
    mountPath: /docker-volume/containers
    readOnly: true
  - name: pods
    mountPath: /var/log/pods
    readOnly: true
  - name: docker-default
    mountPath: /var/lib/docker/containers
    readOnly: true
config:
  clients:
    - url: http://loki-headless:3100/loki/api/v1/push     #loki 서비스 이름과 포트입력
```
3. 배포 및 상태 확인
```
helm install promtail -f my-values.yaml . -n monitoring
```

##### Grafana에 데이터 소스 연동 후 로그 확인

