output "pubsub_topic_id" {
  description = "The ID of the Pub/Sub topic to publish messages to."
  value       = module.pubsub_to_gcs_pipeline.topic_id
}

output "gcs_bucket_name" {
  description = "The name of the GCS bucket where data is stored."
  value       = module.gcs_data_lake_bucket.bucket_name
}

output "gcloud_pubsub_publish_suggestion" {
  description = "A sample gcloud command to publish a message to the topic."
  value       = "gcloud pubsub topics publish ${module.pubsub_to_gcs_pipeline.topic_id} --message '{\"stock_ticker\": \"GOOG\", \"trade_type\": \"BUY\", \"quantity\": 100, \"trade_price\": 175.50}'"
}