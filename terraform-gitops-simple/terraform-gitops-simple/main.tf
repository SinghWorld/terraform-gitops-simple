###############################################################################
# terraform-gitops-simple | main.tf
# Owner : mrbalraj007
# Stage : GitOps + AI (Stage 4 & 5 – TechWorld with Nana)
###############################################################################

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "terraform-gitops-simple"
      ManagedBy   = "terraform"
      Owner       = "mrbalraj007"
      Environment = var.environment
    }
  }
}

###############################################################################
# S3 Demo Bucket  (via reusable module)
###############################################################################
module "demo_bucket" {
  source = "./modules/s3"

  bucket_name = "${var.project_name}-${var.environment}-${var.aws_region}"
  environment = var.environment

  enable_versioning = true
  enable_encryption = true
  block_public_access = true
}
