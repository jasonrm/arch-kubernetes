#!/bin/sh

## Network to be allocated (in /24's by default) to nodes for use by pods
KUBE_CLUSTER_CIDR="10.254.0.0/16"

## Network to be allocated to cluster services which are accessible from anywhere inside the cluster (not externally accessible via routing due to how iptables is used for the intra-cluster routing)
KUBE_SERVICE_CIDR="10.252.0.0/16"

## Users that will authenticate with tokens
KUBE_SYSTEM_USERS=(kubelet kube-proxy kube-scheduler kube-controller-manager kube-dashboard kube-dns)
KUBE_USERS=(jasonrm)

## kube-apiserver
##
## Nodes to install kube-apiserver on
# KUBE_API_NODES=(node01 node02 node03)
##  or
KUBE_API_NODES=("${CLUSTER_NODE_HOSTNAMES[@]}")
##
KUBE_API_PORT=6443

KUBE_API_SERVERS=""
for KUBE_API_SERVER in ${KUBE_API_NODES[@]}; do
    KUBE_API_SERVERS="$KUBE_API_SERVERS,https://${KUBE_API_SERVER}:${KUBE_API_PORT}"
done
KUBE_API_SERVERS=${KUBE_API_SERVERS:1}


## kube-proxy
##
## Nodes to install kube-proxy on
# KUBE_PROXY_NODES=(node01 node02 node03)
##  or
KUBE_PROXY_NODES=("${CLUSTER_NODE_HOSTNAMES[@]}")
