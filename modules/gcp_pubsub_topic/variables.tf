variable "unique_suffix" {
  description = "A unique suffix to append to the resource name for uniqueness."
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to the topic."
  type        = map(string)
  default     = {}
}
