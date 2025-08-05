output "topic_id" {
  description = "The full ID of the Pub/Sub topic (e.g., projects/PROJECT/topics/TOPIC)."
  value       = google_pubsub_topic.data_events.id
}