#!/bin/bash

## This should have **ALL** of the FQDN hostnames (or shortname if using /etc/hosts for name resolution) you will be using in your cluster (including Kubernetes, Etcd, Ceph, etc.)
CLUSTER_NODE_HOSTNAMES=(node01 node02 node03)

## Not particularly important unless/until you want to run multiple clusters side-by-side, but we'll use the same name in Kubernetes and Ceph
CLUSTER_NAME=testCluster

if [[ $REMOTE -eq 1 ]]; then
    ZFS_POOL_NAME=$(zpool list -H | head -n1 | awk '{print $1}')
fi
