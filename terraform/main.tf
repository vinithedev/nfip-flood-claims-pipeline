terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

locals {
  labels = {
    project    = "nfip-flood-claims"
    managed_by = "terraform"
  }
}

# Data lake: raw files from OpenFEMA
resource "google_storage_bucket" "data_lake" {
  name                        = var.bucket_name
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.labels

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# Raw layer: data loaded as-is from the lake
resource "google_bigquery_dataset" "raw" {
  dataset_id                 = "nfip_raw"
  location                   = var.location
  description                = "Raw NFIP claims loaded from the data lake"
  delete_contents_on_destroy = true
  labels                     = local.labels
}

# Analytics layer: dbt models (staging, intermediate, marts)
resource "google_bigquery_dataset" "analytics" {
  dataset_id                 = "nfip_analytics"
  location                   = var.location
  description                = "dbt models: staging, intermediate and marts"
  delete_contents_on_destroy = true
  labels                     = local.labels
}