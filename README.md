# MY K3s/K8s CONFIG
(server/install_server is designed for CentOS 8)

### you need to install

[Kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)

#### change your passwords in kustomization.yaml

```
vim base/01-intern/02-db/kustomization.yaml
vim base/03-proxy/00-traefik22/kustomization.yaml
vim base/02-extern/06-plex/kustomization.yaml
```

### replace all *.domain.tld with your own domain

### install and run

```
git clone git@github.com:Crisu1710/k3s_pub.git
cd k3s_pub
# to run all
chmod +x run.sh
./run.sh
```
