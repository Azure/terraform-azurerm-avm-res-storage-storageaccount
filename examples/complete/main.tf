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
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = "7fa7c11f-8a64-4f17-8c79-163fa82f5a36"
      skip_service_principal_aad_check = false
    },

  }

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
    blob_container1 = {
      name                  = "blob-container-${random_pet.this.id}-1"
      container_access_type = "private"
    }
    blob_container2 = {
      name                  = "blob-container-${random_pet.this.id}-2"
      container_access_type = "private"
    }
    blob_container3 = {
      name                  = "blob-container-${random_pet.this.id}-3"
      container_access_type = "private"
    }
  }
  storage_queue = {
    queue1 = {
      name = "queue-${random_pet.this.id}-1"
    }
    queue2 = {
      name = "queue-${random_pet.this.id}-2"
    }
    queue3 = {
      name = "queue-${random_pet.this.id}-3"
    }
  }
  storage_table = {
    table0 = {
      name = "table${random_pet.this.id}a"
    }
    table1 = {
      name = "table${random_pet.this.id}b"
    }

  }
  storage_share = {
    share1 = {
      name  = "share-${random_pet.this.id}-1"
      quota = 50
    }
    share2 = {
      name  = "share-${random_pet.this.id}-2"
      quota = 50
    }
  }

  diagnostic_settings_blob = {
    blob11 = {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
      category_group             = ["audit", "alllogs"]
      metric_categories          = ["AllMetrics"]

    }

  }
  diagnostic_settings_queue = {
    queue = {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
      category_group             = ["audit", "alllogs"]
      metric_categories          = ["AllMetrics"]

    }

  }
  diagnostic_settings_table = {
    queue = {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
      category_group             = ["audit", "alllogs"]
      metric_categories          = ["AllMetrics"]

    }

  }

  diagnostic_settings_file = {
    queue = {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
      category_group             = ["audit", "alllogs"]
      metric_categories          = ["AllMetrics"]

    }

  }
}

