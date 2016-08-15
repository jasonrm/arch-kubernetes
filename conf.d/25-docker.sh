if [[ $REMOTE -eq 1 ]]; then
    # Use first pool
    ZFS_POOL_NAME=$(zpool list -H | head -n1 | awk '{print $1}')
    ZFS_DOCKER_FS="${ZFS_POOL_NAME}/docker"

    DOCKER_STORAGE_ARGS="-s zfs --storage-opt zfs.fsname=${ZFS_DOCKER_FS}"
fi

