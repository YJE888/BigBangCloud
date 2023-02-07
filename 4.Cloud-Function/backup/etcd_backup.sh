# 오늘의 날짜를 받아서 etcd-{오늘날짜}로 생성됨
#!/bin/bash
today=`date`
echo $today
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /root/script/etcd/etcd-$(date '+%y%m%d')

scp /root/script/etcd/etcd-$(date '+%y%m%d') root@nfs:/backup-volume/etcd-backup
rm -rf /root/script/etcd/etcd-$(date '+%y%m%d')
