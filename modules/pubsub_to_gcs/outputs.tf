output "topic_id" {
  description = "The full ID of the Pub/Sub topic."
  value       = google_pubsub_topic.topic.id
}