variable "unique_suffix" {
  description = "A unique suffix to append to all resource names to ensure uniqueness."
  type        = string
}

variable "kinesis_firehose_stream_arn" {
  description = "The ARN of the Kinesis Firehose stream to subscribe to."
  type        = string
}
