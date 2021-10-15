# install krew
(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" &&
  "$KREW" install krew
)

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/$USER/.zshrc

kubectl krew install ctx
kubectl krew install ns
kubectl krew install tree

# install kube-ps1
git clone https://github.com/jonmosco/kube-ps1.git
echo 'source /home/$USER/kube-ps1.sh' >> /home/$USER/.zshrc
echo 'PROMPT='$(kube_ps1)'$PROMPT' >> /home/$USER/.zshrc

echo 'alias ktree="kubectl tree"' >> /home/$USER/.aliases
echo 'alias k="kubectl"' >> /home/$USER/.aliases
