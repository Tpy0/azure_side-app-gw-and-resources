resource "azurerm_public_ip" "az-waf-app-gw" {
  name                = "az-waf-app-gw0"
  resource_group_name = local.rg_name
  location            = local.loc
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "az-app-gw" {
  name                = "appgateway"
  resource_group_name = local.rg_name
  location            = local.loc

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = local.sub0_id
  }

  backend_http_settings {
    name                  = local.http_settings_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.az-waf-app-gw.id
  }

  #-----------loop and whirl til' you hurl--------------------#
  for_each            = local.gw_config
  
  dynamic "frontend_port" {
      for_each = each.value.gwr[*]   
    content {
      name = frontend_port.value.frontend_port_name
      port = frontend_port.value.frontend_port
    }
  }

  dynamic "backend_address_pool" {
    for_each = each.value.gwr[*]
    content {
      name         = backend_address_pool.value.bap_name
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "http_listener" {
    for_each = each.value.gwr[*]
    content {
      name                           = http_listener.value.listener_name
      frontend_ip_configuration_name = local.frontend_ip_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = "Http"
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.gwr[*]
    content {
      name                       = request_routing_rule.value.request_routing_rule_name
      rule_type                  = "Basic"
      http_listener_name         = request_routing_rule.value.listener_name
      backend_address_pool_name  = request_routing_rule.value.bap_name
      backend_http_settings_name = local.http_settings_name
      priority                   = request_routing_rule.value.priority
    }
  }
}
