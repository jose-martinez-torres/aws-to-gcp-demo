output "bucket_name" {
  description = "The name of the GCS bucket."
  value       = google_storage_bucket.data_lake_bucket.name
}
