mkdir -p $DIR/data/ceph
cd $DIR/data/ceph

for CEPH_MON_NODE in ${CEPH_MON_NODES[@]}; do
    scp monmap ceph.mon.keyring ceph.client.admin.keyring root@${CEPH_MON_NODE}:/etc/ceph/
done
