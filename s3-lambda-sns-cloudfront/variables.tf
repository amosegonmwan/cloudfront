variable "tags" {
  description = "Additional tags to add to all resources"
  type        = map(string)
  default = {
    Team      = "DevOps"
    ManagedBy = "Terraform"
  }
}

variable "sns_topic_name" {
  description = "The name prefix for the SNS topic."
  type        = string
}

variable "sns_topic_display_name" {
  description = "The display name for the SNS topic."
  type        = string
}

variable "sns_topic_subscriptions" {
  description = "List of maps with protocol, endpoint, and endpoint_auto_confirms to create SNS topic subscriptions for."
  type        = list(map(string))
}

variable "website_bucket" {
  description = "List of maps with protocol, endpoint, and endpoint_auto_confirms to create SNS topic subscriptions for."
  type        = string
}

variable "kms_master_key_id" {
  description = "The master key ID to use for encryption"
  type        = string
}

variable "log_bucket" {
  description = "List of maps with protocol, endpoint, and endpoint_auto_confirms to create SNS topic subscriptions for."
  type        = string
}





