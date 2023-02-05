#!/bin/bash
NS=$1
for node in `cat node.txt`
do
    ssh root@${node} "sh /root/repo/node_img_delete.sh ${NS};exit;"
done
#회원 탈퇴 시, 사용자가 사용한 개인이미지를 전체 노드에서 삭제
exit 0
