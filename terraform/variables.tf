variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Region for the GCS bucket and BigQuery datasets (free tier: us-central1, us-east1, us-west1)"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Globally unique name for the data lake bucket"
  type        = string
}