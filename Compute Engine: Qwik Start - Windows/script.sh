export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances create my-vm \
  --project=$GOOGLE_CLOUD_PROJECT \
  --zone=us-west1-b \
  --machine-type=e2-medium \
  --image-family=windows-2022 \
  --image-project=windows-cloud \
  --boot-disk-size=50GB \
  --boot-disk-type=pd-balanced
  
gcloud compute instances get-serial-port-output my-vm --zone=us-west1-b

gcloud compute reset-windows-password my-vm --zone us-west1-b --user admin
