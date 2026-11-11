gcloud compute networks create managementnet --subnet-mode=custom
gcloud compute networks subnets create managementsubnet-1 --network=managementnet --region=us-west1 --range=10.130.0.0/20

gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatesubnet-1 --network=privatenet --region=us-west1 --range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-2 --network=privatenet --region=asia-south1 --range=172.20.0.0/20

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

gcloud compute instances create privatenet-vm-1 --zone=us-west1-b --machine-type=e2-micro --subnet=privatesubnet-1

gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

gcloud compute instances create managementnet-vm-1  --zone=us-west1-b --machine-type=e2-micro --subnet=managementsubnet-1

gcloud compute instances create vm-appliance \
  --zone=us-west1-b \
  --machine-type=e2-standard-4 \
  --network-interface=network=privatenet,subnet=privatesubnet-1 \
  --network-interface=network=managementnet,subnet=managementsubnet-1 \
  --network-interface=network=mynetwork,subnet=mynetwork