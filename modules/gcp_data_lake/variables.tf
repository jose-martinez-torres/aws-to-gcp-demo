variable "unique_suffix" {
  description = "A unique suffix to append to resource names for uniqueness."
  type        = string
}

variable "location" {
  description = "The GCP location (region or multi-region) for the GCS bucket and BigQuery dataset."
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to the resources."
  type        = map(string)
  default     = {}
}

variable "force_destroy_bucket" {
  description = "A boolean to control whether the bucket can be destroyed even if it contains objects. Should be false in production."
  type        = bool
  default     = false
}
