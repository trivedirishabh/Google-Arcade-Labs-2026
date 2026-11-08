gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com

cat >index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.http('helloworld', (req, res) => {
  res.send('Hello World!');
});

EOF
cat >package.json<<EOF
{
  "name": "helloworld",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.4.0"
  }
}
EOF
gcloud run deploy helloworld \
  --source . \
  --function helloworld \
  --base-image nodejs22 \
  --region us-east4 \
  --execution-environment gen2 \
  --max 5 \
  --allow-unauthenticated

curl -LO 'https://github.com/tsenart/vegeta/releases/download/v12.12.0/vegeta_12.12.0_linux_386.tar.gz'

tar -xvzf vegeta_12.12.0_linux_386.tar.gz

CLOUD_RUN_URL=$(gcloud run services describe helloworld --region=us-east4 --format='value(status.url)')
echo $CLOUD_RUN_URL

echo "GET $CLOUD_RUN_URL" | ./vegeta attack -duration=300s -rate=200 > results.bin

gcloud logging metrics create CloudRunFunctionLatency-Logs \
  --description="Cloud Run function HTTP request latency" \
  --log-filter='resource.type="cloud_run_revision"
resource.labels.service_name="helloworld"
httpRequest.latency:*' \
  --value-extractor='EXTRACT(httpRequest.latency)' \
  --bucket-options='{"linearBuckets":{"numFiniteBuckets":10,"width":1,"offset":0}}'

