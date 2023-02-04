#!/bin/bash              
if [ $1 = "-h" ] || [ $1 = "--help" ]
then                     
        echo -e "Usage : ./check-upload.sh {NS} {VOLUME} {FILE} {SIZE}"
        exit 2           
fi                       
                         
NS=$1                     
VOL=$2                   
FILE=$3                   
SIZE=$4                   
PNAME=$(kubectl get pods -n ${NS} | grep -w ${VOL} | cut -d " " -f 1)
                         
chk=`kubectl exec -n ${NS} ${PNAME} -- ls /data/upload/${FILE} > /dev/null 2>&1`
if [ $? == 0 ]            
    then                  
        amount=`kubectl exec -n ${NS} ${PNAME} -- du -b /data/upload/${FILE} | awk '{print $1}'`
        if [ ${amount} == $4 ]
            then          
                echo "${FILE} file upload complete"                                                 
            else         
                while [ ${amount} != $4 ]                         
                do       
                  amount=`kubectl exec -n ${NS} ${PNAME} -- du -b /data/upload/${FILE} | awk '{print $1}'`
                  echo "${FILE} download in progress"
                  sleep 3
                done      
                echo "${FILE} file upload complete"
        fi                
    else                  
            echo "${FILE} file doesn't exist"                     
            exit 1        
fi                        
                         
kubectl exec -n ${NS} ${PNAME} -- rm -rf /ext-volume/${FILE}
                          
exit 0
