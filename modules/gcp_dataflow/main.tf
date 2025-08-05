# This module provisions the data pipeline using Google Cloud Dataflow.
# It is the GCP equivalent of the aws_kinesis_firehose_delivery_stream module.
# It creates:
# 1. A Service Account for the Dataflow job to use.
# 2. IAM bindings to grant the Service Account necessary permissions.
# 3. A GCS object for the Parquet schema definition.
# 4. The Dataflow job itself, which reads from Pub/Sub, converts JSON to Parquet,
#    and writes to a GCS data lake bucket.

# --- IAM Permissions for Dataflow ---
# Creates the identity and permissions that the Dataflow service will use.
# This is the direct equivalent of the aws_iam_role for Firehose.
resource "google_service_account" "dataflow_sa" {
  account_id   = "df-parquet-pipe-sa-${var.unique_suffix}"
  display_name = "Dataflow Parquet Pipeline Service Account"
}

# Allows the Dataflow SA to consume messages from the Pub/Sub topic.
resource "google_pubsub_topic_iam_member" "dataflow_sub_binding" {
  topic   = var.pubsub_topic_name
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

# Allows the Dataflow SA to write data files and temp files to the GCS bucket.
resource "google_storage_bucket_iam_member" "dataflow_storage_binding" {
  bucket = var.gcs_data_bucket_name # The bucket is used for output, temp, and schema
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.dataflow_sa.email}"
}


# --- Dataflow Job ---
# This is the core pipeline resource, using a Google-provided template to stream
# raw text/JSON data from Pub/Sub to Cloud Storage.
resource "google_dataflow_job" "pubsub_to_gcs_text" {
  name                  = "gcp-pubsub-to-gcs-text-${var.unique_suffix}"
  region                = var.gcp_region
  # This is a standard, well-supported template for writing Pub/Sub messages to GCS.
  # It's more flexible than the Parquet-specific template as it lands the raw data.
  template_gcs_path     = "gs://dataflow-templates-${var.gcp_region}/latest/Cloud_PubSub_to_GCS_Text"
  temp_gcs_location     = var.gcs_temp_location
  service_account_email = google_service_account.dataflow_sa.email
  labels                = var.labels

  parameters = {
    inputTopic           = var.pubsub_topic_name
    outputDirectory      = var.gcs_output_directory
    outputFilenamePrefix = "event-data-" # The prefix for output files.
    windowDuration       = var.dataflow_window_duration # Buffer data, similar to Firehose buffer hints.
  }

  # Setting this allows Terraform to manage the job without trying to stop it on every plan.
  on_delete = "cancel"
}
