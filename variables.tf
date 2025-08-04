variable "gcp_project_id" {
  description = "The GCP project ID to create resources in."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to create resources in."
  type        = string
  default     = "us-east1"
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "unique_suffix" {
  description = "A unique suffix to append to all resource names to ensure uniqueness."
  type        = string
  default     = "aws-iac"
}
