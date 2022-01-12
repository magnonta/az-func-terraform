resource "azurerm_storage_account" "storageaccount" {
  # name                      = "${var.project_name}+${var.storage_account_name}+${random_integer.random.result}"
  name                      = "storagefunc1218437"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
  tags = {
    platform = "fdp"
  }
}

resource "azurerm_storage_container" "storagecontainer" {
  # name                  = "${var.project_name}+${var.storage_container_name}+${random_integer.random.result}"
  name                  = "container-func"
  storage_account_name  = azurerm_storage_account.storageaccount.name
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "netrules" {
  resource_group_name  = var.resource_group_name
  storage_account_name = azurerm_storage_account.storageaccount.name

  default_action = "Deny"
  bypass = [
    "AzureServices"
  ]

  depends_on = [
    azurerm_storage_container.storagecontainer,
  ]
}

resource "azurerm_app_service_plan" "functionplan" {
  # name                = "${var.project_name}+${var.service_plan_name}+${random_integer.random.result}"
  name                = "plan-func-teste"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FunctionApp"
  reserved            = "true"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  depends_on = [
    azurerm_storage_account.storageaccount,
    azurerm_storage_container.storagecontainer
  ]

  tags = {
    platform = "fdp"
  }

}

resource "azurerm_function_app" "azfunction" {

  # name                       = "${var.project_name}+${var.function_name}+${random_integer.random.result}"
  name                       = "func-teste1"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.functionplan.id
  storage_account_name       = azurerm_storage_account.storageaccount.name
  storage_account_access_key = azurerm_storage_account.storageaccount.primary_access_key
  version                    = "~3"
  os_type                    = "linux"
  app_settings = {
    https_only               = true
    FUNCTIONS_WORKER_RUNTIME = "python"
    FUNCTION_APP_EDIT_MODE   = "readonly"
    storage_name             = azurerm_storage_account.storageaccount.name
  }

  site_config {
    linux_fx_version          = "PYTHON|3.9"
    use_32_bit_worker_process = false
    ftps_state                = "Disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    platform = "fdp"
  }

}

resource "azurerm_role_assignment" "storage" {
  scope                = azurerm_storage_account.storageaccount.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_function_app.azfunction.identity[0].principal_id
  depends_on = [
    azurerm_function_app.azfunction
  ]
}

resource "azurerm_role_assignment" "data-contributor-role" {
  scope                = azurerm_storage_container.storagecontainer.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_function_app.azfunction.identity[0].principal_id
  depends_on = [
    azurerm_function_app.azfunction
  ]

}

resource "azurerm_storage_blob" "storage_blob" {
  # name                   = "${var.project_name}+${var.blob_name}+${random_integer.random.result}"
  name                   = "blob-func-teste"
  storage_account_name   = azurerm_storage_account.storageaccount.name
  storage_container_name = azurerm_storage_container.storagecontainer.name
  type                   = "Block"
  # source                 = "function-app.zip"
}

data "azurerm_storage_account_blob_container_sas" "sas" {
  connection_string = azurerm_storage_account.storageaccount.primary_connection_string
  container_name    = azurerm_storage_container.storagecontainer.name

  start  = "2022-01-01T00:00:00Z"
  expiry = "2023-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }

}

data "azurerm_storage_account_sas" "account_sas" {
  connection_string = azurerm_storage_account.storageaccount.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = true
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2022-03-21T00:00:00Z"
  expiry = "2022-12-21T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }

  depends_on = [
    azurerm_storage_container.storagecontainer
  ]
}
