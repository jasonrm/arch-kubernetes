ssh root@${CEPH_MON_NODES[0]} "cat > /etc/ceph/ceph.conf" <<DELIM
# Created at $(date -u +"%Y-%m-%dT%H:%M:%SZ")
fsid = ${CEPH_FSID}
mon initial members = ${CEPH_MON_INITIAL_MEMBERS}
mon host = ${CEPH_MON_HOSTS}
DELIM

ssh root@${CEPH_MON_NODES[0]} "bash -s" <<DELIM
# Embed ipfor function
function ipfor() {
  ping -c 1 \$1 | grep -Eo -m 1 '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';
}

rm /tmp/monmap /tmp/ceph.mon.keyring /tmp/ceph.client.admin.keyring
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring /tmp/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /tmp/ceph.client.admin.keyring
monmaptool --create --fsid ${CEPH_FSID} /tmp/monmap

for CEPH_MON_NODE in ${CEPH_MON_NODES[@]}; do
    monmaptool --add \${CEPH_MON_NODE} \$(ipfor \${CEPH_MON_NODE}) --fsid ${CEPH_FSID} /tmp/monmap
done
DELIM

mkdir -p $DIR/data/ceph
cd $DIR/data/ceph

scp root@${CEPH_MON_NODES[0]}:/tmp/monmap root@${CEPH_MON_NODES[0]}:/tmp/ceph.client.admin.keyring root@${CEPH_MON_NODES[0]}:/tmp/ceph.mon.keyring ./
