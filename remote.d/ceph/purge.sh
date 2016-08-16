SERVICES=$(systemctl --plain | grep 'ceph-' | awk '{print $1}')
systemctl disable $SERVICES
systemctl stop $SERVICES

zfs destroy -r ${ZFS_CEPH_FS}
