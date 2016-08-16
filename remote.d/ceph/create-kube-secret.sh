cd $DIR/data/ceph

CEPH_CLIENT_KEY=$(grep 'key = ' ceph.client.admin.keyring | awk '{print $3}')

cat > ceph-secret.yml <<DELIM
apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: ${CEPH_CLIENT_KEY}
DELIM

kubectl create -f ceph-secret.yaml
