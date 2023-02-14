#!/bin/bash
NS=$1
PNAME=$2
JUPYTER=${NS}"-"${PNAME}"-jn"
TENSOR=${NS}"-"${PNAME}"-tb"
JUPYTERLAB=${NS}"-"${PNAME}"-jl"

/home/ehostdev/jupyter/cloudflare-dns/cf-dns.sh -d bigbangcloud-client.co.kr -t CNAME -n ${JUPYTER} -c bigbangcloud-client.co.kr -l 1 -x y
sleep 1
/home/ehostdev/jupyter/cloudflare-dns/cf-dns.sh -d bigbangcloud-client.co.kr -t CNAME -n ${TENSOR} -c bigbangcloud-client.co.kr -l 1 -x y > /dev/null 2>&1
sleep 1
/home/ehostdev/jupyter/cloudflare-dns/cf-dns.sh -d bigbangcloud-client.co.kr -t CNAME -n ${JUPYTERLAB} -c bigbangcloud-client.co.kr -l 1 -x y > /dev/null 2>&1
sleep 1

jn_result_func() { curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${JUPYTER}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" | grep id > /dev/null 2>&1
        echo $?
}
jn_value=$(jn_result_func)
echo $jn_value

tb_result_func() { curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${TENSOR}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" | grep id > /dev/null 2>&1
	echo $?
}
tb_value=$(tb_result_func)
echo $tb_value

jl_result_func() { curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONEID}/dns_records?type=CNAME&name=${JUPYTERLAB}.${DOMAIN}&content=${DOMAIN}&proxied=true&page=1&per_page=100&order=type&direction=desc&match=all" \
     -H "X-Auth-Email: ${EMAIL}" \
     -H "X-Auth-Key: ${KEY}" \
     -H "Content-Type: application/json" | grep id > /dev/null 2>&1
	echo $?
}
jl_value=$(jl_result_func)
echo $jl_value

if [ $jn_value -eq 0 ] && [ $tb_value -eq 0 ] && [ $jl_value -eq 0 ]; then
	echo "ALL DNS are Registered"
elif [ $jn_value -eq 1 ] && [ $tb_value -eq 0 ] && [ $jl_value -eq 0 ]; then
	echo "JupyterNotebook DNS Not Registered"
elif [ $jn_value -eq 0 ] && [ $tb_value -eq 1 ] && [ $jl_value -eq 0 ]; then
	echo "TensorBoard DNS Not Registered"
elif [ $jn_value -eq 0 ] && [ $tb_value -eq 0 ] && [ $jl_value -eq 1 ]; then
	echo "JupyterLab DNS Not Registered"
elif [ $jn_value -eq 1 ] && [ $tb_value -eq 1 ] && [ $jl_value -eq 0 ]; then
	echo "JupyterNotebook, TensorBoard DNS Not Registered"
elif [ $jn_value -eq 0 ] && [ $tb_value -eq 1 ] && [ $jl_value -eq 1 ]; then
	echo "TensorBoard, JupyterLab DNS Not Registered"
elif [ $jn_value -eq 1 ] && [ $tb_value -eq 0 ] && [ $jl_value -eq 1 ]; then
	echo "JupyterNotebook, JupyterLab DNS Not Registered"
else
	echo "ALL DNS are not Registered"
fi

exit 0
