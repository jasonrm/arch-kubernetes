if [[ " ${CEPH_MON_NODES[@]} " =~ " ${HOSTNAME} " ]]; then
    zfs create -p ${ZFS_CEPH_FS}/mon/ceph-${HOSTNAME}
    ceph-mon --mkfs -i ${HOSTNAME} --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
    touch /var/lib/ceph/mon/ceph-${HOSTNAME}/done
    systemctl start ceph-mon@${HOSTNAME}.service
    systemctl enable ceph-mon@${HOSTNAME}.service
fi
