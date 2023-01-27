## Calico Node 구성
### Calicoctl 설치
```
curl -L https://github.com/projectcalico/calico/releases/download/v3.25.0/calicoctl-linux-amd64 -o calicoctl
chmod +x ./calicoctl
```
### 1. calico 설치(50노드 이하)
  - *POD CIDR을 default (192.168.0.0/16)를 사용하면 수정하지 않아도 됨*
  - *Auto-detect the BGP IP address key, value 추가*
```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
vi calico.yaml
# Auto-detect the BGP IP address.
- name: IP
  value: "autodetect"
- name: IP_AUTODETECTION_METHOD
  value: "cidr={IP}/{BIT}"
```
### 2. BGPConfiguration.yaml 배포
  - *serviceClusterIPs 확인 및 ExternalIP, LBIP 기입*
  - `cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range`
```
vi BGPConfiguration.yaml
kubectl apply -f BGPConfiguration.yaml
```
### 3. Global BGP Peer 설정
  - *BGPPeer.yaml 에서 peerIP 수정*
```
vi BGPPeer.yaml
kubectl apply -f BGPPeer.yaml
```
