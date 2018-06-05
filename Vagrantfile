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
# There is no way to create a network interface with a custom name, see https://github.com/hashicorp/vagrant/issues/8322
# Thus, reusing `eth0` that is specific to bento, see https://github.com/chef/bento/pull/900
IPADDR=`ifconfig eth0 | grep Mask | awk '{print $2}'| cut -f2 -d:`
echo This VM has IP address $IPADDR

# Set up Kubernetes
NODENAME=$(hostname -s)
kubeadm init --apiserver-cert-extra-sans=$IPADDR  --node-name $NODENAME

# Set up admin creds for the vagrant user
echo Copying credentials to /home/vagrant...
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

# Wait until Kubernetes cluster is ready
for i in {1..150}; do # timeout for 5 minutes
  ./kubectl get po &> /dev/null
  if [ $? -ne 1 ]; then
      break
  fi
  echo "Kubernetes cluster is not ready"
  sleep 2
done

# Install a pod network
kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')

# Allow pods to run on the master node
kubectl taint nodes --all node-role.kubernetes.io/master-

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "localkube"
  config.vm.hostname = "localkube"
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provision "docker"
  config.vm.provision "shell", inline: $script
end