PROJECT_ID=$(gcloud config get-value project)

gcloud storage buckets create gs://$PROJECT_ID \
  --project=$PROJECT_ID \
  --location=us-central1 \
  --default-storage-class=STANDARD \
  --uniform-bucket-level-access \
  --no-public-access-prevention

BUCKET="gs://$PROJECT_ID"

gcloud storage cp gs://arcade-labs/kitten.png .

gcloud storage cp kitten.png $BUCKET

gcloud storage buckets add-iam-policy-binding gs://$PROJECT_ID \
  --member=allUsers \
  --role=roles/storage.objectViewer

gcloud storage folders create "$BUCKET/folder1/"
gcloud storage folders create "$BUCKET/folder1/folder2/"
gcloud storage cp kitten.png "$BUCKET/folder1/folder2/"
