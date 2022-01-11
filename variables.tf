variable "resource_group_name" {
  description = "Azure Resource Group"
  type        = string
  default     = "amzgrocerystorerg"
}

variable "location" {
  description = "value"
  type        = string
  default     = "East US"

}

variable "storage_account_name" {
  type        = string
  description = "(optional) describe your variable"
  default     = "sa"
}

variable "storage_container_name" {
  description = "value"
  default     = "stcont"
}

variable "service_plan_name" {
  default = "serviceplan"
}

variable "function_name" {
  default = "function"
}

variable "app_insights_name" {
  default = "appinsights"
}

variable "blob_name" {
  default = "blob"
}

variable "project_name" {
  type    = string
  default = "fdp"
}
