# this random string is used to get a unique key vault name
# NOTE: terraform state is not saved so this will generate a unique account name each execution
resource "random_string" "keyvault" {
  length  = 5
  special = false
  upper   = false
}

# Create a Key Vault to hold the kubeconfig and sitecore license
resource "azurerm_key_vault" "default" {
  name                        = "${var.name}${random_string.keyvault.result}"
  location                    = azurerm_resource_group.default.location
  resource_group_name         = azurerm_resource_group.default.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]

    certificate_permissions = [
      "Create",
      "Get",
      "Import",
      "Delete",
      "Update",
      "List"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "random_password" "windows" {
  length = 16
}

resource "random_password" "sql" {
  length = 16
}

resource "azurerm_key_vault_secret" "windowspassword" {
  name         = "windows-password"
  value        = random_password.windows.result
  key_vault_id = azurerm_key_vault.default.id
}

resource "azurerm_key_vault_secret" "kubeconfig" {
  name         = "kubeconfig"
  value        = azurerm_kubernetes_cluster.default.kube_config_raw
  key_vault_id = azurerm_key_vault.default.id
}

resource "azurerm_key_vault_secret" "sqlpassword" {
  name         = "sql-password"
  value        = random_password.sql.result
  key_vault_id = azurerm_key_vault.default.id
}