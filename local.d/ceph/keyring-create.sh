ssh root@${CEPH_MON_NODES[0]} "bash -s" <<SSHDELIM

cat > /etc/ceph/ceph.conf <<DELIM
fsid = ${CEPH_FSID}
mon initial members = ${CEPH_MON_INITIAL_MEMBERS}
mon host = ${CEPH_MON_HOSTS}
DELIM

ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
monmaptool --create --fsid ${CEPH_FSID} /tmp/monmap
CEPH_MON_NODES=("${CEPH_MON_NODES[@]}")
echo $CEPH_MON_NODES
# for CEPH_MON_NODE in ${CEPH_MON_NODES[@]}; do
#     CEPH_MON_NODE_IP=$(resolveip -s ${CEPH_MON_NODE})
#     monmaptool --add $CEPH_MON_NODE ${CEPH_MON_NODE_IP} --fsid ${CEPH_FSID} /tmp/monmap
# done

SSHDELIM


