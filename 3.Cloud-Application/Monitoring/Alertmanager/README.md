## Alert-Manager 설정 및 Slack 연동
### 전제 조건
- prometheus 설치가 선행되어야됨
### 설치법

- prometheus configmap 에 alertmanager 관련 설정 추가
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
