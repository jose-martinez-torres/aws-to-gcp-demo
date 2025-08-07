# --- main.tf for pubsub_to_gcs module ---

# 1. Create the Pub/Sub topic that will be the entry point for data.
resource "google_pubsub_topic" "topic" {
  name = "data-ingestion-topic-${var.unique_suffix}"
}

# 2. Get project details, specifically the project number.
# The Pub/Sub service account's name is derived from the project number,
# so we need to fetch it.
data "google_project" "project" {
  project_id = var.project_id
}

# 3. Grant the Pub/Sub service account permission to write to the GCS bucket.
# Without this, the subscription will fail to create.
# The service account needs both Object Creator and Legacy Bucket Reader roles.
resource "google_storage_bucket_iam_member" "pubsub_object_creator" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "pubsub_bucket_reader" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# 4. Create the Pub/Sub subscription that writes directly to Cloud Storage.
resource "google_pubsub_subscription" "gcs_subscription" {
  name  = "gcs-landing-sub-${var.unique_suffix}"
  topic = google_pubsub_topic.topic.name

  # This block configures the subscription to write to GCS.
  cloud_storage_config {
    bucket = var.gcs_bucket_name

    # Define how files are created in the bucket.
    # Here, we create a new file every 5 minutes or if it reaches 10MB.
    max_duration = "300s"
    max_bytes    = 10485760 # 10 MiB

    # Organize output files in the bucket.
    filename_prefix = "raw-events/"
    filename_suffix = ".json"
  }

  # Ensure the IAM permission is created before the subscription attempts to validate it.
  depends_on = [
    google_storage_bucket_iam_member.pubsub_object_creator,
    google_storage_bucket_iam_member.pubsub_bucket_reader
  ]
}