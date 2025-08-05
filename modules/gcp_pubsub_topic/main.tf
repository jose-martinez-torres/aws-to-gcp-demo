# This module provisions the data ingestion endpoint for the GCP data pipeline.
# It creates a Google Cloud Pub/Sub Topic that applications can publish messages to.
# This is the GCP equivalent of the aws_sns_topic resource.
# The "subscription" logic is handled by the consumer (e.g., the Dataflow job),
# which is granted IAM permissions to read from this topic.

resource "google_pubsub_topic" "data_events" {
  project = var.gcp_project_id
  name    = "gcp-data-events-topic-${var.unique_suffix}"
  labels  = var.labels
}