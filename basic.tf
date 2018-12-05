resource "azurerm_resource_group" "test" {
  name     = "acctestRG1"
  location = "East US"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.test.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  dns_prefix          = "acctestagent1"
  kubernetes_version  = "1.10.9"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
    }
  }

  tags {
    Environment = "Production"
  }
}

output "id" {
    value = "${azurerm_kubernetes_cluster.test.id}"
}

output "name" {
    value = "${azurerm_kubernetes_cluster.test.name}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.test.kube_config_raw}"
}

output "client_key" {
  value = "${azurerm_kubernetes_cluster.test.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.test.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.test.kube_config.0.cluster_ca_certificate}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.test.kube_config.0.host}"
}

output "agent_pool" {
  value = "default"
}

output "resource_group" {
  value = "${azurerm_resource_group.test.name}"
}

output "node_resource_group" {
  value = "${azurerm_kubernetes_cluster.test.node_resource_group}"
}
