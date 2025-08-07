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
  name     = "gcp_datalake_bucket_${var.unique_suffix}"
  location = var.location # Can be a region like "us-east1" or multi-region like "US"
  labels   = var.labels

  # Enforces security best practices by preventing per-object ACLs.
  # This is analogous to the aws_s3_bucket_public_access_block resource.
  uniform_bucket_level_access = true

  # Setting force_destroy to true is useful for ephemeral environments.
  force_destroy = var.force_destroy_bucket

  # Enables versioning on the bucket to protect against accidental data deletion or overwrites.
  versioning {
    enabled = true
  }

  # Adds a lifecycle rule to manage storage costs.
  # After 90 days, data is moved to cheaper Nearline storage.
  # After 365 days, data is deleted. These values should be adjusted
  # based on business and compliance requirements.
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# --- BigQuery Data Catalog ---
# The following resources create the metadata layer for the data lake.
# This allows BigQuery to understand the structure of the data stored in GCS
# and query it in place using standard SQL.

# Creates a BigQuery Dataset, which acts as a logical container for tables.
# This is the direct equivalent of the aws_glue_catalog_database.
resource "google_bigquery_dataset" "events_db" {
  # BigQuery Dataset IDs cannot contain hyphens. We replace them with underscores
  # to ensure compatibility, as hyphens are common in resource naming.
  dataset_id = "gcp_events_database_${replace(var.unique_suffix, "-", "_")}"
  labels     = var.labels
  location   = var.location # For external tables, the dataset location must match the GCS bucket location.
}
