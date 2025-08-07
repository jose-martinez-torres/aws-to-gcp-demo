# Create a Google Cloud Storage bucket
resource "google_storage_bucket" "data_lake_bucket" {
  name                        = "data-lake-bucket-${var.unique_suffix}"
  location                    = var.gcp_region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

}
