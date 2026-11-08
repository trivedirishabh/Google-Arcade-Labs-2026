# Developing a REST API with Go and Cloud Run

This lab builds and deploys a Go REST API to Cloud Run. The API starts with a health endpoint, then adds a customer endpoint backed by Cloud Firestore and imports sample data.

## Prerequisites

- A Google Cloud project with billing enabled
- Google Cloud CLI (`gcloud`) authenticated with permission to enable APIs and create Cloud Run, Artifact Registry, Firestore, and Cloud Storage resources
- Go and Git installed

## Before running the script

Review `script.sh` and update its project ID to your own project. The script currently uses a fixed project ID when setting the `gcloud` project and initializing Firestore, while its image commands use `GOOGLE_CLOUD_PROJECT`. Set that environment variable to the same project ID before running.

The script asks for a region for Firestore and Cloud Storage, but Cloud Run and Artifact Registry are configured for `us-east1`. Make sure the selected Firestore region is compatible with your project and intended setup.

The script creates cloud resources, deploys the service with unauthenticated access, and imports sample data. These resources may incur charges. Review the commands and access settings before running it.

## Run

After updating and reviewing the script, run it from this directory:

```bash
export GOOGLE_CLOUD_PROJECT="your-project-id"
bash script.sh
```

The script clones the lab source into a `pet-theory` directory, builds the Go service, and deploys it to Cloud Run.
