
########## Az Network ##########
# resource "azurerm_resource_group" "example" {
#   name     = "example-resources"
#   location = "West Europe"
# }

# resource "azurerm_network_security_group" "example" {
#   name                = "acceptanceTestSecurityGroup1"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
# }

# resource "azurerm_network_ddos_protection_plan" "example" {
#   name                = "ddospplan1"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
# }

# resource "azurerm_virtual_network" "example" {
#   name                = "virtualNetwork1"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   ddos_protection_plan {
#     id     = azurerm_network_ddos_protection_plan.example.id
#     enable = true
#   }

#   subnet {
#     name           = "subnet1"
#     address_prefix = "10.0.1.0/24"
#   }

#   subnet {
#     name           = "subnet2"
#     address_prefix = "10.0.2.0/24"
#   }

#   subnet {
#     name           = "subnet3"
#     address_prefix = "10.0.3.0/24"
#     security_group = azurerm_network_security_group.example.id
#   }

#   tags = {
#     environment = "Production"
#   }
# }

locals {
  publish_code_command = "az webapp deployment source config-zip --resource-group amzgrocerystorerg --name ${azurerm_function_app.func-app.name} --src function-app.zip --debug"
}

locals {
  sleep_command = "sleep 60"
}

########## Az Function ##########

provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "st-func-app" {
  name                      = "funcstorage15453212"
  resource_group_name       = "amzgrocerystorerg"
  location                  = "East US"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "funcdeploy" {
  name                  = "contents"
  storage_account_name  = azurerm_storage_account.st-func-app.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "func-app-plan" {
  name                = "func-app"
  resource_group_name = "amzgrocerystorerg"
  location            = "East US"
  kind                = "FunctionApp"
  reserved            = "true"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  depends_on = [
    azurerm_storage_account.st-func-app,
    azurerm_storage_container.funcdeploy
  ]

}

resource "azurerm_function_app" "func-app" {

  name                       = "func-py"
  location                   = "East US"
  resource_group_name        = "amzgrocerystorerg"
  app_service_plan_id        = azurerm_app_service_plan.func-app-plan.id
  storage_account_name       = azurerm_storage_account.st-func-app.name
  storage_account_access_key = azurerm_storage_account.st-func-app.primary_access_key
  version                    = "~3"
  os_type                    = "linux"
  app_settings = {
    # WEBSITE_RUN_FROM_ZIP           = "https://${azurerm_storage_account.st-func-app.name}.blob.core.windows.net/${azurerm_storage_container.funcdeploy.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.sas.sas}",
    https_only                     = true
    FUNCTIONS_WORKER_RUNTIME       = "python"
    FUNCTION_APP_EDIT_MODE         = "readonly"
    storage_name                   = azurerm_storage_account.st-func-app.name
    HASH                           = base64encode(filesha256("./function-app.zip"))
    AzureStringConnection          = azurerm_storage_account.st-func-app.primary_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insights.instrumentation_key
  }

  site_config { 
    linux_fx_version          = "PYTHON|3.9"
    use_32_bit_worker_process = false
    ftps_state                = "Disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  #   depends_on = [
  #     null_resource.run-python,
  #     null_resource.run-python-venv
  #   ]

}

resource "null_resource" "function_app_publish" {
  
  provisioner "local-exec" {
    command = local.sleep_command
  }
  provisioner "local-exec" {
    command = local.publish_code_command
  }
  
  depends_on = [local.publish_code_command, local.sleep_command]
  triggers = {
    sleep_command        = local.sleep_command
    input_json           = "./function-app.zip"
    publish_code_command = local.publish_code_command
  }
}

# resource "null_resource" "functions" {

#   provisioner "local-exec" {
#     command = "cd function-app; func azure functionapp publish ${azurerm_function_app.func-app.name}; cd ../"
#   }

# }

# resource "null_resource" "run-python" {
#   provisioner "local-exec" {
#     command = <<EOH
#       cd function-app
#       pip install -r requirements.txt
#   EOH
#   }
# }

# resource "null_resource" "run-python-venv" {
#   provisioner "local-exec" {
#     command = <<EOH
#       . .venv/bin/activate
#       cd function-app
#       pip install -r requirements.txt
#   EOH
#   }
# }

resource "azurerm_application_insights" "application_insights" {
  name                = "func-py-application-insights"
  location            = "East US"
  resource_group_name = "amzgrocerystorerg"
  application_type    = "web"

  depends_on = [
    azurerm_app_service_plan.func-app-plan
  ]
}

resource "azurerm_role_assignment" "storage" {
  scope                = azurerm_storage_account.st-func-app.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_function_app.func-app.identity[0].principal_id
  depends_on = [
    azurerm_function_app.func-app
  ]
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "./function-app"
  output_path = "function-app.zip"
}

resource "azurerm_storage_blob" "storage_blob" {
  name                   = "functionapp.zip"
  storage_account_name   = azurerm_storage_account.st-func-app.name
  storage_container_name = azurerm_storage_container.funcdeploy.name
  type                   = "Block"
  source                 = "function-app.zip"
}

data "azurerm_storage_account_blob_container_sas" "sas" {
  connection_string = azurerm_storage_account.st-func-app.primary_connection_string
  container_name    = azurerm_storage_container.funcdeploy.name

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
