# This file declares that the Terraform configuration should use a GCS backend
# for remote state management. The specific bucket and prefix are not hardcoded
# here; they are provided dynamically by the cloudbuild.yaml file during CI/CD.
terraform {
  backend "gcs" {}
}