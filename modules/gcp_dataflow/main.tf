# This module provisions the data pipeline using Google Cloud Dataflow.
# It is the GCP equivalent of the aws_kinesis_firehose_delivery_stream module.
# It creates:
# 1. A Service Account for the Dataflow job to use.
# 2. IAM bindings to grant the pre-existing Service Account necessary permissions.
# 3. The Dataflow job itself, which reads from Pub/Sub and writes raw JSON messages
#    to a GCS data lake bucket.

# --- IAM Permissions for Dataflow ---
# Creates the identity and permissions that the Dataflow service will use.
# The service account is now expected to be created outside of this module.

# Data source to get the project number, needed for the Dataflow service agent principal.
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# Data source to look up the full details of the pre-existing service account.
data "google_service_account" "dataflow_sa" {
  account_id = var.dataflow_service_account_email
}

# Allows the Dataflow SA to consume messages from the Pub/Sub topic.
resource "google_pubsub_topic_iam_member" "dataflow_sub_binding" {
  topic   = var.pubsub_topic_name
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${var.dataflow_service_account_email}"
}

# Allows the Dataflow SA to write data files and temp files to the GCS bucket.
resource "google_storage_bucket_iam_member" "dataflow_storage_binding" {
  bucket = var.gcs_data_bucket_name # The bucket is used for output, temp, and schema
  # roles/storage.objectUser is a more constrained role than objectAdmin.
  # It allows creating, reading, and deleting objects, which is sufficient for Dataflow.
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${var.dataflow_service_account_email}"
}

# Allows the Dataflow service agent to impersonate the custom service account.
# This is a critical permission that allows the Dataflow service to launch the job with your SA's identity.
resource "google_service_account_iam_member" "dataflow_service_agent_binding" {
  service_account_id = data.google_service_account.dataflow_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.project.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
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
  service_account_email = var.dataflow_service_account_email
  labels                = var.labels

  parameters = {
    inputTopic           = var.pubsub_topic_name
    outputDirectory      = var.gcs_output_directory
    outputFilenamePrefix = "event-data-" # The prefix for output files.
  }

  # Setting this allows Terraform to manage the job without trying to stop it on every plan.
  on_delete = "cancel"
}
