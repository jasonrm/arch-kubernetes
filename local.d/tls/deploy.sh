pushd $DIR/data/tls

for _HOSTNAME in ${CLUSTER_NODE_HOSTNAMES[@]}; do
    scp ${CLUSTER_NAME}-ca.crt $_HOSTNAME.key $_HOSTNAME.crt root@$_HOSTNAME:/etc/ssl/
    scp ${CLUSTER_NAME}-ca.crt root@$_HOSTNAME:/etc/kubernetes/ca.crt
done
