## Helm 을 사용하여 Prometheus 설치
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus-stack
helm pull prometheus-community/kube-prometheus-stack
tar xvfz kube-prometheus-stack-44.3.0.tgz
```
#### value 파일 복사 후 수정
- 필요에 따라 리소스 제한 필요(requests / limits)
```
cp values.yaml my-values.yaml
vi my-values.yaml
...
defaultRules:
  create: true
  rules:
    alertmanager: true
...
alertmanager:
  enable: true
  ## Configuration for Alertmanager service
  ##
  service:
    ## Service type
    ##
    type: NodePort #LoadBalancer 지정 가능?
## 모니터링 대상 추가 활성화 / 비활성화 가능
## Component scraping the kube api server
##
kubeApiServer:
  enabled: true
  
## Component scraping the kubelet and kubelet-hosted cAdvisor
##
kubelet:
  enabled: true
## Deploy a Prometheus instance
##
prometheus:
  enabled: true
  thanosService:
    enabled: false
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    ## How long to retain metrics
    retention: 10d
    ## Maximum size of metrics
    retentionSize: "10GiB"
    storageSpec:
    ## Using PersistentVolumeClaim
      volumeClaimTemplate:
        spec:
          storageClassName: csi-cephfs-sc
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 15Gi
```
#### chart 디렉토리의 grafana/values.yaml 수정
```
service:
  enabled: true
  type: LoadBalancer
## Enable persistence using Persistent Volume Claims
persistence:
  type: pvc
  enabled: true
  storageClassName: csi-cephfs-sc
  accessModes:
    - ReadWriteOnce
  size: 10Gi
```
#### NS 생성 후 배포
```
kubectl create ns monitoring
helm install prometheus -n monitoring -f my-values.yaml .
```
