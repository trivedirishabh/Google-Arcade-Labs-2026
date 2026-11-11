PROJECT_ID=$(gcloud config get-value project)
BUCKET="travel-bucket-qwiklabs-gcp-04-4bc8524d9149"
TOPIC="travel-topic-938"
FUNCTION="travel-thumbnail-maker"
REGION="us-east4"

PROJECT_ID=$(gcloud config get-value project)
USER_EMAIL="student-01-27ade96c6a0b@qwiklabs.net"

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

gcloud config set compute/region $REGION

gcloud storage buckets create "gs://$BUCKET" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --default-storage-class=STANDARD

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="user:$USER_EMAIL" \
  --role="roles/storage.objectViewer"

gcloud pubsub topics create $TOPIC


#!/bin/bash
set -e



echo "Checking prerequisites..."

gcloud storage buckets describe "gs://$BUCKET" >/dev/null
gcloud pubsub topics describe "$TOPIC" >/dev/null

WORKDIR="$HOME/travel-thumbnail-maker"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "Creating index.js..."

cat > index.js <<'EOF'
"use strict";

const { Storage } = require("@google-cloud/storage");
const { PubSub } = require("@google-cloud/pubsub");
const imagemagick = require("imagemagick-stream");

const gcs = new Storage();
const pubsub = new PubSub();

exports.thumbnail = (cloudEvent) => {
  const fileName = cloudEvent.data.name;
  const bucketName = cloudEvent.data.bucket;
  const size = "64x64";
  const topicName = "travel-topic-938";

  const bucket = gcs.bucket(bucketName);

  if (fileName.includes("64x64_thumbnail")) {
    console.log(`${fileName} already has a thumbnail`);
    return;
  }

  const filenameSplit = fileName.split(".");
  const filenameExt = filenameSplit[filenameSplit.length - 1];

  if (!["png", "jpg"].includes(filenameExt.toLowerCase())) {
    console.log(`${fileName} is not a supported image`);
    return;
  }

  console.log(`Processing: gs://${bucketName}/${fileName}`);

  const filenameWithoutExt =
    fileName.substring(0, fileName.length - filenameExt.length);

  const newFilename =
    filenameWithoutExt + size + "_thumbnail." + filenameExt;

  const source = bucket.file(fileName);
  const destination = bucket.file(newFilename);

  const resize = imagemagick().resize(size).quality(90);

  return new Promise((resolve, reject) => {
    const srcStream = source.createReadStream();
    const dstStream = destination.createWriteStream();

    dstStream.on("error", reject);
    srcStream.on("error", reject);
    resize.on("error", reject);

    dstStream.on("finish", async () => {
      try {
        await destination.setMetadata({
          contentType: "image/" + filenameExt.toLowerCase()
        });

        const messageId = await pubsub
          .topic(topicName)
          .publish(Buffer.from(newFilename));

        console.log(`Success: ${newFilename}`);
        console.log(`Message ${messageId} published.`);

        resolve();
      } catch (err) {
        reject(err);
      }
    });

    srcStream.pipe(resize).pipe(dstStream);
  });
};
EOF

echo "Creating package.json..."

cat > package.json <<'EOF'
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/pubsub": "^2.0.0",
    "@google-cloud/storage": "^5.0.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  }
}
EOF

echo "Deploying Cloud Run Function..."

gcloud functions deploy "$FUNCTION" \
  --gen2 \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --runtime=nodejs22 \
  --source=. \
  --entry-point=thumbnail \
  --trigger-bucket="$BUCKET" \
  --trigger-location="$REGION" \
  --memory=512Mi \
  --timeout=120s

echo "Function deployment completed!"
