# --- 1. Pub/Sub Topic ---
# This resource creates the Pub/Sub topic that will serve as the entry point
# for the data pipeline, equivalent to the original SNS topic.
resource "google_pubsub_topic" "ingestion_topic" {
  project = var.project_id
  name    = "user-events-topic-${var.unique_suffix}"
}

# Configure the google-beta provider
provider "google-beta" {
  project = var.project_id
  region  = var.project_id
}

# --- 2. Grant Pub/Sub Service Account Permissions to write to GCS ---
# Before creating the subscription, we must grant the Pub/Sub service account
# the necessary permissions to write objects to the target GCS bucket.

# First, get the special service account that Pub/Sub uses for this project.
resource "google_project_service_identity" "pubsub_sa" {
  project = var.project_id
  provider = google-beta
  service = "pubsub"
}

# Then, grant the "Storage Object Creator" role to that service account on the bucket.
resource "google_storage_bucket_iam_member" "pubsub_writer" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${data.google_project_service_identity.pubsub_sa.email}"
}

# --- 3. Pub/Sub Subscription with Cloud Storage Sink ---
# This resource creates a subscription that automatically writes messages
# from the topic to the GCS bucket. This is the direct replacement for
# the Kinesis Firehose stream.
resource "google_pubsub_subscription" "gcs_sink" {
  project = var.project_id
  name    = "user-events-to-gcs-sink-${var.unique_suffix}"
  topic   = google_pubsub_topic.ingestion_topic.name

  # This subscription will never be pulled from by a client, so a long
  # ack deadline is fine.
  ack_deadline_seconds = 600

  cloud_storage_config {
    bucket          = var.gcs_bucket_name
    filename_prefix = "events/" # Optional: organize files into a sub-directory

    # Define how files are created in GCS (analogous to Firehose buffering)
    max_duration = "300s"     # Create a new file every 5 minutes
    max_bytes    = 10485760 # Or when the file reaches 10MB

  }

  # This subscription depends on the IAM binding being in place first.
  depends_on = [google_storage_bucket_iam_member.pubsub_writer]
}