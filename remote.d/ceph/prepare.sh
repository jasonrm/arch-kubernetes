# Install
pacman --sync --refresh --noconfirm --needed ceph

zfs create -o com.sun:auto-snapshot=false -o xattr=sa -o dnodesize=auto -o mountpoint=/var/lib/ceph ${ZFS_CEPH_FS}

cat > /etc/ceph/ceph.conf <<DELIM
[global]
fsid = ${CEPH_FSID}

public network = ${CEPH_PUBLIC_CIDR}
cluster network = ${CEPH_CLUSTER_CIDR}

auth cluster required = cephx
auth service required = cephx
auth client required = cephx

mon initial members = ${CEPH_MON_INITIAL_MEMBERS}
mon host = ${CEPH_MON_HOSTS}

osd journal size = 1024
osd pool default size = 2
osd pool default min size = 1
osd pool default pg num = 333
osd pool default pgp num = 333
osd crush chooseleaf type = 1

[osd]
journal dio = false
DELIM
