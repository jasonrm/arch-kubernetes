# Install
pacman --sync --refresh --noconfirm --needed  etcd

# unique per-host variables, if you don't have a valid hostname set you'll have issues here
# you might also have issues if the hostname here is different than what was used in the TLS cert creation steps
ETCD_NODE_HOSTNAME=$(hostname -s)
ETCD_NODE_IP=$(ip route get ${ETCD_PEER_CIDR} | grep -oP 'src \K\S+')

cat > /etc/conf.d/etcd <<DELIM
ETCD_INITIAL_CLUSTER="node01=https://node01:${ETCD_PEER_PORT},node02=https://node02:${ETCD_PEER_PORT},node03=https://node03:${ETCD_PEER_PORT}"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${ETCD_NODE_IP}:${ETCD_PEER_PORT}"
ETCD_LISTEN_PEER_URLS="https://${ETCD_NODE_IP}:${ETCD_PEER_PORT}"
ETCD_LISTEN_CLIENT_URLS="https://0.0.0.0:${ETCD_CLIENT_PORT}"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_NODE_HOSTNAME}:${ETCD_CLIENT_PORT}"
ETCD_NAME="${ETCD_NODE_HOSTNAME}"

# Client-to-Server
ETCD_CERT_FILE=/etc/ssl/${ETCD_NODE_HOSTNAME}.crt
ETCD_KEY_FILE=/etc/ssl/${ETCD_NODE_HOSTNAME}.key
ETCD_CLIENT_CERT_AUTH=true
ETCD_TRUSTED_CA_FILE=${TLS_CA_CERT}

# Peer/Server-to-Server/Cluster
ETCD_PEER_CERT_FILE=/etc/ssl/${ETCD_NODE_HOSTNAME}.crt
ETCD_PEER_KEY_FILE=/etc/ssl/${ETCD_NODE_HOSTNAME}.key
ETCD_PEER_CLIENT_CERT_AUTH=true
ETCD_PEER_TRUSTED_CA_FILE=${TLS_CA_CERT}

DELIM

# Start Etcd
systemctl restart etcd

# Configure Etcd to start on boot
systemctl enable etcd
