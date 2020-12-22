variable "project" {
  description = "Name of the GCP project"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "functions" {
  description = "List of google_cloudfunctions_function."
  type = list(object({
    name                = string
    available_memory_mb = number
    timeout             = number
  }))
}

variable "notification_channels" {
  description = "List of notification_channels."
  type        = list(string)
}

variable "overrides" {
  type        = any
  default     = {}
  description = "Override parameters for each alarm. The key must match snake cased alarm resource id, e.g. cpu_utilization_high. See main.tf for which parameters are overridable for each alarm."
}
