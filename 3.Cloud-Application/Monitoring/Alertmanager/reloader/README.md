## Reloader(option)
#### 참고 : (https://github.com/stakater/Reloader.git)

#### 1) 사용 이유
- Deployment에 마운트 되어 있는 `Secret`이나 `Configmap`이 변경되었을 경우 Deployment 자동으로 재시작하여 설정 적용
- 컨피그맵 수정 후 수동으로 Deployment를 롤아웃 할거면 설치하지 않아도 됨

#### 2) 설치
- 필요한 경우 `Namespace` 변경 후 설치
```
kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml
```

#### 3) 사용법
- secret, configmap이 마운트 된 Deployment의 `metadata.annotations`에 아래의 값을 적절하게 추가
  - `reloader.stakater.com/auto: "true"` -> secret과 configmap 변경 시 Deployment 자동으로 재시작
  - `reloader.stakater.com/search: "true"` -> Deployment의 컨피그맵, 시크릿 중 `reloader.stakater.com/match: "true"` 값이 있는 오브젝트 변경 시 Deployment 자동으로 재시작
  - `{configmap 또는 secret}.reloader.stakater.com/reload: "test"` -> test라는 이름을 가진 configmap 또는 secret을 변경 시 Deployment 자동으로 재시작
- prometheus deployment에 annotation 추가
```
$ kubectl edit deployment -n monitoring prometheus
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "6"
    reloader.stakater.com/auto: "true" ## 추가하여 적용!!
  name: prometheus-deployment
...
```
- Deployment에 마운트 되어 있는 configmap 변경 후 업데이트 여부 확인
