###############################################################################
# backend.tf
# NOTE: The S3 state bucket must exist BEFORE running `terraform init`.
#       Run scripts/bootstrap.sh once to create it.
###############################################################################

terraform {
  backend "s3" {
    bucket  = "mrbalraj-tfstate-gitops" # created by bootstrap.sh
    key     = "simple/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
