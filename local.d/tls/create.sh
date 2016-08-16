# TLS : Create CA and node certificates

mkdir -p $DIR/data/tls
cd $DIR/data/tls

# Create CA
openssl genrsa -out ${CLUSTER_NAME}-ca.key $TLS_CA_RSA_BITS
openssl req -x509 -new -nodes -key ${CLUSTER_NAME}-ca.key -subj "/CN=${TLS_CA_NAME}" -days $TLS_CA_DAYS -out ${CLUSTER_NAME}-ca.crt

# Create server certs
for _HOSTNAME in ${CLUSTER_NODE_HOSTNAMES[@]}; do
    SAN_IP=$(resolveip -s ${_HOSTNAME})
    SAN="DNS:${_HOSTNAME},IP:${SAN_IP},IP:10.252.0.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"
    export SAN
    openssl genrsa -out $_HOSTNAME.key $TLS_SERVER_RSA_BITS
    openssl req -new -key $_HOSTNAME.key -subj "/CN=${_HOSTNAME}" -config $DIR/openssl.cnf -out tmp-server.csr
    openssl req -text -noout -in tmp-server.csr
    openssl x509 -req -in tmp-server.csr -CA ${CLUSTER_NAME}-ca.crt -extfile $DIR/openssl.cnf -extensions server_ext -CAkey ${CLUSTER_NAME}-ca.key -CAcreateserial -out $_HOSTNAME.crt -days $TLS_SERVER_DAYS
    openssl x509 -text -noout -in $_HOSTNAME.crt
    rm tmp-server.csr
done
