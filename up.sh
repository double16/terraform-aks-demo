#!/bin/bash -xe -o pipefail

export KUBECONFIG="${HOME}/.kube/aks-demo-config"
export TF_VAR_client_id="${AZURE_CLIENT_ID}"
export TF_VAR_client_secret="${AZURE_CLIENT_SECRET}"

terraform apply
terraform output -json | jq -r .kube_config.value > ${KUBECONFIG}

# Helm, https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm
kubectl apply -f tiller-rbac-config.yaml
helm init --service-account tiller --wait
helm install stable/cluster-autoscaler --namespace kube-system \
    --set "cloudProvider=azure" \
    --set "autoscalingGroups[0].name=$(terraform output -json | jq -r .agent_pool.value)" \
    --set "autoscalingGroups[0].maxSize=10" \
    --set "autoscalingGroups[0].minSize=1" \
    --set "azureClientID=${AZURE_CLIENT_ID}" \
    --set "azureClientSecret=${AZURE_CLIENT_SECRET}" \
    --set "azureSubscriptionID=${AZURE_SUBSCRIPTION_ID}" \
    --set "azureTenantID=${AZURE_TENANT_ID}" \
    --set "azureClusterName=$(terraform output -json | jq -r .name.value)" \
    --set "azureResourceGroup=$(terraform output -json | jq -r .resource_group.value)" \
    --set "azureVMType=AKS" \
    --set "azureNodeResourceGroup=$(terraform output -json | jq -r .node_resource_group.value)"
