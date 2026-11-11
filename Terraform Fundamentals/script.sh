#!/bin/bash
cat <<'EOF' > ~/.customize_environment

# Set up HashiCorp repository and install Terraform

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).\*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
EOF
bash ~/.customize_environment

cat >instance.tf <<EOF
resource "google_compute_instance" "default" {
project = "qwiklabs-gcp-01-43933e144b2d"
zone = "us-west1-b"
name = "terraform"
machine_type = "e2-medium"
boot_disk {
initialize_params {
image = "debian-12"
}
}
network_interface {
network = "default"
access_config {
}
}
}
EOF

echo "Initiating terraform"

terraform init

echo " Starting terraform Plan"
terraform plan

echo "Applying terraform changes with auto-apply set to true"
terraform apply -auto-approve
