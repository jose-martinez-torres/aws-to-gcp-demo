output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic to publish messages to."
  value       = google_pubsub_topic.ingestion_topic.name
}