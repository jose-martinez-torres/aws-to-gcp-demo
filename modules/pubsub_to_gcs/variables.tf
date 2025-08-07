variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "unique_suffix" {
  description = "A unique suffix to append to resource names."
  type        = string
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket to write data to."
  type        = string
}