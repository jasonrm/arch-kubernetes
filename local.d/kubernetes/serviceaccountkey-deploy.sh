pushd $DIR/data/kubernetes

for NODE in ${KUBE_API_NODES[@]}; do
    scp serviceaccount.key root@${NODE}:/etc/kubernetes/serviceaccount.key
done
