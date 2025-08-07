variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "unique_suffix" {
  description = "A unique suffix for resource names."
  type        = string
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket to sink messages to."
  type        = string
}