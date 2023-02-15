## 전제조건
0. 현재 old_files의 스크립트로 구성되어있음. (변동 x)
</br>

1. `~/harbor/repo` 경로에 password.txt 파일 만들고 harbor 패스워드 기입
</br>

2. 사용자 (user-role) / 웹서버 (web-clusterrole) yaml 파일 사용
 - 사용자 : NS 제한, 모든 권한 가능
 - 웹서버 : Cluster 전부, 모든 View 가능
</br>

3. 공유 NFS Directory 설정(웹서버, HA Proxy가 공유)
 - log : /ext-volume/kubeconfig/create_kconfig.log ,  /ext-volume/kubeconfig/delete_kconfig.log
 - yaml (role) : /ext-volume/yaml/user-role.yaml
 - script : /ext-volume/script/create_kubeconfig.sh,  /ext-volume/script/delete_kubeconfig.sh
</br>

4. Web/HA Proxy에 inotifywait 설치 및 설정 필요
 - 감시 스크립트 실행(HA Prxoy) : check_userID.sh</br>
   **감시할 디렉터리 : /ext-volume/user-id**
