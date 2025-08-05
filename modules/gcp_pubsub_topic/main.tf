# This module creates a single Google Pub/Sub topic.

variable "unique_suffix" {
  description = "A unique suffix to append to the topic name."
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to the topic."
  type        = map(string)
}

resource "google_pubsub_topic" "topic" {
  name   = "gcp-events-topic-${var.unique_suffix}"
  labels = var.labels
}