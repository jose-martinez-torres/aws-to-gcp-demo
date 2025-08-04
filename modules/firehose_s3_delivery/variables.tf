variable "unique_suffix" {
  description = "A random string to append to resource names for uniqueness."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources are created."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for Firehose to write to."
  type        = string
}

variable "glue_database_name" {
  description = "The name of the Glue database."
  type        = string
}

variable "glue_table_name" {
  description = "The name of the Glue table."
  type        = string
}

variable "glue_database_arn" {
  description = "The ARN of the Glue database."
  type        = string
}

variable "glue_table_arn" {
  description = "The ARN of the Glue table."
  type        = string
}