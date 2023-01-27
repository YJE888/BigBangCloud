## 특정 Process 숨김
### *컨테이너가 구동되는 모든 노드에 설정 필요*

#### 1) 숨겨야되는 프로세스 명 지정
  - *ex) sleep 명령어 숨김처리 필요*
```
vi processhider.c
static const char* process_to_filter = "sleep";
```

#### 2) 적용
```
cd ~/libprocesshider
make
sudo mv libprocesshider.so /usr/local/lib/
echo /usr/local/lib/libprocesshider.so >> /etc/ld.so.preload
```

#### 3) 확인
  - *pod 배포 후 ps -ef 명령어로 프로세스에 sleep이 있는지 확인*
```
kubectl apply -f ~/example/sample-pod.yaml
kubectl exec {pod명} -- ps -ef
```
