

variable "env" {
  type = string
  description = "Environment identifier"
  default = "dev"
}

variable "prefix" {
  type = string
  description = "Short prefix for all the resource names"
}


variable "location" {
  type        = string
  description = "Location"
  default     = "northeurope"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  
}
variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  
}
variable "sleep_after_script" {
  type        = string
  description = "Sleep after script execution"
  default     = "60s"
}