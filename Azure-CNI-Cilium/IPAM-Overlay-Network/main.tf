resource "azurerm_resource_group" "azpcoverlay" {
  name     = "azpcoverlay"
  location = "canadacentral"
}
resource "azurerm_virtual_network" "azpcoverlay" {
  name                = "azpcoverlay-vnet"
  address_space       = ["192.168.10.0/24"]
  location            = azurerm_resource_group.azpcoverlay.location
  resource_group_name = azurerm_resource_group.azpcoverlay.name
}
resource "azurerm_subnet" "azpcoverlay" {
  name                 = "azpcoverlay-subnet"
  resource_group_name  = azurerm_resource_group.azpcoverlay.name
  virtual_network_name = azurerm_virtual_network.azpcoverlay.name
  address_prefixes     = ["192.168.10.0/24"]

}
resource "azurerm_kubernetes_cluster" "azpcoverlay" {
  name                = "azpcoverlay"
  location            = azurerm_resource_group.azpcoverlay.location
  resource_group_name = azurerm_resource_group.azpcoverlay.name
  dns_prefix          = "azpcoverlay"
  default_node_pool {
    name           = "azpcoverlay"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.azpcoverlay.id
  }

  identity {
    type = "SystemAssigned"
  }
  
  network_profile {
    pod_cidr            = "10.10.0.0/22"
    service_cidr        = "10.20.0.0/24"
    dns_service_ip      = "10.20.0.10"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    ebpf_data_plane     = "cilium"
  }
}