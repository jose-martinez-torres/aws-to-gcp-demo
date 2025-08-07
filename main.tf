# This file is the main entrypoint for the Terraform configuration.
# It defines the providers and orchestrates the creation of resources
# by calling reusable modules for the GCP equivalent pipeline.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "iac-accel-tfstate"
    prefix = "gcp-sample/terraform.tfstate"
  }
}

# Configure the Google Cloud provider with the specified project and region.
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Module Definitions ---

# Module 1: GCP Data Lake Storage and Catalog
# This module creates the foundational components for the GCP data lake:
# - A Google Cloud Storage (GCS) bucket to serve as the data lake storage.
# - A BigQuery Dataset to organize tables.
# - A BigQuery External Table to define the schema and query data directly from GCS.
module "gcp_data_lake" {
  source = "./modules/gcp_data_lake"

  project_id = var.gcp_project_id
  unique_suffix = var.unique_suffix
  location = var.gcp_region
}

# Module 2: Pub/Sub to GCS Ingestion Pipeline
# This module creates the data pipeline that ingests streaming data and delivers it to GCS.
# - A Pub/Sub topic where applications can publish data messages.
# - A Pub/Sub subscription with a Cloud Storage "sink" that automatically writes
#   messages from the topic to the GCS bucket created in the `gcp_data_lake` module.
module "pubsub_to_gcs" {
  source = "./modules/pubsub_to_gcs"

  project_id      = var.gcp_project_id
  unique_suffix   = var.unique_suffix
  gcs_bucket_name = module.gcp_data_lake.gcs_bucket_name
}