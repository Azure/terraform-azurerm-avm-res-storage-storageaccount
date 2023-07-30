resource "random_pet" "this" {
  length = 1
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "terraform-azurerm-storage-account-${random_pet.this.id}"
}

resource "random_string" "table_acl_id" {
  length  = 64
  special = false
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "storage${random_pet.this.id}"
  resource_group_name = azurerm_resource_group.this.name
}

module "this" {
  #checkov:skip=CKV_AZURE_34:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV_AZURE_35:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_20:It's a known issue that Checkov cannot work prefect along with module
  #checkov:skip=CKV2_AZURE_21:It's a known issue that Checkov cannot work prefect along with module
  source = "../.."

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
  storage_account_account_kind             = "StorageV2"
  storage_account_location                 = azurerm_resource_group.this.location
  storage_account_name                     = "tfmodstoracc${random_pet.this.id}"
  storage_account_resource_group_name      = azurerm_resource_group.this.name
  storage_account_min_tls_version          = "TLS1_2"
  storage_account_network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = [local.public_ip]
  }
  storage_account_identity = {
    identity_ids = {
      msi = azurerm_user_assigned_identity.this.id
    }
    type = "UserAssigned"
  }
  storage_account_customer_managed_key = {
    key_name     = azurerm_key_vault_key.storage_key.name
    key_vault_id = azurerm_key_vault.storage_vault.id
  }
  key_vault_access_policy = {
    msi = {
      identity_principle_id = azurerm_user_assigned_identity.this.principal_id
      identity_tenant_id    = azurerm_user_assigned_identity.this.tenant_id
    }
  }
  storage_container = {
    blob_container = {
      name                  = "blob-container-${random_pet.this.id}"
      container_access_type = "private"
    }
  }
  storage_queue = {
    queue0 = {
      name = "queue-${random_pet.this.id}"
    }
  }
  storage_table = {
    table0 = {
      name = "table${random_pet.this.id}"
    }
  }
}
