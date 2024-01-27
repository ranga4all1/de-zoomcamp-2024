variable "credentials" {
  description = "my credentials"
  default     = "../terraform/keys/my-creds.json"
  # Do NOT upload credentials files to github to repository or anywhere on internet
  # This can be done by adding those files/folders to .gitignore
}

variable "project" {
  description = "Project id"
  #Update the below to your project
  default = "woven-edge-412500"
}

variable "location" {
  description = "Project lopcation"
  #Update the below to your desired location
  default = "US"
}

variable "region" {
  description = "Project region"
  #Update the below to your desired region
  default = "us-west1"
}

variable "bq_dataset_name" {
  description = "My BigQuery dataset name"
  #Update the below to what you want your dataset to be called
  default = "yellow_taxi_trips"
}

variable "gcs_bucket_name" {
  description = "My storage bucket name"
  #Update the below to a unique bucket name
  default = "woven-edge-412500-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket storage class"
  #Update the below to your storage class
  default = "STANDARD"
}