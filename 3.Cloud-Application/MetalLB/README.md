#### IPVS 모드의 kube-proxy를 사용할 경우, strictARP mode를 활성화 시켜줘야 됨
#### 만약, kube-router(서비스 프록시)를 사용할 경우 기본적으로 활성화 되어있음

### IPVS 모드 변경
```
kubectl edit configmap -n kube-system kube-proxy
...
ipvs:
  strictARP: true
...
```

#### calico & MetalLB BGP 동시 사용 테스트 결과 구 버전(0.9.6)에서는 동작 확인 완료(최신버전에서 사용 불가능)

### 동작 조건
```
calico bgp peer 연결 (BGPPeer.yaml)
calico bgp configuration (BGPConfiguration.yaml)
```
MetalLB는 Speaker 배포 필요없음</br>
LoadBalancer IP를 할당해주는 Controller만 필요함

### Error
  - MetalLB-Controller log에 rbac 관련 에러가 뜨면 ClusterRole에 Configmap 관련 내용 추가 할 것
