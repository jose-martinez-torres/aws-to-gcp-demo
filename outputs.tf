output "sns_topic_arn" {
  description = "The ARN of the SNS topic to publish messages to."
  value       = module.sns_to_firehose.sns_topic_arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket where data is stored."
  value       = module.data_lake.s3_bucket_id
}

output "glue_database_name" {
  description = "The name of the AWS Glue Catalog database."
  value       = module.data_lake.glue_database_name
}

output "glue_table_name" {
  description = "The name of the AWS Glue Catalog table."
  value       = module.data_lake.glue_table_name
}

output "athena_query_suggestion" {
  description = "A sample Athena query to run in the AWS console."
  value       = "SELECT * FROM \"${module.data_lake.glue_database_name}\".\"${module.data_lake.glue_table_name}\" limit 10;"
}