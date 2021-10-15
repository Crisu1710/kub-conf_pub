#!/usr/bin/env bash

apt-get update && apt-get upgrade -y

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    vim \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update && apt-get install -y containerd.io

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

systemctl restart containerd

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

curl -s \
https://packages.cloud.google.com/apt/doc/apt-key.gpg \
| apt-key add -

apt-get -y update
apt-get install -y \
kubeadm=1.22.2-00 kubelet=1.22.2-00 kubectl=1.22.2-00
apt-mark hold kubelet kubeadm kubectl

swapoff -a
sed '/swap/d' /etc/fstab > /etc/fstab.noswap; mv /etc/fstab.noswap /etc/fstab
echo "NODE_IP #TODO cp" >> /etc/hosts

#################################### MASTER #########################################

if [ "$HOSTNAME" = cp ]; then
    printf 'MASTER'
    wget -c https://docs.projectcalico.org/manifests/calico.yaml

    cat <<EOF | sudo tee /root/kubeadm-config.yaml
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterConfiguration
    kubernetesVersion: 1.22.2
    controlPlaneEndpoint: "cp:6443"
    networking:
      podSubnet: 192.168.233.0/24
EOF

    kubeadm init --config=/root/kubeadm-config.yaml --upload-certs | tee /root/kubeadm-init.out
    kubeadm token create --print-join-command | grep kubeadm > join

    mkdir -p $HOME/.kube
    mkdir /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    chown vagrant:vagrant /home/vagrant/.kube/config
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl taint nodes --all node-role.kubernetes.io/master-
    kubectl apply -f calico.yaml
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
    #https://github.com/kubernetes/ingress-nginx/blob/main/docs/deploy/index.md#bare-metal
    cat /root/kubeadm-init.out

else
    printf "NOK"
fi
