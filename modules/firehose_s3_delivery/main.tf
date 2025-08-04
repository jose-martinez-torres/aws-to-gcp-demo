# This module provisions the data pipeline using AWS Kinesis Firehose.
# It creates:
# 1. An IAM Role and Policy to grant the necessary permissions.
# 2. The Kinesis Firehose Delivery Stream itself, which is responsible for
#    ingesting, converting, and delivering data to the S3 data lake.

# --- IAM Permissions for Firehose ---
# Creates the identity and permissions that the Firehose service will use to access other AWS resources.
# The GCP equivalent is a Service Account with specific IAM roles.
resource "aws_iam_role" "firehose_role" {
  name = "aws-firehose-role-${var.unique_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

# Defines the specific permissions for the Firehose role.
resource "aws_iam_policy" "firehose_policy" {
  name        = "aws-firehose-policy-${var.unique_suffix}"
  description = "Policy for Kinesis Firehose to write to S3 and use Glue Catalog."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Allows Firehose to write data files to the S3 bucket.
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        # Allows Firehose to read the table schema from the Glue Data Catalog for data conversion.
        Effect = "Allow",
        Action = [
          "glue:GetTable",
          "glue:GetTableVersion",
          "glue:GetTableVersions"
        ],
        Resource = [
          var.glue_table_arn,
          var.glue_database_arn
        ]
      }
    ]
  })
}

# Attaches the policy to the role.
resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

# --- Kinesis Firehose Delivery Stream ---
# This is the core pipeline resource. It ingests, buffers, transforms, and delivers data.
# The GCP equivalent is a Cloud Dataflow job or a Pub/Sub to Cloud Storage subscription.
resource "aws_kinesis_firehose_delivery_stream" "s3_stream" {
  name        = "aws-firehose-stream-${var.unique_suffix}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.s3_bucket_arn

    # Best Practice: Partition data by arrival time for efficient querying
    # This creates a folder structure like: s3://.../data/2023/11/28/15/
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}"

    # Best Practice: Convert incoming JSON to columnar Parquet format
    data_format_conversion_configuration {
      enabled = true
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }
      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
      schema_configuration {
        role_arn      = aws_iam_role.firehose_role.arn
        database_name = var.glue_database_name
        table_name    = var.glue_table_name
        region        = var.aws_region
      }
    }
  }
}