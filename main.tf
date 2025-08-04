# This file is the main entrypoint for the Terraform configuration.
# It defines the providers and orchestrates the creation of resources
# by calling reusable modules.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider with the specified region.
provider "aws" {
  region = var.aws_region
}

# --- Module Definitions ---

# Module 1: Data Lake Storage and Catalog
# This module creates the foundational components:
# - An S3 bucket to serve as the data lake storage.
# - An AWS Glue Catalog database and table to define the schema for the data.
module "data_lake" {
  source = "./modules/data_lake"

  unique_suffix = var.unique_suffix
}

# Module 2: Kinesis Firehose Delivery Stream
# This module creates the data pipeline that ingests streaming data and delivers it to S3.
# It uses the outputs from the `data_lake` module to know where to store the data and what schema to use.
module "firehose_s3_delivery" {
  source = "./modules/firehose_s3_delivery"

  unique_suffix      = var.unique_suffix
  aws_region         = var.aws_region
  s3_bucket_arn      = module.data_lake.s3_bucket_arn
  glue_database_name = module.data_lake.glue_database_name
  glue_table_name    = module.data_lake.glue_table_name
  glue_database_arn  = module.data_lake.glue_database_arn
  glue_table_arn     = module.data_lake.glue_table_arn
}

# Module 3: SNS Topic for Data Ingestion
# This module creates the entry point for the pipeline:
# - An SNS topic where applications can publish data messages.
# - A subscription that connects the SNS topic directly to the Kinesis Firehose stream.
module "sns_to_firehose" {
  source = "./modules/sns_to_firehose"

  unique_suffix               = var.unique_suffix
  kinesis_firehose_stream_arn = module.firehose_s3_delivery.kinesis_firehose_stream_arn
}