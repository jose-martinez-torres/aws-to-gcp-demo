terraform {
  required_version = ">= 1.0"

  # Configure the GCS backend for storing Terraform state remotely.
  # This is crucial for team collaboration and state locking.
  backend "gcs" {
    bucket = "iac-accel-tfstate"
    prefix = "gcp-sample/terraform.tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0" 
    }
  }
}

# Default Google Cloud provider configuration for the primary region.
provider "google" {
  project = var.project_id
  region  = var.region
}


# --- Module Definitions ---

# Module 1: GCP Data Lake Foundation (The Destination)
# This module creates the foundational components:
# - A Google Cloud Storage (GCS) bucket for raw data storage.
# - A BigQuery dataset to contain our tables.
module "gcp_data_lake" {
  source = "./modules/gcp_data_lake"
  unique_suffix = var.unique_suffix
  
  location      = var.region
  labels        = var.resource_labels
}

# Module 2: Pub/Sub Topic for Data Ingestion (The Source)
# This module creates the entry point for the pipeline:
# - A Pub/Sub topic where applications can publish data messages.
module "gcp_pubsub_topic" {
  source = "./modules/gcp_pubsub_topic"

  gcp_project_id = var.project_id
  unique_suffix = var.unique_suffix
  labels        = var.resource_labels
}

# Resource: BigQuery Native Table (The Destination)
# This is a native BigQuery table that will store the data pushed from Pub/Sub.
resource "google_bigquery_table" "json_native_table" {
  project    = var.project_id
  dataset_id = module.gcp_data_lake.bigquery_dataset_id
  # BigQuery Table IDs cannot contain hyphens. We replace them with underscores
  # to ensure compatibility, as hyphens are common in resource naming.
  table_id   = "events_json_${replace(var.unique_suffix, "-", "_")}"
  labels     = var.resource_labels

  # Disable deletion protection, allowing Terraform to manage the table's lifecycle.
  deletion_protection = false

  # Use an explicit schema for production-grade reliability.
  schema = file("${path.module}/bigquery_schema.json")
}

# Data source to get the project number for constructing the Pub/Sub service account principal.
data "google_project" "project" {}

# Grant the Pub/Sub service account permissions to write to the BigQuery table.
# This is often handled automatically by GCP, but creating it explicitly can resolve
# race conditions and permission issues during initial creation.
resource "google_bigquery_table_iam_member" "pubsub_bq_writer" {
  project    = google_bigquery_table.json_native_table.project
  dataset_id = google_bigquery_table.json_native_table.dataset_id
  table_id   = google_bigquery_table.json_native_table.table_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# Introduce a delay to allow IAM permissions to propagate before creating the subscription.
# This helps prevent race conditions where the subscription is created before GCP
# recognizes that the Pub/Sub service account has write access to the BigQuery table.
resource "time_sleep" "wait_for_iam_propagation" {
  create_duration = "30s"
  depends_on      = [google_bigquery_table_iam_member.pubsub_bq_writer]
}

# Resource: Pub/Sub to BigQuery Push Subscription
# This subscription directly pushes messages from the topic to the BigQuery table.
resource "google_pubsub_subscription" "bigquery_push_subscription" {
  name  = "bq-push-subscription-${var.unique_suffix}"
  topic = module.gcp_pubsub_topic.topic_id

  bigquery_config {
    table = google_bigquery_table.json_native_table.id
    # If true, the subscription will write the message data as a string in a single `data` column.
    # If false, it will parse the JSON payload and map it to the table columns.
    use_topic_schema = false
    # If true, fields in the message that are not in the table schema will be dropped.
    drop_unknown_fields = true
  }

  # Explicitly depend on the IAM binding to ensure permissions are set before the subscription is created.
  depends_on = [time_sleep.wait_for_iam_propagation]
}