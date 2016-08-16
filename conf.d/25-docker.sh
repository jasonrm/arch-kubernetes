if [[ $REMOTE -eq 1 ]]; then
    ZFS_DOCKER_FS="${ZFS_POOL_NAME}/docker"

    DOCKER_STORAGE_ARGS="-s zfs --storage-opt zfs.fsname=${ZFS_DOCKER_FS}"
fi

