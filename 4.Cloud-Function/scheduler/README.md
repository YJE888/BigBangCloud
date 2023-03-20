### *완료된 job 삭제 시간 1일 후 자동으로 정리됨 (24시간 - 86400초)*
### *push gateway의 메트릭 로그도 같이 삭제되도록 맞춰줄 것(24시간)*
##### 현재 push gateway는 사용하지 않음
```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-with-ttl
spec:
  ttlSecondsAfterFinished: 86400 
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```
