cd $DIR/data/ceph

CEPH_CLIENT_KEY=$(grep key ceph.client.admin.keyring |awk '{printf "%s", $NF}'|base64)

cat > ceph-secret.yaml <<DELIM
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: ${CEPH_CLIENT_KEY}
DELIM

kubectl create -f ceph-secret.yaml
