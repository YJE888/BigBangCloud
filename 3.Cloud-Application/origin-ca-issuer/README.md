### 전제 조건
1) cert-manger 1.0이상 설치필요
2) k8s클러스터 1.16이상 필요

### git 다운로드
```
git clone https://github.com/cloudflare/origin-ca-issuer.git
```

### crd 설치
```
kubectl apply -f deploy/crds
```

### rbac 설치
```
kubectl apply -f deploy/rbac
```

### manifests 설치
```
kubectl apply -f deploy/manifests
```

### sercret 생성 (cloudflare api를 통해 접근하기 위해)
- 키는 Cloudflare 대시보드의 API 토큰 섹션으로 이동하여 "Origin CA Key" API 키를 보면 찾을 수 있다. 이 키는 "v1.0-"으로 시작하며 일반 API 키와 다름.
```
kubectl create secret generic \
    --dry-run \
    -n default service-key \
    --from-literal key=v1.0-FFFFFFF-FFFFFFFF -oyaml
```

### OriginIssuer yaml 작성
```
apiVersion: cert-manager.k8s.cloudflare.com/v1
kind: OriginIssuer
metadata:
  name: prod-issuer
  namespace: default
spec:
  requestType: OriginECC
  auth:
    serviceKeyRef:
      name: service-key
      key: key
```

### OriginIssuer와 Servicekey 배포
```
kubectl apply -f service-key.yaml -f issuer.yaml
```
