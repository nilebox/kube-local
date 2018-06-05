# kube-local
Vagrant-based script for starting local Kubernetes cluster accessible from kubectl on the host machine

# Prerequisites

Download and install Vagrant (https://www.vagrantup.com/docs/installation/).

# Creating/resuming VM with Kubernetes cluster

Run `./kube-up.sh` to create or resume suspended VM with Kubernetes cluster.
At the end of running script, follow instructions:
```
====================================================================

Now run the following command to setup kubectl context for localkube

  export KUBECONFIG=${HOME}/.kube/config:$HOME/.kube/localkube

Once you've done this, you can use this context via --context flag:

  kubectl --context localkube get pods

And if you want to make 'localkube' your default context, run:

  kubectl config use-context localkube

====================================================================
```
Once you finished, you should be able to run commands agaist locally running Kubernetes 
cluster using `kubectl` the same way you normally do for remote clusters:
```
kubectl get pods
```

# Suspending VM with Kubernetes cluster

Run `./kube-down.sh`

# Destroying VM with Kubernetes cluster

Run `./kube-destroy.sh`
