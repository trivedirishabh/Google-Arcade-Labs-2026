echo "Provide Region"
read Region

PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/region $Region

gcloud storage buckets create gs://$PROJECT_ID
BUCKET="gs://$PROJECT_ID"

curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg
gcloud storage cp ada.jpg $BUCKET

rm ada.jpg

gcloud storage cp -r $BUCKET/ada.jpg .

gcloud storage cp $BUCKET/ada.jpg $BUCKET/image-folder/

gcloud storage objects update $BUCKET/ada.jpg --add-acl-grant=entity=allUsers,role=READER

echo "hit enter"
read enter

gcloud storage objects update $BUCKET/ada.jpg --remove-acl-grant=allUsers
gcloud storage rm $BUCKET/ada.jpg