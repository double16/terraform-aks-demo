# AKS Quick Start

This is the configuration from https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html

WIP: Virtual machine instances are auto scaled using helm chart stable/cluster-autoscaler.

Helm is installed according to https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm

```shell
$ az login
$ ./up.sh
$ export KUBECONFIG="${HOME}/.kube/aks-demo-config"
$ helm install stable/kubernetes-dashboard --namespace kube-system
$ kubectl get all
```
