ETCD_NODE_HOSTNAME=$(hostname -s)

etcdctl \
    --endpoints="https://${ETCD_NODE_HOSTNAME}:2379" \
    --ca-file=${TLS_CA_CERT} \
    --cert-file=/etc/ssl/$(hostname -s).crt \
    --key-file=/etc/ssl/$(hostname -s).key \
    cluster-health
