## Elasticsearch, Fluentd, Kibana 설치
##### *Elasticsearch 와 kibana는 같은 버전으로 설치*
### Elasticsearch 설치
1) 저장소 추가 및 차트 다운로드
  ```
  helm repo add elastic https://helm.elastic.co
  helm repo update
  # 특정 버전 설치 시 --version 옵션 사용
  helm pull elastic/elasticsearch (--version 7.9.3)
  tar xvfz elasticsearch-8.5.1.tgz
  cd elasticsearch
  ```
2) value.yaml 파일 수정
  ```
  cp values.yaml my-values.yaml
  vi my-values.yaml
  ...
  # 스토리지 클래스 추가
  volumeClaimTemplate:
  storageClassName: "csi-cephfs-sc"
  ...
  
  # initialDelaySeconds 추가
  readinessProbe:
  failureThreshold: 3
  #initialDelaySeconds: 10
  initialDelaySeconds: 200
  ...
 
 # 상황에 맞게 tolerations 추가
  ```
3) 배포 및 상태 확인
  ```
  helm install elasticsearch -f my-values.yaml . -n monitoring
  curl http://{elastic-ip:port}/_cluster/health?pretty  
  ```

### Fluentd 설치
1) 저장소 추가 및 차트 다운로드
  ```
  helm repo add fluent https://fluent.github.io/helm-charts
  helm repo update
  helm pull fluent/fluentd
  tar xvfz fluentd-0.3.9.tgz
  cd fluentd
  ```
2) value.yaml 파일 수정
  ```
  cp values.yaml my-values.yaml
  vi my-values.yaml
  ...
  
  # 상황에 맞게 tolerations 추가
  ...
  
  ```
3) 배포
  ```
  helm install fluentd -f my-values.yaml . -n monitoring
  ```
### Kibana 설치
1) 차트 다운로드
  ```
  helm pull elastic/kibana
  tar xfzv kibana-8.5.1.tgz
  cd kibana
  ```
2) value.yaml 파일 수정
```
cp values.yaml my-values.yaml
vi my-values.yaml
elasticsearchHosts: "http://elasticsearch-master:9200"
...
serverHost: "0.0.0.0"
healthCheckPath: "/api/status"
kibanaConfig:
   kibana.yml: |
     elasticsearch.hosts: ["http://{elasticsearch-master or elasticsearch-svc-ip}:9200"]
     server.name: kibana
     server.host: "0"
     elasticsearch.requestTimeout: 180000
...
```

#### kibana 설치 시 index 리소스가 존재한다는 에러 발생 시 하단의 명령어로 기존 인덱스 삭제 후 kibana 재시작
```
curl -XDELETE http://{elasticsearch-master or elasticsearch-svc-ip}:9200/.kibana_1
```
