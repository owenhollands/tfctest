resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "this" {
  name                     = "storAccHub1"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "storConHub1"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_eventhub_namespace" "this" {
  name                = "nSpaceHib1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

resource "azurerm_eventhub" "this" {
  name                = "eHubHub1"
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "this" {
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  name                = "eHubRuleHub1"
  send                = true
}

resource "azurerm_iothub" "this" {
  name                         = "iotHubHub1"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  local_authentication_enabled = false

  sku {
    name     = "S1"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = azurerm_storage_account.this.primary_blob_connection_string
    name                       = "export"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = azurerm_storage_container.this.name
    encoding                   = "Avro"
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }

  endpoint {
    type              = "AzureIotHub.EventHub"
    connection_string = azurerm_eventhub_authorization_rule.this.primary_connection_string
    name              = "export2"
  }

  route {
    name           = "export"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export"]
    enabled        = true
  }

  route {
    name           = "export2"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export2"]
    enabled        = true
  }

  enrichment {
    key            = "tenant"
    value          = "$twin.tags.Tenant"
    endpoint_names = ["export", "export2"]
  }

  cloud_to_device {
    max_delivery_count = 30
    default_ttl        = "PT1H"
    feedback {
      time_to_live       = "PT1H10M"
      max_delivery_count = 15
      lock_duration      = "PT30S"
    }
  }

  tags = {
    purpose = "testing"
  }
}