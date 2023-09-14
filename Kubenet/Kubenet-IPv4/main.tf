resource "azurerm_resource_group" "azurecilium" {
  name     = "azurecilium"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "azurecilium" {
  name                = "azurecilium-vnet"
  address_space       = ["192.168.10.0/24"]
  location            = azurerm_resource_group.azurecilium.location
  resource_group_name = azurerm_resource_group.azurecilium.name
}

resource "azurerm_subnet" "azurecilium" {
  name                 = "azurecilium-subnet"
  resource_group_name  = azurerm_resource_group.azurecilium.name
  virtual_network_name = azurerm_virtual_network.azurecilium.name
  address_prefixes     = ["192.168.10.0/24"]

}

resource "azurerm_kubernetes_cluster" "azurecilium" {
  name                = "azurecilium"
  location            = azurerm_resource_group.azurecilium.location
  resource_group_name = azurerm_resource_group.azurecilium.name
  dns_prefix          = "azurecilium"
  default_node_pool {
    name              = "azurecilium"
    node_count        = 2
    vm_size           = "Standard_DS2_v2"
    vnet_subnet_id    = azurerm_subnet.azurecilium.id
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin   = "kubenet"
    ip_versions      = ["IPv4"]
    pod_cidr         = "10.10.0.0/22"
    service_cidr     = "10.20.0.0/24"
    dns_service_ip   = "10.20.0.10"
  }
}