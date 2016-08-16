if [[ " ${CEPH_OSD_NODES[@]} " =~ " ${HOSTNAME} " ]]; then
    UUID=$(uuidgen)
    OSD_NUMBER=$(ceph osd create $UUID)
    echo "$UUID $OSD_NUMBER"
    zfs create -p ${ZFS_CEPH_FS}/osd/ceph-${OSD_NUMBER}
    ceph-osd -i ${OSD_NUMBER} --mkfs --mkkey --osd-uuid ${UUID}

    ceph auth add osd.${OSD_NUMBER} osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-${OSD_NUMBER}/keyring

    ceph osd crush add-bucket $(hostname -s) host
    ceph osd crush move $(hostname -s) root=default
    ceph osd crush add osd.${OSD_NUMBER} 1.0 host=$(hostname -s)

    # Make sure the service is always running
    mkdir -p /etc/systemd/system/ceph-osd@.service.d
    cat > /etc/systemd/system/ceph-osd@.service.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
    systemctl start ceph-osd@${OSD_NUMBER}.service
    systemctl enable ceph-osd@${OSD_NUMBER}.service
fi
