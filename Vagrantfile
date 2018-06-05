# This script to install Kubernetes will get executed after we have provisioned the box 
$script = <<-SCRIPT

export DEBIAN_FRONTEND=noninteractive

# Install kubernetes
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

# kubelet requires swap off
swapoff -a
# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Make sure that the cgroup driver used by kubelet is the same as the one used by Docker.
# see https://kubernetes.io/docs/tasks/tools/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-master-node
# For debug, run `docker info | grep -i cgroup`
echo "Updating kubelet cgroup driver to match the Docker one"
sed -i '0,/[Service]/a\
Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Get the IP address that VirtualBox has given this VM
# `eth1` is the name of network interface created via `config.vm.network` below
IPADDR=`ifconfig eth1 | grep Mask | awk '{print $2}' | cut -f2 -d: | tr -d '\n'`
echo This VM has IP address $IPADDR

# Set up Kubernetes
NODENAME=$(hostname -s)
kubeadm init --apiserver-cert-extra-sans=$IPADDR  --node-name $NODENAME

# Set up admin creds for the vagrant user (to let user `vagrant ssh` and run kubectl)
echo Copying credentials to /home/vagrant...
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

# Set up admin creds for the current user (to be able to run kubectl within Vagrantfile)
echo Copying credentials to $HOME...
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u $USER):$(id -g $USER) $HOME/.kube/config

# Wait until Kubernetes cluster is ready
echo "Waiting for Kubernetes cluster to become ready"
kube_ready=false
for i in {1..150}; do # timeout for 5 minutes
  if ! kubectl get pods > /dev/null; then
    echo "Kubernetes cluster is not ready"
    sleep 2
    continue
  fi
  echo "Kubernetes cluster is ready"
  kube_ready=true
  break
done

if [ ! "$kube_ready" = true ] ; then
    echo 'Timed out waiting for Kubernetes to become ready'
    exit 1
fi

# Install a pod network
echo "Installing a pod network (Weave)"
kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')

# Allow pods to run on the master node
echo "Allowing pods to run on the master node"
kubectl taint nodes --all node-role.kubernetes.io/master-

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "localkube"
  config.vm.hostname = "localkube"
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.network "private_network", type: "dhcp"
  config.vm.provision "docker"
  config.vm.provision "shell", inline: $script
end