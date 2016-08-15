pushd $DIR/data/kubernetes

for NODE in ${KUBE_API_NODES[@]}; do
    scp known_tokens.csv root@${NODE}:/etc/kubernetes/known_tokens.csv
done
