output "gcs_bucket_name" {
  description = "The name of the GCS bucket."
  value       = google_storage_bucket.data_lake.name
}

output "gcs_bucket_path" {
  description = "The gs:// path to the GCS bucket, used by other GCP services."
  value       = google_storage_bucket.data_lake.url
}

output "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = google_bigquery_dataset.events_db.dataset_id
}

output "bigquery_table_id" {
  description = "The ID of the BigQuery table."
  value       = google_bigquery_table.events_table.table_id
}