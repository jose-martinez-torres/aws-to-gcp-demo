variable "unique_suffix" {
  description = "A unique suffix to append to resource names."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for the Dataflow job."
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic to read from (e.g., projects/PROJECT/topics/TOPIC)."
  type        = string
}

variable "gcs_output_directory" {
  description = "The GCS path for the output Parquet files (e.g., gs://bucket/path)."
  type        = string
}

variable "gcs_temp_location" {
  description = "A GCS path for Dataflow to stage temporary files."
  type        = string
}

variable "gcs_data_bucket_name" {
  description = "The name of the GCS bucket for output, temp files, and schema."
  type        = string
}

variable "dataflow_window_duration" {
  description = "The window duration for the Dataflow job (e.g., 5m, 10s). Determines how often files are written."
  type        = string
  default     = "5m"
}

variable "schema_content" {
  description = "The string content of the Avro schema file."
  type        = string
}

variable "labels" {
  description = "A map of labels to apply to the Dataflow job."
  type        = map(string)
}
