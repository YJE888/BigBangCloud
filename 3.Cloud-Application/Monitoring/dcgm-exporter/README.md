## dcgm-exporter를 설치하기 위한 전제 조건

#### 하단의 CRD 파일 배포
```
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
```

#### dcgm-exporter는 helm 으로 배포하며, 배포 전에 values 파일을 가져와서 별도의 value 파일을 만들어서 배포(taint, toleration)
```
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts

helm repo update

helm install dcgm-exporter gpu-helm-charts/dcgm-exporter --values /{경로}/values.yaml\
```
