output "pubsub_topic_id" {
  description = "The ID of the Pub/Sub topic to publish messages to."
  value       = module.gcp_pubsub_topic.topic_id
}

output "gcs_bucket_name" {
  description = "The name of the GCS bucket where data is stored."
  value       = module.gcp_data_lake.gcs_bucket_name
}

output "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = module.gcp_data_lake.bigquery_dataset_id
}

output "bigquery_json_table_id" {
  description = "The ID of the BigQuery table for querying the raw JSON data."
  value       = google_bigquery_table.json_external_table.table_id
}

output "bigquery_query_suggestion" {
  description = "A sample BigQuery query to run in the GCP console."
  value       = "SELECT * FROM `${var.gcp_project_id}.${module.gcp_data_lake.bigquery_dataset_id}.${google_bigquery_table.json_external_table.table_id}` LIMIT 10"
}