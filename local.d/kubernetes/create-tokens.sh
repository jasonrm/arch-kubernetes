mkdir -p $DIR/data/kubernetes
cd $DIR/data/kubernetes

rm known_tokens.csv

KUBE_UID=10
for KUBE_USER in ${KUBE_SYSTEM_USERS[@]}; do
    KUBE_TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
    echo "$KUBE_TOKEN,$KUBE_USER,$KUBE_UID" >> known_tokens.csv
    KUBE_UID=$(($KUBE_UID + 1))
done

KUBE_UID=1000
for KUBE_USER in ${KUBE_USERS[@]}; do
    KUBE_TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
    echo "$KUBE_TOKEN,$KUBE_USER,$KUBE_UID" >> known_tokens.csv
    KUBE_UID=$(($KUBE_UID + 1))
done
