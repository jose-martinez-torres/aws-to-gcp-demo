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
}

# Module 2: Pub/Sub Topic for Data Ingestion (The Source)
# This module creates the entry point for the pipeline:
# - A Pub/Sub topic where applications can publish data messages.
module "gcp_pubsub_topic" {
  source = "./modules/gcp_pubsub_topic"

  unique_suffix = var.unique_suffix
}

# Module 3: Dataflow Pipeline (The Pipe)
# This module creates the data pipeline that connects the source to the destination.
# It launches a Dataflow job using a Google-provided template to stream data
# from the Pub/Sub topic to the GCS bucket.
module "gcp_dataflow_pipeline" {
  source = "./modules/gcp_dataflow_pipeline"

  unique_suffix   = var.unique_suffix
  pubsub_topic_id = module.gcp_pubsub_topic.topic_id
  gcs_output_path = module.gcp_data_lake.gcs_bucket_path
  gcs_temp_path   = "${module.gcp_data_lake.gcs_bucket_path}/temp"
}