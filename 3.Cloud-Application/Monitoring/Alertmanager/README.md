## Alert-Manager 설정 및 Slack 연동
### 1) 전제 조건
- prometheus 설치가 선행되어야됨
- slack 가입 후 알람을 받을 워크스페이스 생성
  - 테스트 환경 : 워크스페이스(k8s-alert), 채널(#alert-manager)
  - 웹훅 URL : 채널(#alert-manager)우클릭 > 채널 세부정보 보기 > 통합 > 앱-앱추가 > webhook 검색 - incoming-webhook 설치 > Slack에 추가 > 채널 선택 > **웹후크 URL 획득!**
### 2) 설치법
- *alert-manager configmap 생성*
  - 파일 내부에서 웹훅 URL 추가 
```
kubectl apply -f alert-cm.yaml
```
- *alert-manager Deployment, Service 생성*
```
kubectl apply -f alert-deploy.yaml
kubectl apply -f alert-svc.yaml
```
- *alert-manager 쿠버네티스 관련 규칙 configmap 생성*
  - 참고: (https://awesome-prometheus-alerts.grep.to/)
```
kubectl apply -f alert-rules.yaml
```
- *prometheus configmap 에 alertmanager 관련 설정 추가*
```
$ kubectl edit
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server-conf
...
data
  prometheus.yml: | -
    global:
    ...
    alerting:
      alertmanagers:
      - scheme: http
        static_configs:
        - targets: ['{alertmanager-svc-IP}:9093']
    rule_files:
      - "/prometheus/rules/*.yaml" # rule을 정의한 파일 configmap으로 생성 후 마운트
```
- *prometheus deployment에 alert-manager 규칙 configmap 설정 추가*
```
$ kubectl edit deployment -n monitoring prometheus-deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "6"
    reloader.stakater.com/auto: "true"              #reloader 사용하는 경우 추가
  name: prometheus-deployment
  namespace: monitoring
spec:
  ...
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: prometheus-server
    spec:
      containers:
      - args:
        ...
        name: prometheus
        ports:
        - containerPort: 9090
          protocol: TCP
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/prometheus/
          name: prometheus-config-volume
        - mountPath: /prometheus/
          name: prometheus-storage-volume
        - mountPath: /prometheus/rules/           #alert-rule 추가
          name: alert-rule-cm
      dnsPolicy: ClusterFirst
      initContainers:
      - name: prometheus-data-permission-fix
        ...
      volumes:
      - configMap:                                #alert-rule 추가
          name: alert-rule
        name: alert-rule-cm
      - configMap:
          name: prometheus-server-conf
        name: prometheus-config-volume
      - name: prometheus-storage-volume
        nfs:
          path: /monitoring-volume/prometheus
          server: 10.10.10.69
```
