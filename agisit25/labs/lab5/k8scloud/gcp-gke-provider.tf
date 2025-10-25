# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud Native on a Cloud-Hosted Kubernetes
# Check how configure the provider here:
# https://www.terraform.io/docs/providers/google/index.html

provider "google" {
    # Create/Download your credentials from:
    # Google Console -> "APIs & services -> Credentials"
    credentials = file("./xxxxxxxxxxxxxxxxxxxxxxxxxx.json")
}
