#### Pod 배포 시, Private Github Repository 마운트 옵션 추가

### Case 1) git commit 시, 마운트된 볼륨 내용도 자동으로 업데이트(sync)되는 방법
~~~
      containers:  # containers로 생성할 것
      - name: git-sync
        image: k8s.gcr.io/git-sync/git-sync:v3.2.2
        volumeMounts:
        - name: git
          mountPath: /home/git
        env:
        - name: GIT_SYNC_REPO
          value: "https://github.com/YJE888/Cloud.git" #연결할 Git https 주소(URL)
        - name: GIT_SYNC_USERNAME
          value: "YJE888"  # git 사용자(소유자)
        - name: GIT_SYNC_PASSWORD
          value: "ghp_..." # Personal Access Token값 입력. (github settings > Developer Settings > Personal Access Tokens 에서 설정)
        - name: GIT_SYNC_BRANCH
          value: "main" # 가져올 Branch 입력
        - name: GIT_SYNC_ROOT 
          value: /home/git  # github와 싱크맞추는 Pod내 경로
        - name: GIT_SYNC_PERMISSIONS
          value: "0777"
        - name: GIT_SYNC_ONE_TIME # 처음연결후 종료(sync) 여부
          value: "false"
        - name: GIT_SYNC_PERIOD
          value: "10"
        securityContext:
          runAsUser: 0
     volumes:
      - name: git
        emptyDir: {}
~~~
### Case 2) 처음 git 마운트 후, 원본 git과 sync 제거, 업데이트 되지 않음(1회성)
~~~
      initContainers:  # initContainers로 생성할 것
      - name: git-sync
        image: k8s.gcr.io/git-sync/git-sync:v3.2.2
        volumeMounts:
        - name: git
          mountPath: /home/git
        env:
        - name: GIT_SYNC_REPO
          value: "https://github.com/YJE888/Cloud.git" #연결할 Git https 주소(url)
        - name: GIT_SYNC_USERNAME
          value: "YJE888"  # git 사용자(소유자)
        - name: GIT_SYNC_PASSWORD
          value: "ghp_..." # Personal Access Token값 입력. (github settings > Developer Settings > Personal Access Tokens 에서 설정)
        - name: GIT_SYNC_BRANCH
          value: "main" # 가져올 Branch 입력
        - name: GIT_SYNC_ROOT 
          value: /home/git  # github와 싱크맞추는 Pod내 경로
        - name: GIT_SYNC_PERMISSIONS
          value: "0777"
        - name: GIT_SYNC_ONE_TIME # 처음연결후 종료(sync) 여부
          value: "true"
        securityContext:
          runAsUser: 0
     volumes:
      - name: git
        emptyDir: {}
~~~

### Pod 배포 시, Public Github Repository 마운트 옵션 추가
~~~
      initContainers:
      - name: git-cloner
        image: alpine/git
        args:
          - clone
          - --single-branch
          - --
          - https://github.com/kubernetes/git-sync.git
          - /home/git
        volumeMounts:
        - name: git
          mountPath: /home/git
        securityContext:
          runAsUser: 0
      imagePullSecrets:
      - name: ehost-repo.xyz
      volumes:
      - name: git
        emptyDir: {}
~~~
