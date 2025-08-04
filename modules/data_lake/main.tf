# This module provisions the foundational components for an AWS Data Lake:
# 1. An S3 bucket for raw data storage.
# 2. AWS Glue resources (database and table) to provide a queryable schema over the data in S3.
# This creates a logical "data lake" pattern that can be queried by services like Amazon Athena.

# --- S3 Data Lake Storage ---
# The following resources create and configure the S3 bucket that will serve as the
# primary storage for the data lake. It includes security settings to block public
# access and versioning for data protection.

# Creates the S3 bucket. This is the physical storage location for the data.
# The GCP equivalent is a Google Cloud Storage (GCS) bucket.
resource "aws_s3_bucket" "data_lake" {
  bucket = "aws-datalake-bucket-${var.unique_suffix}"
}

# Enforces security best practices by blocking all public access to the bucket.
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enables versioning on the bucket to protect against accidental data deletion or overwrites.
resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- AWS Glue Data Catalog ---
# The following resources create the metadata layer for the data lake.
# This allows services like Amazon Athena to understand the structure of the
# data stored in S3 and query it using standard SQL.

# Creates a Glue Catalog Database, which acts as a logical container for tables.
# The GCP equivalent is a BigQuery Dataset.
resource "aws_glue_catalog_database" "events_db" {
  name = "aws_events_database_${var.unique_suffix}"
}

# AWS Glue Catalog table (The "BigQuery Table" definition)
# This defines the schema for the data Firehose will store in S3.
resource "aws_glue_catalog_table" "events_table" {
  name          = "aws_events_table_${var.unique_suffix}"
  database_name = aws_glue_catalog_database.events_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"            = "TRUE"
    "parquet.compression" = "SNAPPY"
    "projection.enabled"  = "true" # For Athena partition projection
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.id}/data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = "1"
      }
    }

    # Define the schema of the data. This tells query engines what columns to expect.
    columns {
      name = "eventid"
      type = "string"
    }
    columns {
      name = "eventtype"
      type = "string"
    }
    columns {
      name = "payload"
      type = "string"
    }
  }
}