output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic to publish messages to."
  value       = module.pubsub_to_gcs.pubsub_topic_name
}

output "gcs_bucket_name" {
  description = "The name of the GCS bucket where data is stored."
  value       = module.gcp_data_lake.gcs_bucket_name
}

output "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = module.gcp_data_lake.bigquery_dataset_id
}

output "bigquery_table_name" {
  description = "The name of the BigQuery external table."
  value       = module.gcp_data_lake.bigquery_table_id
}

output "bigquery_query_suggestion" {
  description = "A sample BigQuery query to run in the GCP console."
  value       = "SELECT * FROM `${module.gcp_data_lake.bigquery_table_full_id_for_query}` LIMIT 10"
}