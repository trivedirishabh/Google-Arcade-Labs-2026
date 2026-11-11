#!/bin/bash

set -e
gcloud config set project $DEVSHELL_PROJECT_ID
gcloud services enable container.googleapis.com

export GCLOUD_PROJECT=$(gcloud config get-value project)
export GCLOUD_BUCKET="${GCLOUD_PROJECT}-media"

gcloud storage cp -r gs://qwiklabs-gcp-03-8f460694c25a-assets/kubernetesengine .

cd ~/kubernetesengine/start

export APP_REGION=europe-west
export REGION=europe-west1
sed -i -e 's/us-central1/'"$REGION"'/g' -e 's/us-central/'"$APP_REGION"'/g' -e 's/python3/'"python3.12"'/g' prepare_environment.sh

sh ~/kubernetesengine/start/prepare_environment.sh

gcloud container clusters create quiz-cluster \
    --zone=europe-west1-b \
    --scopes=https://www.googleapis.com/auth/cloud-platform

gcloud container clusters get-credentials quiz-cluster --zone europe-west1-b --project qwiklabs-gcp-03-8f460694c25a

gcloud artifacts repositories create container-dev-repo --repository-format=docker \
  --location=europe-west1 \
  --description="Docker repository for Container Dev Workshop"

cat >frontend/Dockerfile <<EOF
FROM gcr.io/google_appengine/python

RUN virtualenv -p python3.7 /env

ENV VIRTUAL_ENV /env
ENV PATH /env/bin:$PATH

ADD requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

ADD . /app

CMD gunicorn -b 0.0.0.0:$PORT quiz:app
EOF

cat > backend/Dockerfile <<EOF
FROM gcr.io/google_appengine/python

RUN virtualenv -p python3.7 /env

ENV VIRTUAL_ENV /env
ENV PATH /env/bin:$PATH

ADD requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

ADD . /app

CMD python -m quiz.console.worker
EOF

cd ~/kubernetesengine/start
gcloud builds submit -t europe-west1-docker.pkg.dev/qwiklabs-gcp-03-8f460694c25a/container-dev-repo/quiz-frontend:v1 ./frontend/

gcloud builds submit -t europe-west1-docker.pkg.dev/qwiklabs-gcp-03-8f460694c25a/container-dev-repo/quiz-backend:v1 ./backend/


sed -i \
  -e "s|\[GCLOUD_PROJECT\]|$GCLOUD_PROJECT|g" \
  -e "s|\[GCLOUD_BUCKET\]|$GCLOUD_BUCKET|g" \
  -e "s|\[FRONTEND_IMAGE_IDENTIFIER\]|$REGION-docker.pkg.dev/$GCLOUD_PROJECT/container-dev-repo/quiz-frontend:v1|g" \
  frontend-deployment.yaml

sed -i \
  -e "s|\[GCLOUD_PROJECT\]|$GCLOUD_PROJECT|g" \
  -e "s|\[GCLOUD_BUCKET\]|$GCLOUD_BUCKET|g" \
  -e "s|\[BACKEND_IMAGE_IDENTIFIER\]|$REGION-docker.pkg.dev/$GCLOUD_PROJECT/container-dev-repo/quiz-backend:v1|g" \
  backend-deployment.yaml

cd ~/kubernetesengine/start

kubectl create -f ./frontend-deployment.yaml

kubectl create -f ./backend-deployment.yaml

kubectl create -f ./frontend-service.yaml

kubectl set env deployment/quiz-frontend PORT=8080
