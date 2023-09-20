locals {
  rg_name            = azurerm_resource_group.az-waf-rg.name
  loc                = azurerm_resource_group.az-waf-rg.location
  vnet_name          = azurerm_virtual_network.az-waf-vnet.name
  sub0_id            = azurerm_subnet.az-waf-sub-0.id
  sub1_id            = azurerm_subnet.az-waf-sub-1.id
  nsg_id             = azurerm_network_security_group.az-waf-nsg.id
  http_settings_name = "${azurerm_virtual_network.az-waf-vnet.name}-be-http"
  #app_gateway_locals:
  frontend_ip_name = "${azurerm_virtual_network.az-waf-vnet.name}-fe-ip"
  gw_config        = yamldecode(file("vars.yaml"))
}
