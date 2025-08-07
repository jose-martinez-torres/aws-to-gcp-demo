variable "unique_suffix" {
  description = "A unique suffix to append to the bucket name."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to create the bucket in."
  type        = string
  default     = "us-east1"
}