resource "azurerm_resource_group" "iotcentral-rg-01" {
  name     = "iot-hub-central-01"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "example" {
  name                = "iotcentral-app-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sub_domain          = "iotcentral-app-subdomain-01"

  display_name = "iotcentral-app-display-name-01"
  sku          = "ST1"
  template     = "iotc-pnp-preview"

  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = "true"


  tags = {
    Foo = "Bar"
  }
}