### 전제조건
1) GPU 노드에 Nvidia-Driver 가 설치되어 있어야됨
2) GPU 노드에 Nvidia-Docker2 가 설치되어 있어야됨
3) Kubelet의 Runtime은 Docker를 사용함
4) Docker는 Runc 대신 Nvidia-Container-Runtime을 기본 Runtime으로 설정되어 있어야됨 (daemon.json 설정 변경 필요)
5) Nvidia Driver 버전은 384.81보다 크거나 같은 것

#### Master Node에서 Git 복제
```
git clone https://github.com/NVIDIA/k8s-device-plugin.git
```

#### Master Node에서 배포
```
kubectl apply -f nvidia-device-plugin.yml
```
