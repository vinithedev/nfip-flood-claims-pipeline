## How to reproduce

Tested on Linux, macOS and WSL2 (bash).

### Prerequisites
- GCP account with billing enabled (everything fits in the free tier)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- Terraform >= 1.5

### 1. Clone and configure
```bash
git clone https://github.com/YOUR_USER/nfip-flood-claims-pipeline.git
cd nfip-flood-claims-pipeline
cp .env.example .env    # edit PROJECT_ID
set -a; source .env; set +a
```
> Run `set -a; source .env; set +a` again in every new terminal.

### 2. Set up GCP
```bash
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud services enable bigquery.googleapis.com storage.googleapis.com

gcloud iam service-accounts create nfip-pipeline --display-name="NFIP pipeline"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:nfip-pipeline@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:nfip-pipeline@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"

mkdir -p ~/.gcp
gcloud iam service-accounts keys create $GOOGLE_APPLICATION_CREDENTIALS \
  --iam-account=nfip-pipeline@${PROJECT_ID}.iam.gserviceaccount.com
```

### 3. Create the infrastructure
```bash
cd terraform
terraform init
terraform apply
cd ..
```

### 4. _(ingestion, dbt and dashboard steps will be added here)_

### Teardown
```bash
cd terraform && terraform destroy
```