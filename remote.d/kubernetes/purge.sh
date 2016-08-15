systemctl stop kubelet kube-proxy kube-apiserver kube-scheduler kube-controller-manager docker
systemctl disable kubelet kube-proxy kube-apiserver kube-scheduler kube-controller-manager docker
zfs destroy -r rpool/docker
