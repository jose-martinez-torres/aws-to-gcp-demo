# This module provisions the ingestion endpoint for the data pipeline.
# It creates:
# 1. An SNS Topic that applications can publish messages to.
# 2. A subscription that automatically forwards messages from the topic to the Kinesis Firehose stream.
# 3. The necessary IAM permissions to allow SNS to securely publish to Firehose.

# --- IAM Permissions for SNS ---
# Creates the identity and permissions that the SNS service will use to publish data to Firehose.
# The GCP equivalent is a Service Account with specific IAM roles.
resource "aws_iam_role" "sns_firehose_role" {
  name = "aws-sns-to-firehose-role-${var.unique_suffix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "sns.amazonaws.com"
        }
      }
    ]
  })
}

# Defines a policy that grants permission to publish records to a specific Firehose stream.
resource "aws_iam_policy" "sns_firehose_policy" {
  name        = "aws-sns-to-firehose-policy-${var.unique_suffix}"
  description = "Allows SNS to publish to a specific Kinesis Firehose stream."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "firehose:PutRecord",
        Effect   = "Allow",
        Resource = var.kinesis_firehose_stream_arn
      }
    ]
  })
}

# Attaches the policy to the role.
resource "aws_iam_role_policy_attachment" "sns_firehose_attach" {
  role       = aws_iam_role.sns_firehose_role.name
  policy_arn = aws_iam_policy.sns_firehose_policy.arn
}

# --- SNS Topic and Subscription ---
# Creates the messaging components that form the pipeline's entry point.

# The SNS Topic, which acts as the message ingestion point.
# The GCP equivalent is a Google Cloud Pub/Sub Topic.
resource "aws_sns_topic" "data_events" {
  name = "aws-data-events-topic-${var.unique_suffix}"
}

# The SNS Subscription that creates a direct link between the SNS Topic and the Kinesis Firehose stream.
# Any message published to the topic will be automatically sent to Firehose.
resource "aws_sns_topic_subscription" "firehose_subscription" {
  topic_arn              = aws_sns_topic.data_events.arn
  protocol               = "firehose"
  endpoint               = var.kinesis_firehose_stream_arn
  endpoint_auto_confirms = true
  subscription_role_arn  = aws_iam_role.sns_firehose_role.arn
}
