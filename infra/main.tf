# ============================================
# SILLALIBRE - Infraestructura Terraform
# ============================================
# Backend: S3 + DynamoDB locking
# Región: us-east-1 (decidido en ADR-003 / ENA-0-01)
# ============================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3 - Configurar después de crear bucket y DynamoDB
  # Ejecutar primero: terraform apply -target=module.backend
  # Luego descomentar y ejecutar: terraform init -migrate-state
  #
  # backend "s3" {
  #   bucket         = "REEMPLAZAR_CON_BUCKET_ID"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "sillalibre-tflock"
  #   encrypt        = true
  # }
}

# ============================================
# PROVIDER
# ============================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SillaLibre"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ============================================
# DATA SOURCES
# ============================================

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# MODULES
# ============================================

module "backend" {
  source = "./modules/backend"

  bucket_name         = "sillalibre-tfstate-${data.aws_caller_identity.current.account_id}"
  dynamodb_table_name = "sillalibre-tflock"
  kms_key_arn         = module.kms.key_arn
  environment         = var.environment
}

module "kms" {
  source = "./modules/kms"

  environment       = var.environment
  enable_key_rotation = true
}

# Módulos siguientes se descomentan según fase:
# module "vpc" { ... }
# module "rds" { ... }
# module "s3" { ... }
