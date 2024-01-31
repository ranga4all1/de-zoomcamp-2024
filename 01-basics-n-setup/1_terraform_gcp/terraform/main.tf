# Replace variables in this file with your data - e. g. PROJECT_ID

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.13.0"
    }
  }
}

provider "google" {
  # Credentials only needs to be set if you do not have the GOOGLE_APPLICATION_CREDENTIALS set
  # credentials =
  project = "PROJECT_ID"
  region  = "REGION"
}

resource "google_storage_bucket" "data-lake-bucket" {
  name          = "GCS_BUCKET_NAME"
  location      = "LOCATION"
  force_destroy = true

  # Optional, but recommended settings:
  storage_class               = "GCS_STORAGE_CLASS"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30 // days
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "BQ_DATASET_NAME"
  project    = "PROJECT_ID"
  location   = "LOCATION"
  delete_contents_on_destroy = true
}