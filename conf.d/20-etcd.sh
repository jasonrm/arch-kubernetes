#!/bin/sh

## Network to be used by Etcd peers (used to determine etcd node IP)
ETCD_PEER_CIDR="10.0.0.0/8"
ETCD_PEER_PORT=2380
ETCD_CLIENT_PORT=2379

## Nodes to run Etcd cluster on
#ETCD_CLUSER_NODES=(node01 node02 node03)
# or
ETCD_CLUSER_NODES=("${CLUSTER_NODE_HOSTNAMES[@]}")

ETCD_SERVERS=""
for ETCD_SERVER in ${ETCD_CLUSER_NODES[@]}; do
    ETCD_SERVERS="$ETCD_SERVERS,https://${ETCD_SERVER}:${ETCD_CLIENT_PORT}"
done
ETCD_SERVERS=${ETCD_SERVERS:1}
