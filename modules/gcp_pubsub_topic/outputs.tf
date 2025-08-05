output "topic_id" {
  description = "The fully qualified ID of the Pub/Sub topic."
  value       = google_pubsub_topic.topic.id
}