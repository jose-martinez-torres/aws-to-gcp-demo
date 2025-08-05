variable "gcp_project_id" {
  description = "The GCP project ID where the Pub/Sub topic will be created."
  type        = string
}

variable "unique_suffix" {
  description = "A unique suffix to append to all resource names to ensure uniqueness."
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to the Pub/Sub topic."
  type        = map(string)
  default     = {}
}