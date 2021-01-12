cd /mnt
mkdir MAIN SLAVE DATA
swapoff -a
#  /dev/sda    /mnt/data    ext4    defaults    0    1
#  /dev/sdc    /mnt/main    ext4    defaults    0    1
#  /dev/sdb    /mnt/slave   ext4    defaults    0    1
yum install epel-release
yum update
yum config-manager --set-enabled PowerTools
yum install -y container-selinux selinux-policy-base
rpm -i https://rpm.rancher.io/k3s-selinux-0.1.1-rc1.el7.noarch.rpm
export INSTALL_K3S_VERSION="v1.18.12+k3s1"
curl -sfL https://get.k3s.io | sh -s - --disable traefik --kubelet-arg=allowed-unsafe-sysctls=
yum install vim
yum install htop
yum install tar
dnf install nfs-utils
systemctl start nfs-server.service
systemctl enable nfs-server.service
systemctl stop firewalld
systemctl disable firewalld

# [root@localhost data]# cat /etc/exports
# /mnt/data		192.168.213.0/24(rw,sync,subtree_check,no_root_squash)
# /mnt/main		192.168.213.2(rw,sync,subtree_check,no_root_squash)