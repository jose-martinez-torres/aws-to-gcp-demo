output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket."
  value       = aws_s3_bucket.data_lake.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.data_lake.arn
}

output "glue_database_name" {
  description = "The name of the Glue database."
  value       = aws_glue_catalog_database.events_db.name
}

output "glue_database_arn" {
  description = "The ARN of the Glue database."
  value       = aws_glue_catalog_database.events_db.arn
}

output "glue_table_name" {
  description = "The name of the Glue table."
  value       = aws_glue_catalog_table.events_table.name
}

output "glue_table_arn" {
  description = "The ARN of the Glue table."
  value       = aws_glue_catalog_table.events_table.arn
}