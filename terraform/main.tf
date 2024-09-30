# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.95.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  subscription_id = "3356e38f-516f-4c71-917b-b8c1f1a41341" 
}

# Create a resource group
resource "azurerm_resource_group" "product" {
  name     = "product-resources"
  location = "East US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "producct" {
  name                = "product-network"
  resource_group_name = azurerm_resource_group.product.name
  location            = azurerm_resource_group.product.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "product" {
  name                = "product-aks1"
  location            = azurerm_resource_group.product.location
  resource_group_name = azurerm_resource_group.product.name
  dns_prefix          = "productaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.product.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.product.kube_config_raw

  sensitive = true
}