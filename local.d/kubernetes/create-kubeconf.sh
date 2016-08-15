ADMIN_USER=$3
ADMIN_TOKEN=$(cat $DIR/data/kubernetes/known_tokens.csv | grep ",${ADMIN_USER}," |  awk -F, '{print $1}')

kubectl config set-cluster ${CLUSTER_NAME} --certificate-authority="${DIR}/data/tls/${CLUSTER_NAME}-ca.crt" --embed-certs=true --server="https://${KUBE_API_NODES[0]}:${KUBE_API_PORT}"
kubectl config set-credentials ${ADMIN_USER} --token=${ADMIN_TOKEN}

kubectl config set-context $CLUSTER_NAME --cluster=${CLUSTER_NAME} --user=${ADMIN_USER}
kubectl config use-context $CLUSTER_NAME
