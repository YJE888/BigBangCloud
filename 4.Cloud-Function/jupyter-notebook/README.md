## Jupyter Notebook, Tensorboard, Jupyter Lab 사용
### Service Domain 정보
```
bigbangcloud-client.co.kr
```

### Service Domain Cname 정보
```
${NS}-${DeployNAME}-jn-bigbangcloud-client.co.kr
${NS}-${DeployNAME}-tb-bigbangcloud-client.co.kr
${NS}-${DeployNAME}-jl-bigbangcloud-client.co.kr
```

### Service Flow
1. 회원가입
- Cert_Install.sh 실행(사용자 NS에 OriginIssuer, Secret 생성)
<br/>

2. 컨테이너 생성
- cname_create.sh 생성(Cloudflare 상 jn, tb, jl 도메인 등록)
- Ingress 생성(Certificate 생성)
<br/>

3. JN/TB/JL 활성 / 비활성
- 서비스 활성화 시 활성화 한 서비스에 맞게 { jl || jn || tb }_cert_confirm.sh 로 각 서비스의 Certificate 확인 후 정상이라면 Service 생성
- 서비스 비활성화 시 Service 제거하여 endpoint 접근 차단
<br/>

4. 컨테이너 삭제
- delete.sh 실행
- K8S : Ingress, Service, Certificate, Deployment 삭제
- Cloudflare : OriginCA, Certificate, DNS Record 삭제
