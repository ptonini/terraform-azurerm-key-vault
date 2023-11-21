resource "random_id" "this" {
  count = var.randomize_name ? 1 : 0
  keepers = {
    name = var.name
  }
  byte_length = 8
}

resource "azurerm_key_vault" "this" {
  name                      = var.randomize_name ? substr("${var.name}${random_id.this[0].dec}", 0, 24) : var.name
  location                  = var.rg.location
  resource_group_name       = var.rg.name
  tenant_id                 = var.tenant_id
  sku_name                  = var.sku_name
  enable_rbac_authorization = var.enable_rbac_authorization
  dynamic "access_policy" {
    for_each = var.admins
    content {
      tenant_id               = var.tenant_id
      object_id               = access_policy.value
      certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
      key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
    }
  }
  dynamic "access_policy" {
    for_each = var.getters
    content {
      tenant_id          = var.tenant_id
      object_id          = access_policy.value.principal_id
      key_permissions    = ["Get"]
      secret_permissions = ["Get"]
    }
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "null_resource" "secret_value" {
  for_each = var.secrets
  triggers = {
    value = var.secrets[each.key]
  }
}

resource "azurerm_key_vault_secret" "this" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
  lifecycle {
    ignore_changes = [
      value
    ]
    replace_triggered_by = [
      null_resource.secret_value[each.key]
    ]
  }
}