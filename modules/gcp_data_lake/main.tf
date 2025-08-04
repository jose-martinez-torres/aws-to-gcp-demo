# This module provisions the foundational components for a GCP Data Lake:
# 1. A Google Cloud Storage (GCS) bucket for raw data storage.
# 2. Google BigQuery resources (dataset and table) to provide a queryable schema
#    over the data in GCS. This creates a logical "data lake" pattern.

# --- GCS Data Lake Storage ---
# The following resources create and configure the GCS bucket that will serve as the
# primary storage for the data lake. It includes security settings and versioning.

# Creates the GCS bucket. This is the physical storage location for the data.
# This is the direct equivalent of the aws_s3_bucket resource.
resource "google_storage_bucket" "data_lake" {
  name     = "gcp-datalake-bucket-${var.unique_suffix}"
  location = "US" # Using a multi-region for high availability.

  # Enforces security best practices by preventing per-object ACLs.
  # This is analogous to the aws_s3_bucket_public_access_block resource.
  uniform_bucket_level_access = true

  # Enables versioning on the bucket to protect against accidental data deletion or overwrites.
  versioning {
    enabled = true
  }
}

# --- BigQuery Data Catalog ---
# The following resources create the metadata layer for the data lake.
# This allows BigQuery to understand the structure of the data stored in GCS
# and query it in place using standard SQL.

# Creates a BigQuery Dataset, which acts as a logical container for tables.
# This is the direct equivalent of the aws_glue_catalog_database.
resource "google_bigquery_dataset" "events_db" {
  dataset_id = "gcp_events_database_${var.unique_suffix}"
  location   = "US" # For external tables, the dataset location must match the GCS bucket location.
}

# Creates a BigQuery External Table.
# This defines the schema for the data that will be stored in GCS, making it queryable.
# This is the direct equivalent of the aws_glue_catalog_table.
resource "google_bigquery_table" "events_table" {
  dataset_id = google_bigquery_dataset.events_db.dataset_id
  table_id   = "gcp_events_table_${var.unique_suffix}"

  # Defines this as an external table, meaning the data resides outside BigQuery (in GCS).
  external_data_configuration {
    autodetect    = true # Allows BigQuery to infer the schema from the source data.
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris = [
      # The "*" is a wildcard that tells BigQuery to read all files in this "directory".
      # The Dataflow job will write data to this path.
      "${google_storage_bucket.data_lake.url}/data/*"
    ]
  }
}