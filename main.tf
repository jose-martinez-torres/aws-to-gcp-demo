# This file is the main entrypoint for the Terraform configuration.
# It defines the providers and orchestrates the creation of resources
# by calling reusable modules.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.25"
    }
  }
}

# Configure the Google Cloud provider.
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Module Definitions ---

# Module 1: GCP Data Lake Foundation (The Destination)
# This module creates the foundational components:
# - A Google Cloud Storage (GCS) bucket for raw data storage.
# - A BigQuery dataset and an external table to provide a schema over the GCS data.
module "gcp_data_lake" {
  source = "./modules/gcp_data_lake"
  
  unique_suffix = var.unique_suffix
  gcp_location  = var.gcp_region
  labels        = var.resource_labels
}

# Module 2: Pub/Sub Topic for Data Ingestion (The Source)
# This module creates the entry point for the pipeline:
# - A Pub/Sub topic where applications can publish data messages.
module "gcp_pubsub_topic" {
  source = "./modules/gcp_pubsub_topic"

  gcp_project_id = var.gcp_project_id
  unique_suffix = var.unique_suffix
  labels        = var.resource_labels
}

# Resource: BigQuery Native Table (The Destination)
# This is a native BigQuery table that will store the data pushed from Pub/Sub.
resource "google_bigquery_table" "json_native_table" {
  project    = var.gcp_project_id
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
}