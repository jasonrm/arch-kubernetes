if [[ " ${CEPH_MON_NODES[@]} " =~ " ${HOSTNAME} " ]]; then
    systemctl stop ceph-mon@${HOSTNAME}.service
    systemctl disable ceph-mon@${HOSTNAME}.service
    rm -rf /var/lib/ceph/mon/ceph-${HOSTNAME}/*
fi
