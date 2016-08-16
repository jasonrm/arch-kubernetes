pacman --sync --refresh --noconfirm --needed kubernetes docker bird

zfs create -o com.sun:auto-snapshot=false -o mountpoint=/var/lib/docker ${ZFS_DOCKER_FS}

mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/kubernetes.conf <<DELIM
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// -H tcp://127.0.0.1:2375 --bridge=cbr0 --iptables=false --ip-masq=false ${DOCKER_STORAGE_ARGS}
DELIM
systemctl daemon-reload
systemctl restart docker
systemctl enable docker


cat > /etc/systemd/network/90-cbr0.netdev <<DELIM
[NetDev]
Name=cbr0
Kind=bridge
DELIM

# BIRD - Use OSPF to determine route to pods on other nodes
#
cat > /etc/bird.conf <<DELIM
protocol kernel {
  persist;
  scan time 20;
  export all;
}

protocol device {
  scan time 30;
}

protocol ospf kubernetes {
  area 0.0.0.0 {
    interface "en*";
  };
  area 120 {
    interface "cbr0";
  };
}
DELIM

# Make sure the service is always running
mkdir -p /etc/systemd/system/bird.service.d
cat > /etc/systemd/system/bird.service.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
systemctl daemon-reload
systemctl restart bird
systemctl enable bird


KUBEPROXY_TOKEN=$(cat /etc/kubernetes/known_tokens.csv | grep ',kube-proxy,' | awk -F, '{print $1}')
mkdir -p /var/lib/kube-proxy
cat > /var/lib/kube-proxy/kubeconfig <<DELIM
apiVersion: v1
kind: Config
users:
- name: kube-proxy
  user:
    token: ${KUBEPROXY_TOKEN}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority: ${TLS_CA_CERT}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: kube-proxy
  name: service-account-context
current-context: service-account-context
DELIM

KUBELET_TOKEN=$(cat /etc/kubernetes/known_tokens.csv | grep ',kubelet,' | awk -F, '{print $1}')
mkdir -p /var/lib/kubelet
cat > /var/lib/kubelet/kubeconfig <<DELIM
apiVersion: v1
kind: Config
users:
- name: kubelet
  user:
    token: ${KUBELET_TOKEN}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority: ${TLS_CA_CERT}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: kubelet
  name: service-account-context
current-context: service-account-context
DELIM

KUBEDASHBOARD_TOKEN=$(cat /etc/kubernetes/known_tokens.csv | grep ',kube-dashboard,' | awk -F, '{print $1}')
mkdir -p /var/lib/kube-dashboard
cat > /var/lib/kube-dashboard/kubeconfig <<DELIM
apiVersion: v1
kind: Config
users:
- name: kube-dashboard
  user:
    token: ${KUBEDASHBOARD_TOKEN}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority: ${TLS_CA_CERT}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: kube-dashboard
  name: service-account-context
current-context: service-account-context
DELIM

KUBESCHDULER_TOKEN=$(cat /etc/kubernetes/known_tokens.csv | grep ',kube-scheduler,' | awk -F, '{print $1}')
mkdir -p /var/lib/kube-scheduler
cat > /var/lib/kube-scheduler/kubeconfig <<DELIM
apiVersion: v1
kind: Config
users:
- name: kube-scheduler
  user:
    token: ${KUBESCHDULER_TOKEN}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority: ${TLS_CA_CERT}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: kube-scheduler
  name: service-account-context
current-context: service-account-context
DELIM

KUBECONTROLLER_TOKEN=$(cat /etc/kubernetes/known_tokens.csv | grep ',kube-controller-manager,' | awk -F, '{print $1}')
mkdir -p /var/lib/kube-controller-manager
cat > /var/lib/kube-controller-manager/kubeconfig <<DELIM
apiVersion: v1
kind: Config
users:
- name: kube-controller-manager
  user:
    token: ${KUBECONTROLLER_TOKEN}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority: ${TLS_CA_CERT}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: kube-controller-manager
  name: service-account-context
current-context: service-account-context
DELIM

KUBEDNS_TOKEN=$(cat /etc/kubernetes/known_tokens.csv | grep ',kube-dns,' | awk -F, '{print $1}')
mkdir -p /var/lib/kube-dns
cat > /var/lib/kube-dns/kubeconfig <<DELIM
apiVersion: v1
kind: Config
users:
- name: kube-dns
  user:
    token: ${KUBEDNS_TOKEN}
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    certificate-authority: ${TLS_CA_CERT}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: kube-dns
  name: service-account-context
current-context: service-account-context
DELIM

# Configure and start services

# API Server
cat > /etc/kubernetes/apiserver <<DELIM
KUBE_API_ARGS="\
--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \
--client-ca-file=${TLS_CA_CERT} \
--etcd-cafile=${TLS_CA_CERT} \
--etcd-certfile=/etc/ssl/${HOSTNAME}.crt \
--etcd-keyfile=/etc/ssl/${HOSTNAME}.key \
--etcd-servers=${ETCD_SERVERS} \
--secure-port=${KUBE_API_PORT} \
--service-account-key-file=/etc/kubernetes/serviceaccount.key \
--service-cluster-ip-range=${KUBE_SERVICE_CIDR} \
--tls-cert-file=/etc/ssl/${HOSTNAME}.crt \
--tls-private-key-file=/etc/ssl/${HOSTNAME}.key \
--token-auth-file=/etc/kubernetes/known_tokens.csv \
"
DELIM
# Make sure the service is always running
mkdir -p /etc/systemd/system/kube-apiserver.d
cat > /etc/systemd/system/kube-apiserver.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
systemctl daemon-reload
systemctl restart kube-apiserver
systemctl enable kube-apiserver


# Kubelet
cat > /etc/kubernetes/kubelet <<DELIM
KUBELET_ARGS="\
--api-servers=${KUBE_API_SERVERS} \
--configure-cbr0=true \
--kubeconfig=/var/lib/kubelet/kubeconfig \
--register-node \
"
DELIM
# Make sure the service is always running
mkdir -p /etc/systemd/system/kubelet.d
cat > /etc/systemd/system/kubelet.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
systemctl daemon-reload
systemctl restart kubelet
systemctl enable kubelet


# kube-proxy
##
cat > /etc/kubernetes/proxy <<DELIM
KUBE_PROXY_ARGS="\
--cluster-cidr=${KUBE_CLUSTER_CIDR} \
--kubeconfig=/var/lib/kube-proxy/kubeconfig \
--master=https://${KUBE_API_NODES[0]}:${KUBE_API_PORT} \
"
DELIM
# Make sure the service is always running
mkdir -p /etc/systemd/system/kube-proxy.d
cat > /etc/systemd/system/kube-proxy.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
systemctl daemon-reload
systemctl restart kube-proxy
systemctl enable kube-proxy

# kube-scheduler
##
cat > /etc/kubernetes/scheduler <<DELIM
KUBE_SCHEDULER_ARGS="\
--kubeconfig=/var/lib/kube-scheduler/kubeconfig \
--leader-elect=true \
--master=https://${KUBE_API_NODES[0]}:${KUBE_API_PORT} \
"
DELIM
# Make sure the service is always running
mkdir -p /etc/systemd/system/kube-scheduler.d
cat > /etc/systemd/system/kube-scheduler.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
systemctl daemon-reload
systemctl restart kube-scheduler
systemctl enable kube-scheduler

# kube-controller-manager
##
cat > /etc/kubernetes/controller-manager <<DELIM
KUBE_CONTROLLER_MANAGER_ARGS="\
--root-ca-file=${TLS_CA_CERT} \
--allocate-node-cidrs=true \
--cluster-cidr=${KUBE_CLUSTER_CIDR} \
--cluster-name=${CLUSTER_NAME} \
--kubeconfig=/var/lib/kube-controller-manager/kubeconfig \
--leader-elect=true \
--master=https://${KUBE_API_NODES[0]}:${KUBE_API_PORT} \
--service-account-private-key-file=/etc/kubernetes/serviceaccount.key \
--service-cluster-ip-range=${KUBE_SERVICE_CIDR} \
"
DELIM
# Make sure the service is always running
mkdir -p /etc/systemd/system/kube-controller-manager.d
cat > /etc/systemd/system/kube-controller-manager.d/restart-always.conf <<DELIM
[Service]
Restart=always
RestartSec=15s
DELIM
systemctl daemon-reload
systemctl restart kube-controller-manager
systemctl enable kube-controller-manager
