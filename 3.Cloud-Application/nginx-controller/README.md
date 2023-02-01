#### nginx-ingress svc 부분 수정 필요함
```
type: LoadBalancer
loadBalancerIP: {할당해야될 LB IP 입력}
externalTrafficPolicy: Local
```

#### helm 을 사용하여 nginx-controller 설치
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo list
helm repo update
kubectl create ns ingress-nginx
helm search repo ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
```
