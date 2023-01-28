## CephFS 사용을 위한 Ceph-CSI 배포
### 1) Namespace 배포
```
cd ceph-csi
kubectl create -f ns.yaml
```

### 2) Configmap 배포
  - mon 서버에서 `ceph mon dump`로 fsid, mon 정보 추가
```
kubectl create -f ceph-conf.yaml

vi csi-config-map.yaml
kubectl create -f csi-config-map.yaml
```

### 3) Secret 배포
  - mon 서버에서 `ceph auth get client.admin`으로 admin key 정보 추가
```
vi secret.yaml
kubectl create -f secret.yaml
```

### 4) Storageclass 배포
  - mon 서버에서 `ceph fs ls`로 fsname 정보 추가, `ceph mon dump`로 fsid 정보 추가
```
vi storageclass.yaml
kubectl create -f storageclass.yaml
```

### 5) RBAC 배포
```
kubectl create -f csi-nodeplugin-rbac.yaml
kubectl create -f csi-provisioner-rbac.yaml
```

### 6) Plugin, Provisioner 배포
```
kubectl create -f csi-cephfsplugin.yaml
kubectl create -f csi-cephfsplugin-provisioner.yaml
```

#### Error
  - Ceph-CSI가 제대로 배포되지 않는 경우 Provisioner Deployment에서 `--extra-create-metadata=true`로 
