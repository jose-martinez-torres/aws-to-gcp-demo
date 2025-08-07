output "gcs_bucket_name" {
  description = "The name of the GCS bucket for the data lake."
  value       = google_storage_bucket.datalake.name
}

output "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = google_bigquery_dataset.datalake.dataset_id
}

output "bigquery_table_id" {
  description = "The ID of the BigQuery external table."
  value       = google_bigquery_table.external_user_events.table_id
}

output "bigquery_table_full_id_for_query" {
  description = "The full ID of the BigQuery table, formatted for use in queries."
  value       = "${var.project_id}.${google_bigquery_dataset.datalake.dataset_id}.${google_bigquery_table.external_user_events.table_id}"
}