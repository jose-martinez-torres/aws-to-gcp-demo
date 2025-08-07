# This file is the main entrypoint for the Terraform configuration.
# It defines the providers and orchestrates the creation of resources
# by calling reusable modules.
# This configuration creates a data pipeline in GCP: Pub/Sub -> Cloud Storage.
terraform {
  backend "gcs" {
    bucket = "iac-accel-tfstate"
    prefix = "gcp-sample/terraform.tfstate"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Cloud provider.
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Module Definitions ---

# Module 1: Data Lake Storage
# This module creates the foundational storage component:
# - A Google Cloud Storage (GCS) bucket to serve as the data lake.
module "gcs_data_lake_bucket" {
  source = "./modules/gcs_bucket"

  unique_suffix = var.unique_suffix
  gcp_region    = var.gcp_region
}

# Module 2: Pub/Sub to Cloud Storage Pipeline
# This module creates the entry point and delivery mechanism for the pipeline:
# - A Pub/Sub topic where applications can publish data messages.
# - A Pub/Sub subscription that automatically writes messages from the topic to the GCS bucket.
module "pubsub_to_gcs_pipeline" {
  source = "./modules/pubsub_to_gcs"

  project_id = var.gcp_project_id
  unique_suffix   = var.unique_suffix
  gcs_bucket_name = module.gcs_data_lake_bucket.bucket_name
}