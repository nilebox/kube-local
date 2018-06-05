#!/usr/bin/env bash

set -euo pipefail
cd "$( dirname "${BASH_SOURCE[0]}" )"

vagrant up

# Get internal VM IP address
INTERNAL_IP=$(vagrant ssh -c "ifconfig eth0 | grep Mask | awk '{print \$2}' | cut -f2 -d: | tr -d '\n'")
echo VM internal IP address is $INTERNAL_IP

# Get external VM IP address
EXTERNAL_IP=$(vagrant ssh -c "ifconfig eth1 | grep Mask | awk '{print \$2}' | cut -f2 -d: | tr -d '\n'")
echo VM external IP address is $EXTERNAL_IP

# Prepare config file
vagrant ssh -c "sudo cat /etc/kubernetes/admin.conf" > localkube.conf
sed -i '' "s/$INTERNAL_IP/$EXTERNAL_IP/g" localkube.conf
sed -i '' 's/kubernetes/localkube/g' localkube.conf
sed -i '' 's/localkube-admin@localkube/localkube/g' localkube.conf

LOCALCONFIG=$HOME/.kube/localkube
cp localkube.conf $LOCALCONFIG

# Keep both remote and local config accessible via kubectl
echo "===================================================================="
echo ""
echo "Now run the following command to setup kubectl context for localkube"
echo ""
KUBECONFIG=${HOME}/.kube/config:${LOCALCONFIG}
echo "  export KUBECONFIG=\${HOME}/.kube/config:\$HOME/.kube/localkube"
echo ""
echo "Once you've done this, you can use this context via --context flag:"
echo ""
echo "  kubectl --context localkube get pods"
echo ""
echo "And if you want to make 'localkube' your default context, run:"
echo ""
echo "  kubectl config use-context localkube"
echo ""
echo "===================================================================="