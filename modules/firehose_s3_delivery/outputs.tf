output "kinesis_firehose_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.s3_stream.arn
}