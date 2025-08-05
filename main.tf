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

# Module 3: Dataflow Parquet Pipeline (The GCP equivalent of Kinesis Firehose)
# This module creates the data pipeline that connects the source to the destination,
# performing a JSON-to-Parquet conversion, similar to the original AWS Firehose stream.
module "gcp_dataflow" {
  source = "./modules/gcp_dataflow"

  unique_suffix          = var.unique_suffix
  gcp_region             = var.gcp_region
  gcp_project_id         = var.gcp_project_id
  pubsub_topic_name      = module.gcp_pubsub_topic.topic_id
  gcs_output_directory   = "${module.gcp_data_lake.gcs_bucket_path}/data-parquet"
  gcs_temp_location      = "${module.gcp_data_lake.gcs_bucket_path}/temp"
  gcs_data_bucket_name   = module.gcp_data_lake.gcs_bucket_name
  schema_content         = file("${path.module}/schema/event_schema.json")
  labels                 = var.resource_labels
}

# Resource: BigQuery External Table (The Query Layer)
# This resource is defined in the root module because it connects the storage
# layer (from gcp_data_lake) with the data format produced by the dataflow pipeline.
resource "google_bigquery_table" "parquet_external_table" {
  project    = var.gcp_project_id
  dataset_id = module.gcp_data_lake.bigquery_dataset_id
  table_id   = "events_parquet_${var.unique_suffix}"

  external_data_configuration {
    source_format = "PARQUET"
    source_uris   = ["${module.gcp_data_lake.gcs_bucket_path}/data-parquet/**"]
    autodetect    = false
    # Use an explicit schema for production-grade reliability.
    schema = file("${path.module}/bigquery_schema.json")
  }

  labels = var.resource_labels
}