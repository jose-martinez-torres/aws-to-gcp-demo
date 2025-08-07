# --- 1. Google Cloud Storage (GCS) Bucket ---
# This resource creates a GCS bucket to act as the raw data lake storage.
# Data from the pipeline will be landed here as JSON files.
resource "google_storage_bucket" "datalake" {
  project      = var.project_id
  name         = "${var.project_id}-datalake-bucket-${var.unique_suffix}"
  location     = var.location
  force_destroy = true # Recommended for demo environments to allow easy cleanup

  uniform_bucket_level_access = true
}

# --- 2. BigQuery Dataset ---
# This resource creates a BigQuery Dataset, which is a container for tables,
# views, and other BigQuery resources. It's analogous to a database schema.
resource "google_bigquery_dataset" "datalake" {
  project    = var.project_id
  dataset_id = "datalake_${replace(var.unique_suffix, "-", "_")}"
  location   = var.location

  # Allows the dataset to be deleted even if it contains tables.
  delete_contents_on_destroy = true
}

# --- 3. BigQuery External Table ---
# This resource creates an external table in BigQuery that points directly
# to the data stored in the GCS bucket. This allows querying the data in place
# without loading it into BigQuery, similar to AWS Glue Catalog + Athena.
resource "google_bigquery_table" "external_user_events" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.datalake.dataset_id
  table_id   = "user_events"

  # Allows the table to be deleted without manual intervention.
  deletion_protection = false

  external_data_configuration {
    source_uris = [
      "${google_storage_bucket.datalake.url}/*" # Point to all files in the bucket
    ]
    source_format = "NEWLINE_DELIMITED_JSON"
    autodetect    = false # We are providing a schema below

    # Define the schema for the JSON data, similar to the original Glue table.
    schema = jsonencode([
      { "name" : "user_id", "type" : "STRING", "mode" : "NULLABLE" },
      { "name" : "event_type", "type" : "STRING", "mode" : "NULLABLE" },
      { "name" : "timestamp", "type" : "TIMESTAMP", "mode" : "NULLABLE" }
    ])
  }
}