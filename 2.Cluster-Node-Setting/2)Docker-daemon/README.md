## Docker Data Root 경로 변경 및 사이즈 제한
#### 1) 기존 위치 확인
```
docker info | grep "Docker Root Dir"
```
#### 2) 도커 서비스 중지
```
systemctl stop docker
```

#### 3) Data Root로 사용 할 디렉토리 생성
```
mkdir /Docker-Volume
mkfs.xfs -f /dev/sdb1
mount /dev/sdb1 /Docker-Volume

# 영구 적용
vi /etc/fstab
/dev/sdb1 /Docker-Volume  xfs defaults,pquota	0 0
```

#### 4) Docker의 daemon.json 수정
  - Worker, GPU 노드에서 수정(파일이 없을 경우 새로 생성)</br>
  - `insecure-registries`에 harbor 도메인 입력
  - `data-root`에 3번에서 만든 디렉토리명 입력
  - `overlay2.size`에 컨테이너의 OS영역 용량 지정(사이즈 제한)
  - GPU노드의 경우 `default-runtime`이 nvidia인지 확인
