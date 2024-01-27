
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
  project = "woven-edge-412500"
  region  = "us-west1"
}

resource "google_storage_bucket" "data-lake-bucket" {
  name          = "woven-edge-412500-terra-bucket"
  location      = "US"
  force_destroy = true

  # Optional, but recommended settings:
  storage_class               = "STANDARD"
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
  dataset_id = "yellow_taxi_trips"
  project    = "woven-edge-412500"
  location   = "US"
  delete_contents_on_destroy = true
}