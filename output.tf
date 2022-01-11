output "function_app_name" {
  value       = azurerm_function_app.azfunction.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value       = azurerm_function_app.azfunction.default_hostname
  description = "Deployed function app hostname"
}