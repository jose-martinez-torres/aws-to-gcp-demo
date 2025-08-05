variable "gcp_project_id" {
  description = "The GCP project ID to create resources in."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to create resources in."
  type        = string
  default     = "us-east1"
}

variable "unique_suffix" {
  description = "A unique suffix to append to all resource names to ensure uniqueness."
  type        = string
  default     = "gcp_iac"
}

variable "resource_labels" {
  description = "A map of labels to apply to all resources for organization and cost tracking."
  type        = map(string)
  default = {
    "managed-by"  = "terraform"
    "environment" = "demo"
  }
}