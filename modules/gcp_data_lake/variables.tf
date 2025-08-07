variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "unique_suffix" {
  description = "A unique suffix for resource names."
  type        = string
}

variable "location" {
  description = "The GCP location (region) for the resources."
  type        = string
}