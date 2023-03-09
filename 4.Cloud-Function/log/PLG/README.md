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
```
3. 배포 및 상태 확인
```
helm install promtail -f my-values.yaml . -n monitoring
```

